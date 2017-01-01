require 'rails_helper'

describe HtmlPlayerController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get('/html_player/1')).to route_to('html_player#show', id: '1')
    end
  end
end
