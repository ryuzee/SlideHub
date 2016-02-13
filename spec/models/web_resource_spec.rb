require 'rails_helper'

describe 'WebResource' do
  # assign concern to a model
  let(:test_class) { Struct.new(:dummy) { include WebResource } }
  let(:dummy) { test_class.new }

  describe 'get_json' do
    it 'succeed to retrieve json' do
      stub_request(:any, 'http://www.example.com/toro.json').to_return(
        body: { 'test' => 'ok' }.to_json,
        status: 200,
      )
      expect(dummy.get_json('http://www.example.com/toro.json', 1)).to eq({ 'test' => 'ok' })
    end

    it 'succeed to retrieve json with redirect' do
      stub_request(:any, 'http://www.example.com/toro.json').to_return(
        status: 301,
        headers: { 'Location' => 'http://www.example.com/uni.json' },
      )
      stub_request(:any, 'http://www.example.com/uni.json').to_return(
        body: { 'test' => 'ok' }.to_json,
        status: 200,
      )
      expect(dummy.get_json('http://www.example.com/toro.json', 2)).to eq({ 'test' => 'ok' })
    end

    it 'fail to retrieve json because of 404' do
      stub_request(:any, 'http://www.example.com/toro.json').to_return(
        status: 404,
      )
      expect(dummy.get_json('http://www.example.com/toro.json', 1)).to eq(false)
    end
  end

  describe 'get_php_serialized_data' do
    it 'return normalized data' do
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        body: 'a:1:{s:4:"test";s:2:"ok";}',
        status: 200,
      )
      expect(dummy.get_php_serialized_data('http://www.example.com/transcript.txt', 1)).to eq({ 'test' => 'ok' })
    end

    it 'return empty data if resource was corrupted' do
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        body: 'abcdefg',
        status: 200,
      )
      expect(dummy.get_php_serialized_data('http://www.example.com/transcript.txt', 1)).to eq([])
    end

    it 'return empty data' do
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        status: 404,
      )
      expect(dummy.get_php_serialized_data('http://www.example.com/transcript.txt', 1)).to eq([])
    end
  end
end
