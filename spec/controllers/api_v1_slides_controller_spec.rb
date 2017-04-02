require 'rails_helper'

RSpec.describe Api::V1::SlidesController, type: :controller do
  before(:each) { request.env['HTTP_ACCEPT'] = 'application/json' }
  render_views
  let(:first_user) { create(:first_user) }
  list_json_keys = %w(id user_id name description category_id object_key extension)
  list_json_keys += %w(num_of_pages created_at category_name username thumbnail_url transcript_url tags)

  describe 'GET #index' do
    it 'renders index' do
      create_list(:slide, 2)
      get :index, format: 'json'
      expect(response.status).to eq(200)
      expect(response).to render_template :index
      json = JSON.parse(response.body);
      expect(json.count).to be > 0
      json.each do |j|
        list_json_keys.each do |k|
          expect(j.key?(k)).to eq(true)
        end
      end
    end

    it 'assigns @slides' do
      @slides = create_list(:slide, 2)
      get :index, format: 'json'
      expect(response.status).to eq(200)
      expect(assigns(:slides).to_a).to eq(@slides)
    end
  end

  describe 'GET #index with name' do
    it 'renders index' do
      create_list(:slide, 2)
      get :index, params: { name: 'Hoge' }, format: 'json'
      expect(response.status).to eq(200)
      expect(response).to render_template :index
      json = JSON.parse(response.body);
      expect(json.count).to be > 0
      json.each do |j|
        list_json_keys.each do |k|
          expect(j.key?(k)).to eq(true)
        end
      end
    end
  end

  describe 'GET #index with tag' do
    it 'renders index' do
      create_list(:slide, 2)
      get :index, params: { tag: 'Sushi' }, format: 'json'
      expect(response.status).to eq(200)
      expect(response).to render_template :index
      json = JSON.parse(response.body);
      expect(json.count).to be > 0
      json.each do |j|
        list_json_keys.each do |k|
          expect(j.key?(k)).to eq(true)
        end
      end
    end
  end

  describe 'GET #show' do
    it 'renders show' do
      slide = create(:slide)
      get :show, params: { id: slide.id }, format: 'json'
      expect(response.status).to eq(200)
      expect(assigns(:slide)).to eq(slide)
      json = JSON.parse(response.body);
      list_json_keys.each do |k|
        expect(json.key?(k)).to eq(true)
      end
    end

    it 'returns error' do
      get :show, params: { id: 448 }, format: 'json'
      expect(response.status).to eq(404)
    end
  end

  describe 'GET #transcript' do
    it 'renders show' do
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
