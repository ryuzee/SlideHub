# require 'batch_logger'
# require 'cloud/queue/response'
# require 'convert_util'
# require 'image'
require 'tmpdir'
require_relative 'env_util'

module SlideHub
  # スライドを画像などに変換する。
  #   object_key          元のファイルがあるキー
  #   new_object_key      変換結果を置くキー（再変換）。元のファイルもここにコピーし、変換後にスライドをこのキーに切り替える
  #   previous_object_key 変換が終わったら消す古いキー（ファイルの差し替え）
  # キーを変えるのは URL を変えるため。CDN やブラウザに古い画像が残っていても、新しい画像が表示される
  class ConvertProcedure
    def initialize(object_key:, logger:, new_object_key: nil, previous_object_key: nil)
      @object_key = object_key
      @output_key = new_object_key.presence || object_key
      @previous_object_key = previous_object_key.presence
      @logger = logger
      @work_dir = ''
      @work_file = SecureRandom.hex.to_s
      @file_type = ''
      @slide_image_list = []
      @upload_file_list = []
      @convert_util = SlideHub::ConvertUtil.new(logger)
    end

    def run
      Dir.mktmpdir do |dir|
        @work_dir = dir
        logger.info("Current directory is #{work_dir}")
        return false unless save_file

        convert_to_jpg
        generate_json
        convert_to_thumbnail
        convert_to_transcript
        upload_files
        copy_original_file
        update_database
        delete_old_files
        true
      end
    end

    private

      attr_reader :logger, :work_dir, :object_key, :output_key, :previous_object_key, :work_file, :convert_util

      def save_file
        return false unless CloudConfig.provider.save_file(CloudConfig.provider.config.bucket_name, object_key, "#{work_dir}/#{work_file}")

        @file_type = convert_util.get_slide_file_type("#{work_dir}/#{work_file}")
        true
      end

      def convert_to_jpg
        case @file_type
        when 'pdf'
          logger.info('Rename to PDF')
          convert_util.rename_to_pdf(work_dir, work_file)
        when 'ppt', 'pptx'
          logger.info('Start converting from PPT to PDF')
          convert_util.ppt_to_pdf(work_dir, work_file)
        else
          false
        end
        logger.info('Start converting from PDF to JPG')
        @slide_image_list = convert_util.pdf_to_jpg(work_dir, work_file.to_s)
        logger.info(convert_util.get_local_file_list(work_dir, '').inspect)
        @upload_file_list = @slide_image_list.dup
        true
      end

      def convert_to_thumbnail
        logger.info('Generating thumbnails')
        logger.info(@slide_image_list.inspect)
        thumbnail_list = convert_util.jpg_to_thumbnail(@slide_image_list)
        thumbnail_list.each do |tm|
          @upload_file_list.push(tm)
        end if thumbnail_list.instance_of?(Array)
      end

      def convert_to_transcript
        transcript = convert_util.pdf_to_transcript(work_dir, "#{work_file}.pdf")
        @upload_file_list.push(transcript) if transcript
      end

      def generate_json
        save_list = []
        @slide_image_list.each do |item|
          save_list.push("#{output_key}/#{File.basename(item)}")
        end
        File.open("#{work_dir}/list.json", 'w') do |io|
          JSON.dump(save_list, io)
        end
        @upload_file_list.push("#{work_dir}/list.json")
      end

      def upload_files
        logger.info(@upload_file_list.inspect)
        CloudConfig.provider.upload_files(CloudConfig.provider.config.image_bucket_name, @upload_file_list, output_key)
      end

      # 再変換では、元のファイルも新しいキーにコピーする（ダウンロードや次の再変換で使う）
      def copy_original_file
        return if output_key == object_key

        logger.info("Copy the original file from #{object_key} to #{output_key}")
        CloudConfig.provider.copy_slide(object_key, output_key)
      end

      # もう使っていない古いキーのファイル（元のファイルと変換結果）を消す。
      # どのスライドからも参照されていないことを確かめてから消す
      def delete_old_files
        old_keys = [previous_object_key, (object_key if output_key != object_key)].compact.uniq - [output_key]
        old_keys.each do |key|
          if key_in_use?(key)
            logger.info("Keep the files of #{key} because a slide still uses it")
            next
          end

          logger.info("Delete the old files of #{key}")
          CloudConfig.provider.delete_slide(key)
          CloudConfig.provider.delete_generated_files(key)
        end
      rescue StandardError => e
        # 消せなくても変換は済んでいるので、失敗扱いにはしない（メッセージを繰り返さない）
        logger.error("Failed to delete the old files: #{e.message}")
      end

      def key_in_use?(key)
        return true if Slide.key_exist?(key)
        return false unless SlideHub::EnvUtil.fetch('MULTI_TENANT', false)

        in_use = Tenant.pluck(:name).any? do |tenant|
          Apartment::Tenant.switch(tenant) { Slide.key_exist?(key) }
        end
        Apartment::Tenant.reset
        in_use
      end

      def update_database
        # If multi-tenanted, update all database which includes specified object_key
        if SlideHub::EnvUtil.fetch('MULTI_TENANT', false)
          tenants = Tenant.pluck(:name)
          tenants.each do |tenant|
            Apartment::Tenant.switch(tenant) do
              logger.info("tenant is #{tenant}")
              Slide.update_after_convert(object_key, @file_type, @slide_image_list.count, new_object_key: output_key)
            end
          end
          Apartment::Tenant.reset
        end
        # Update main database
        Slide.update_after_convert(object_key, @file_type, @slide_image_list.count, new_object_key: output_key)
      end
  end
end
