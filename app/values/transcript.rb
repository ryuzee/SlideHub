class Transcript
  include WebResource

  attr_accessor :object_key

  def initialize(object_key)
    @object_key = object_key
  end

  def url
    "#{CloudConfig::provider.resource_endpoint}/#{object_key}/transcript.txt"
  end

  def lines
    @lines ||= get_php_serialized_data(url)
  end

  def exist?
    result = false
    if lines.instance_of?(Array)
      lines.each do |tran|
        unless tran.empty?
          result = true
          break
        end
      end
    end
    result
  end
end
