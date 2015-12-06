module SqsUsable
  extend ActiveSupport::Concern

  def sqs
    @sqs ||= Aws::SQS::Client.new(region: ENV['OSS_REGION'])
  end

  def send_message(message)
    resp = sqs.send_message({
      queue_url: ENV['OSS_SQS_URL'],
      message_body: message,
    },)
    resp
  end

  def receive_message(max_number = 10)
    sqs.receive_message(queue_url: ENV['OSS_SQS_URL'], visibility_timeout: 30, max_number_of_messages: max_number)
  end

  def delete_message(message_object)
    resp = sqs.delete_message({
      queue_url: ENV['OSS_SQS_URL'],
      receipt_handle: message_object.receipt_handle,
    },)
    resp
  end

  def batch_delete(entries)
    sqs.delete_message_batch(queue_url: ENV['OSS_SQS_URL'], entries: entries)
  end
end
