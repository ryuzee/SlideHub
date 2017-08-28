require 'spec_helper'
require 'rails_helper'

RSpec.describe ApplicationHelper, type: 'helper' do
  describe 'nl2br' do
    it 'returns html that includes <br />' do
      expect(helper.nl2br("test\ntest")).to eq 'test<br />test'
    end

    it 'returns html that includes <br />' do
      expect(helper.nl2br("test\rtest")).to eq 'test<br />test'
    end

    it 'returns html that includes <br />' do
      expect(helper.nl2br("test\r\ntest")).to eq 'test<br />test'
    end

    it 'returns html that includes multiple <br />' do
      expect(helper.nl2br("test\n\ntest")).to eq 'test<br /><br />test'
    end

    it 'returns original' do
      expect(helper.nl2br('testtest')).to eq 'testtest'
    end
  end
end
