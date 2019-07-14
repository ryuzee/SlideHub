require 'rails_helper'

describe 'WebResource' do
  # assign concern to a model
  let(:test_class) { Struct.new(:dummy) { include WebResource } }
  let(:dummy) { test_class.new }
  let(:url_dummy) { 'http://www.example.com/toro.json' }

  describe 'get_json' do
    it 'succeed to retrieve json' do
      stub_request(:any, url_dummy).to_return(
        body: { 'test' => 'ok' }.to_json,
        status: 200,
      )
      expect(dummy.get_json(url_dummy, 1)).to eq({ 'test' => 'ok' })
    end

    it 'succeed to retrieve json with redirect' do
      url_redirect = 'http://www.example.com/uni.json'
      stub_request(:any, url_dummy).to_return(
        status: 301,
        headers: { 'Location' => url_redirect },
      )
      stub_request(:any, url_redirect).to_return(
        body: { 'test' => 'ok' }.to_json,
        status: 200,
      )
      expect(dummy.get_json(url_dummy, 2)).to eq({ 'test' => 'ok' })
    end

    it 'fail to retrieve json because of 404' do
      stub_request(:any, url_dummy).to_return(
        status: 404,
      )
      expect(dummy.get_json(url_dummy, 1)).to eq(false)
    end
  end

  describe 'get_php_serialized_data' do
    it 'return normalized data' do
      stub_request(:any, url_dummy).to_return(
        body: 'a:1:{s:4:"test";s:2:"ok";}',
        status: 200,
      )
      expect(dummy.get_php_serialized_data(url_dummy, 1)).to eq({ 'test' => 'ok' })
    end

    it 'return empty data if resource was corrupted' do
      stub_request(:any, url_dummy).to_return(
        body: 'abcdefg',
        status: 200,
      )
      expect(dummy.get_php_serialized_data(url_dummy, 1)).to eq([])
    end

    it 'return empty data' do
      stub_request(:any, url_dummy).to_return(
        status: 404,
      )
      expect(dummy.get_php_serialized_data(url_dummy, 1)).to eq([])
    end
  end

  describe 'get_contents' do
    it 'returns false when url is not valid' do
      url_invalid_protocol = 'hogehoge://www.example.com/transcript.txt'
      expect(dummy.get_contents(url_invalid_protocol, 1)).to eq(false)
    end
  end
end
