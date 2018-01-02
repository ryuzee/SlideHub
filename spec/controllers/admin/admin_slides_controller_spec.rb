require 'rails_helper'

RSpec.describe Admin::SlidesController, type: :controller do
  describe 'Slides' do
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/slides/' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /admin/slides/edit/1' do
      it 'works!' do
        create(:slide)
        get 'edit', params: { id: '1' }
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /admin/slides/update' do
      it 'works!' do
        create(:slide)
        data = Slide.find(1)
        update_name = 'SushiKuitai'
        data[:name] = update_name
        post :update, params: { id: data.id, slide: data.attributes }
        expect(response.status).to eq(302)
        new_name = Slide.find(1).name
        expect(update_name).to eq(new_name)
      end
    end

    describe 'POST /admin/slides/update' do
      it 'move to edit screen' do
        create(:slide)
        data = Slide.find(1)
        update_name = '' # validation error
        data[:name] = update_name
        post :update, params: { id: data.id, slide: data.attributes }
        expect(response.status).to eq(200)
        expect(response).to render_template :edit
      end
    end
  end
end
