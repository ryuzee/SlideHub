module SqsUsable
  extend ActiveSupport::Concern

  def sqs
    @sqs ||= Aws::SQS::Client.new(region: AWSConfig.config.region)
  end

  def send_message(message)
    resp = sqs.send_message({
      queue_url: AWSConfig.config.sqs_url,
      message_body: message,
    },)
    resp
  end

  def receive_message(max_number = 10)
    sqs.receive_message(queue_url: AWSConfig.config.sqs_url, visibility_timeout: 30, max_number_of_messages: max_number)
  end

  def delete_message(message_object)
    resp = sqs.delete_message({
      queue_url: AWSConfig.config.sqs_url,
      receipt_handle: message_object.receipt_handle,
    },)
    resp
  end

  def batch_delete(entries)
    sqs.delete_message_batch(queue_url: AWSConfig.config.sqs_url, entries: entries)
  end
end
