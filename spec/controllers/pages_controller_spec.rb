require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'GET #show' do
    it 'leads to the custom page' do
      page = create(:default_page)
      get :show, params: { path: page.path }
      expect(assigns(:page)).to be_an_instance_of(Page)
      expect(response.status).to eq(200)
      expect(response).to render_template :show
    end

    it 'leads to 404' do
      expect { get :show, params: { path: 'no_existent_path' } }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Page")
    end
  end
end
