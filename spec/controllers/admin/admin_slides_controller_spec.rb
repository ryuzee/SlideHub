require 'rails_helper'

RSpec.describe Admin::SlidesController, type: :controller do
  describe 'Slides' do
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/slides/' do
      render_views
      it 'shows all slides regardless of the conversion status' do
        slides = create_list(:slide, 3, convert_status: -1)
        get 'index'
        expect(response.status).to eq(200)
        expect(assigns(:slides)).to eq(slides)
        expect(response).to render_template :index
        expect(response.content_type).to eq 'text/html'
      end
    end

    describe 'GET /admin/slides/index.csv' do
      it 'returns csv that includes all slides' do
        slides = create_list(:slide, 3, convert_status: -1)
        get 'index', { format: 'csv' }
        expect(response.status).to eq(200)
        expect(assigns(:slides)).to eq(slides)
        expect(response).to render_template :index
        expect(response.content_type).to eq 'text/csv'
      end
    end

    describe 'GET /admin/slides/edit/1' do
      it 'shows the form to edit slide' do
        create(:slide)
        get 'edit', params: { id: '1' }
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /admin/slides/update' do
      it 'succeeds to update slide if parameters are valid' do
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
      it 'failed to update slide and shows the form again if parameters are invalid' do
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
