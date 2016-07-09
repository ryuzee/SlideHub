require 'rails_helper'
require 'spec_helper'

describe 'SlideHub::Cloud::Queue::Response' do
  describe 'add message' do
    it 'stores message' do
      response = SlideHub::Cloud::Queue::Response.new
      expect(response.exist?).to eq(false)
      response.add_message(1, 'a', 'b')
      expect(response.exist?).to eq(true)
      message = response.messages.pop
      expect(message.id).to eq(1)
      expect(message.body).to eq('a')
      expect(message.handle).to eq('b')
    end
  end
end
