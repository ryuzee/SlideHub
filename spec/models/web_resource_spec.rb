require 'rails_helper'
require 'webmock'
include WebMock::API
WebMock.allow_net_connect!
#WebMock.disable_net_connect!(:allow => [/codeclimate.com/, /amazonaws.com/])

describe 'WebResource' do
  # assign concern to a model
  let(:test_class) { Struct.new(:dummy) { include WebResource } }
  let(:dummy) { test_class.new }

  before do
  end

  describe 'get_json' do
    it 'succeed to retrieve json' do
      stub_request(:any, "http://www.example.com/toro.json").to_return(
        :body => {"test" => "ok"}.to_json,
        :status => 200
      )
      expect(dummy.get_json('http://www.example.com/toro.json', 1)).to eq({"test" => "ok"})
    end

    it 'succeed to retrieve json with redirect' do
      stub_request(:any, "http://www.example.com/toro.json").to_return(
        :status => 301,
        :headers => {'Location' => 'http://www.example.com/uni.json'}
      )
      stub_request(:any, "http://www.example.com/uni.json").to_return(
        :body => {"test" => "ok"}.to_json,
        :status => 200
      )
      expect(dummy.get_json('http://www.example.com/toro.json', 2)).to eq({"test" => "ok"})
    end

    it 'fail to retrieve json because of 404' do
      stub_request(:any, "http://www.example.com/toro.json").to_return(
        :status => 404
      )
      expect(dummy.get_json('http://www.example.com/toro.json', 1)).to eq(false)
    end
  end
end
