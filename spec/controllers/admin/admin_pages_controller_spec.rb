require 'rails_helper'

RSpec.describe Admin::PagesController, type: :controller do
  render_views
  let(:admin_user) { create(:admin_user) }

  before do
    login_by_admin_user admin_user
  end

  describe 'GET /admin/pages/' do
    it 'lists the pages' do
      create(:default_page, title: 'About this site')
      get 'index'
      expect(response.status).to eq(200)
      expect(response.body).to include('About this site')
    end
  end

  describe 'GET /admin/pages/new' do
    it 'shows the form to create a page' do
      get 'new'
      expect(response.status).to eq(200)
      expect(response.body).to include('name="page[path]"', 'name="page[title]"', 'name="page[content]"')
    end
  end

  describe 'POST /admin/pages' do
    it 'creates a page' do
      expect { post 'create', params: { page: { path: 'abc', title: 'test', content: 'content' } } }.to change(Page, :count).by(1)
      expect(response).to redirect_to admin_pages_path
      expect(Page.find_by(path: 'abc')).to have_attributes(title: 'test', content: 'content')
    end

    it 'shows the form again without creating anything when the title is missing' do
      expect { post 'create', params: { page: { path: 'abc', title: '', content: 'content' } } }.not_to change(Page, :count)
      expect(response.status).to eq(200)
      expect(response).to render_template :new
    end
  end

  describe 'GET /admin/pages/edit/1' do
    it 'shows the form filled with the current page' do
      target = create(:default_page)
      get 'edit', params: { id: target.id }
      expect(response.status).to eq(200)
      expect(response.body).to include('value="About"', 'Contents')
    end
  end

  describe 'POST /admin/pages/update' do
    it 'updates the page' do
      target = create(:default_page)
      post :update, params: { id: target.id, page: { path: target.path, title: 'SushiKuitai', content: target.content } }
      expect(response).to redirect_to admin_pages_path
      expect(Page.find(target.id).title).to eq('SushiKuitai')
    end

    it 'shows the form again and keeps the old title when the title is empty' do
      target = create(:default_page)
      post :update, params: { id: target.id, page: { path: target.path, title: '', content: target.content } }
      expect(response.status).to eq(200)
      expect(response).to render_template :edit
      expect(Page.find(target.id).title).to eq('About')
    end
  end

  describe 'DELETE /admin/page' do
    it 'deletes the page' do
      target = create(:default_page)
      delete :destroy, params: { id: target.id }
      expect(response).to redirect_to admin_pages_path
      expect(Page.where(id: target.id).count).to eq(0)
    end
  end
end
