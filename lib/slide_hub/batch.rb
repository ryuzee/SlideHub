# require 'batch_logger'
# require 'cloud/queue/response'
# require 'convert_procedure'

module SlideHub
  class Batch
    def self.execute
      logger = SlideHub::BatchLogger

      logger.info('Start convert process')
      resp = CloudConfig.provider.receive_message(5)
      unless resp.exist?
        logger.info('No Queue message found')
        return true
      end

      resp.messages.each do |msg|
        obj = JSON.parse(msg.body)
        result = process(obj, logger)
        logger.error("Processing failed. type=#{obj['type']} id=#{obj['id']} object_key=#{obj['object_key']}") unless result
        # サムネイル再生成は失敗しても繰り返さない（ページ画像が無いなど、やり直しても直らないため）
        if result || obj['type'] == 'thumbnail'
          logger.info("Delete message from Queue. id=#{obj['id']} object_key=#{obj['object_key']}")
          CloudConfig.provider.delete_message(msg)
        end
      end
    end

    # type が thumbnail のメッセージは一覧用サムネイルの再生成だけを行う（管理画面の一括再生成）。
    # それ以外（type なし）はスライドの変換。
    def self.process(obj, logger)
      if obj['type'] == 'thumbnail'
        logger.info("Start regenerating thumbnails. id=#{obj['id']} object_key=#{obj['object_key']}")
        ThumbnailProcedure.new(object_key: obj['object_key'], logger: logger).run
      else
        logger.info("Start converting slide. id=#{obj['id']} object_key=#{obj['object_key']} " \
                    "new_object_key=#{obj['new_object_key']} previous_object_key=#{obj['previous_object_key']}")
        ConvertProcedure.new(object_key: obj['object_key'], new_object_key: obj['new_object_key'],
                             previous_object_key: obj['previous_object_key'], logger: logger).run
      end
    end
  end
end
