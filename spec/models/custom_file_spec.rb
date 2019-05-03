require 'rails_helper'

describe 'CustomFile' do
  describe 'custom_file directory' do
    it 'returns "custom-files" when tenant is not set' do
      expect(CustomFile.custom_files_directory).to eq('custom-files')
    end

    it 'includes tenant name when tenant is set' do
      allow(Tenant).to receive(:identifier).and_return('hoge')
      expect(CustomFile.custom_files_directory).to eq('custom-files/hoge')
    end
  end
end
