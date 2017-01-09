require 'rails_helper'

RSpec.describe Api::V1::SlidesController, type: :controller do
  let(:first_user) { create(:first_user) }

  describe 'GET #index' do
    it 'render index' do
      get :index, format: 'json'
      expect(response.status).to eq(200)
      expect(response).to render_template :index
    end

    it 'assigns the @slides' do
      @slides = create_list(:slide, 2)
      get :index, format: 'json'
      expect(response.status).to eq(200)
      expect(assigns(:slides).to_a).to eq(@slides)
    end
  end

  describe 'GET #show' do
    it 'render show' do
      slide = create(:slide)
      get :show, params: { id: slide.id }, format: 'json'
      expect(response.status).to eq(200)
      expect(assigns(:slide)).to eq(slide)
    end

    it 'returns error' do
      get :show, params: { id: 448 }, format: 'json'
      expect(response.status).to eq(404)
    end
  end

  describe 'GET #transcript' do
    it 'render show' do
      slide = create(:slide)
      get :transcript, params: { id: slide.id }, format: 'json'
      expect(response.status).to eq(200)
      expect(assigns(:slide)).to eq(slide)
    end

    it 'returns error' do
      get :transcript, params: { id: 448 }, format: 'json'
      expect(response.status).to eq(404)
    end
  end
end
