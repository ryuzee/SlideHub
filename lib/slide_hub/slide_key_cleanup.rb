module SlideHub
  # ファイルの差し替えや再変換でキー（フォルダ）を切り替えたときの、ファイルの移動と片付け
  class SlideKeyCleanup
    def initialize(logger:)
      @logger = logger
    end

    # 元のファイルを新しいキーにコピーする（再変換で、ダウンロードや次の再変換に使う）
    def copy_original(from_key, to_key)
      logger.info("Copy the original file from #{from_key} to #{to_key}")
      CloudConfig.provider.copy_slide(from_key, to_key)
    end

    # もう使っていないキーのファイル（元のファイルと変換結果）を消す。
    # どのスライドからも参照されていないことを確かめてから消す
    def delete_unused(keys)
      keys.each do |key|
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

    private

      attr_reader :logger

      def key_in_use?(key)
        return true if Slide.key_exist?(key)
        return false unless SlideHub::EnvUtil.fetch('MULTI_TENANT', false)

        in_use = Tenant.pluck(:name).any? do |tenant|
          Apartment::Tenant.switch(tenant) { Slide.key_exist?(key) }
        end
        Apartment::Tenant.reset
        in_use
      end
  end
end
