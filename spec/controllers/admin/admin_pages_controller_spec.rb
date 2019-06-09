require 'rails_helper'

RSpec.describe Admin::PagesController, type: :controller do
  describe 'Pages' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/pages/' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /admin/pages/new' do
      it 'works!' do
        get 'new'
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /admin/pages' do
      it 'works!' do
        post 'create', params: { page: { path: 'abc', title: 'test', content: 'content' } }
        expect(response.status).to eq(302)
        expect(response).to redirect_to admin_pages_path
      end

      it 'render form' do
        post 'create', params: { page: { path: 'abc', title: '', content: 'content' } }
        expect(response.status).to eq(200)
        expect(response).to render_template :new
      end
    end

    describe 'GET /admin/pages/edit/1' do
      it 'works!' do
        target = create(:default_page)
        get 'edit', params: { id: target.id }
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /admin/pages/update' do
      it 'works!' do
        target = create(:default_page)
        data = Page.find(target.id)
        update_title = 'SushiKuitai'
        data[:title] = update_title
        keys = %w[id path title content]
        data_attr = data.attributes
        data_attr.each_key do |k, _v|
          data_attr.delete(k) unless keys.include?(k)
        end
        post :update, params: { id: target.id, page: data_attr }
        new_title = Page.find(target.id).title
        expect(new_title).to eq(update_title)
        expect(response.status).to eq(302)
      end
    end

    describe 'POST /admin/pages/update' do
      it 'move to edit screen' do
        target = create(:default_page)
        data = Page.find(target.id)
        update_title = '' # validation error
        data[:title] = update_title
        keys = %w[id path title content]
        data_attr = data.attributes
        data_attr.each_key do |k, _v|
          data_attr.delete(k) unless keys.include?(k)
        end
        post :update, params: { id: target.id, page: data_attr }
        expect(response.status).to eq(200)
        expect(response).to render_template :edit
      end
    end

    describe 'DELETE /admin/page' do
      it 'works' do
        target = create(:default_page)
        delete :destroy, params: { id: target.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to admin_pages_path
        expect(Page.where(id: target.id).count).to eq(0)
      end
    end
  end
end
