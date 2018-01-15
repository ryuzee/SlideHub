require 'batch_logger'
require 'cloud/queue/response'
require 'convert_procedure'

class Batch
  def self.execute
    logger = SlideHub::BatchLogger

    logger.info('Start convert process')
    resp = CloudConfig::SERVICE.receive_message(5)
    unless resp.exist?
      logger.info('No Queue message found')
      return true
    end

    resp.messages.each do |msg|
      obj = JSON.parse(msg.body)
      logger.info("Start converting slide. id=#{obj['id']} object_key=#{obj['object_key']}")
      result = ConvertProcedure.new(object_key: obj['object_key'], logger: SlideHub::BatchLogger).run
      if result
        logger.info("Delete message from Queue. id=#{obj['id']} object_key=#{obj['object_key']}")
        CloudConfig::SERVICE.delete_message(msg)
      else
        logger.error("Slide conversion failed. id=#{obj['id']} object_key=#{obj['object_key']}")
      end
    end
  end
end
