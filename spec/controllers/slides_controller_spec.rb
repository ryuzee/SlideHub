require 'rails_helper'

RSpec.describe SlidesController, type: :controller do
  describe 'GET #show' do
    it 'render index' do
      get :index
      expect(response).to render_template :index
    end

    it 'assigns the @latest_slides' do
      @latest_slides = create_list(:slide, 2)
      get :index
      expect(assigns(:latest_slides).to_a).to eq(@latest_slides)
    end

    it 'render latest' do
      get :latest
      expect(response).to render_template :latest
    end

    it 'render popular' do
      get :popular
      expect(response).to render_template :popular
    end

    it 'render search' do
      get :search
      expect(response).to render_template :search
    end
  end
end
