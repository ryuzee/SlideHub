require 'net/http'
require 'uri'
require 'json'

# :reek:DataClump { enabled: false }
module WebResource
  extend ActiveSupport::Concern

  def get_json(location, limit = 10)
    result = get_contents(location, limit)
    if result
      JSON.parse(result)
    else
      false
    end
  end

  def get_php_serialized_data(location, limit = 10)
    result = get_contents(location, limit)
    if result
      begin
        response = result.dup.force_encoding('utf-8')
        require 'php_serialization/unserializer'
        return PhpSerialization::Unserializer.new.run(response)
      rescue
        return []
      end
    else
      []
    end
  end

  # :reek:FeatureEnvy { enabled: false }
  def get_contents(location, limit = 10)
    raise ArgumentError, 'too many HTTP redirects' if limit.zero?
    uri = URI.parse(location)
    begin
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get(uri.request_uri)
      end
      case response
      when Net::HTTPSuccess
        response.body
      when Net::HTTPRedirection
        get_contents(response['location'], limit - 1)
      else
        false
      end
    rescue
      false
    end
  end
end
