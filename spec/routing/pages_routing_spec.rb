require 'rails_helper'

describe PagesController do
  describe 'routing' do
    it 'routes to #show by path' do
      page = create(:default_page)
      expect(get("/pages/#{page.path}")).to route_to('pages#show', path: page.path)
    end
  end
end
