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
      @key_cleanup = SlideHub::SlideKeyCleanup.new(logger: logger)
    end

    def run
      Dir.mktmpdir do |dir|
        @work_dir = dir
        logger.info("Current directory is #{work_dir}")
        return false unless save_file
        return give_up_unsupported_file unless convert_to_jpg

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

      attr_reader :logger, :work_dir, :object_key, :output_key, :previous_object_key, :work_file, :convert_util, :key_cleanup

      def save_file
        return false unless CloudConfig.provider.save_file(CloudConfig.provider.config.bucket_name, object_key, "#{work_dir}/#{work_file}")

        @file_type = convert_util.get_slide_file_type("#{work_dir}/#{work_file}")
        true
      end

      def convert_to_jpg
        return false unless @file_type == 'pdf'

        logger.info('Rename to PDF')
        convert_util.rename_to_pdf(work_dir, work_file)
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
        @upload_file_list.concat(thumbnail_list) if thumbnail_list.instance_of?(Array)
      end

      def convert_to_transcript
        transcript = convert_util.pdf_to_transcript(work_dir, "#{work_file}.pdf")
        @upload_file_list.push(transcript) if transcript
      end

      def generate_json
        save_list = @slide_image_list.map { |item| "#{output_key}/#{File.basename(item)}" }
        File.write("#{work_dir}/list.json", JSON.dump(save_list))
        @upload_file_list.push("#{work_dir}/list.json")
      end

      def upload_files
        logger.info(@upload_file_list.inspect)
        CloudConfig.provider.upload_files(CloudConfig.provider.config.image_bucket_name, @upload_file_list, output_key)
      end

      # 再変換では、元のファイルも新しいキーにコピーする
      def copy_original_file
        key_cleanup.copy_original(object_key, output_key) if output_key != object_key
      end

      def delete_old_files
        key_cleanup.delete_unused([previous_object_key, (object_key if output_key != object_key)].compact.uniq - [output_key])
      end

      def update_database
        in_each_database do
          Slide.update_after_convert(object_key, @file_type, @slide_image_list.count, new_object_key: output_key)
        end
      end

      # PDF ではないファイルは変換できない。スライドを変換エラーにして終える
      # （true を返してキューのメッセージを消し、同じ失敗を繰り返さない）
      def give_up_unsupported_file
        logger.error("Unsupported file type: #{@file_type.inspect} object_key=#{object_key}")
        in_each_database { Slide.find_by(object_key: object_key)&.convert_error! }
        true
      end

      # マルチテナントのときは、各テナントのデータベースでも同じ処理をする
      def in_each_database(&)
        if SlideHub::EnvUtil.fetch('MULTI_TENANT', false)
          Tenant.pluck(:name).each do |tenant|
            Apartment::Tenant.switch(tenant, &)
          end
          Apartment::Tenant.reset
        end
        yield
      end
  end
end
