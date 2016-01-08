require 'rails_helper'

describe 'Storage' do
  describe 'initialize storage' do
    storage = Storage.new
    it 'should have more than 1 file' do
      if ENV.has_key?('OSS_BUCKET_NAME') && ENV.has_key?('OSS_AWS_ACCESS_ID') && ENV.has_key?('OSS_AWS_SECRET_KEY')
        expect(storage.get_file_list('ossfiles-dev', '').count).to be > 0
      end
    end
  end
end
