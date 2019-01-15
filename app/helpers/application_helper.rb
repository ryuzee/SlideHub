module ApplicationHelper
  def js_prefix
    require 'securerandom'
    require 'digest/md5'
    prefix = 'js' + Digest::MD5.hexdigest(SecureRandom.hex + Time.zone.now.strftime('%Y%m%d%H%M%S'))
    prefix
  end
end
