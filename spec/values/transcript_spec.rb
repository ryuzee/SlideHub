require 'rails_helper'

describe 'Transcript' do
  before do
    CloudConfig.provider = SlideHub::Cloud::Engine::Aws
    CloudHelpers.switch_to_aws
  end

  describe 'Transcript' do
    it 'can be retrieved and put it into array' do
      stub_request(:get, Transcript.new('an_object_key').url).to_return(
        body: 'a:1:{i:0;s:4:"Test";}',
        status: 200,
      )
      transcript = Transcript.new('an_object_key')
      expect(transcript.lines).to eq(['Test'])
      expect(transcript.exist?).to eq(true)
    end

    it 'returns no lines when the file does not exist' do
      stub_request(:get, Transcript.new('an_object_key').url).to_return(
        status: 404,
      )
      transcript = Transcript.new('an_object_key')
      expect(transcript.lines).to eq([])
      expect(transcript.exist?).to eq(false)
    end

    it 'can be retrieved. however the result is empty' do
      stub_request(:get, Transcript.new('an_object_key').url).to_return(
        body: 'a:1:{i:0;s:0:"";}',
        status: 200,
      )
      transcript = Transcript.new('an_object_key')
      expect(transcript.exist?).to eq(false)
    end
  end

  describe 'Method "url"' do
    it 'returns valid url' do
      transcript = Transcript.new('an-object-key')
      expect(transcript.url).to eq('https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/an-object-key/transcript.txt')
    end
  end
end

describe 'Slide_on_Azure' do
  before do
    CloudConfig.provider = SlideHub::Cloud::Engine::Azure
    CloudHelpers.switch_to_azure
  end

  describe 'Method "url"' do
    it 'returns valid url' do
      transcript = Transcript.new('an-object-key')
      expect(transcript.url).to eq('https://azure_test.blob.core.windows.net/my-image-bucket/an-object-key/transcript.txt')
    end
  end
end
