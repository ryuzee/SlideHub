require 'spec_helper'

describe 'Storage' do
  describe 'initialize storage' do
    storage = Storage.new
    it 'should have more than 1 file' do
      expect(storage.get_file_list('ossfiles-dev', '').count).to be > 0
    end
  end
end
