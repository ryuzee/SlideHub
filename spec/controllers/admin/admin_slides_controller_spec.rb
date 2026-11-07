require 'rails_helper'

RSpec.describe Admin::SlidesController, type: :controller do
  render_views
  let(:admin_user) { create(:admin_user) }

  before do
    login_by_admin_user admin_user
  end

  describe 'GET /admin/slides/' do
    it 'shows all slides regardless of the conversion status' do
      slides = create_list(:slide, 3, convert_status: -1)
      get 'index'
      expect(response.status).to eq(200)
      expect(assigns(:slides)).to eq(slides)
      expect(response).to render_template :index
      expect(response.content_type).to match(%r{text/html})
    end

    it 'loads the authors together with the slides' do
      create_list(:slide, 2)
      get 'index'
      expect(assigns(:slides).map { |slide| slide.association(:user).loaded? }).to all(be(true))
    end
  end

  describe 'GET /admin/slides/index.csv' do
    it 'returns csv that includes all slides' do
      slides = create_list(:slide, 3, convert_status: -1)
      get 'index', params: { format: 'csv' }
      expect(response.status).to eq(200)
      expect(assigns(:slides)).to eq(slides)
      expect(response).to render_template :index
      expect(response.content_type).to match(%r{text/csv})
    end

    it 'puts each value under its own heading' do
      slide = create(:slide, page_view: 12, embedded_view: 34, download_count: 56)
      create(:comment_for_slide, slide: slide)
      get 'index', params: { format: 'csv' }
      rows = CSV.parse(response.body, headers: true)
      row = rows.find { |r| r[I18n.t('activerecord.attributes.slide.id')] == slide.id.to_s }
      expect(row[I18n.t('activerecord.attributes.slide.convert_status')]).to eq(slide.convert_status_i18n)
      expect(row[I18n.t('activerecord.attributes.slide.page_view')]).to eq('12')
      expect(row[I18n.t('activerecord.attributes.slide.embedded_view')]).to eq('34')
      expect(row[I18n.t('activerecord.attributes.slide.download_count')]).to eq('56')
      expect(row[I18n.t('activerecord.attributes.slide.comments')]).to eq(slide.reload.comments_count.to_s)
    end
  end

  describe 'GET /admin/slides/edit/1' do
    it 'shows the form filled with the current slide' do
      slide = create(:slide, name: 'Sushi Talk')
      get 'edit', params: { id: slide.id }
      expect(response.status).to eq(200)
      expect(response.body).to include('value="Sushi Talk"')
    end
  end

  describe 'POST /admin/slides/update' do
    it 'updates the slide when the values are valid' do
      slide = create(:slide)
      post :update, params: { id: slide.id, slide: slide.attributes.merge('name' => 'SushiKuitai') }
      expect(response.status).to eq(302)
      expect(Slide.find(slide.id).name).to eq('SushiKuitai')
    end

    it 'shows the form again and keeps the old name when the name is empty' do
      slide = create(:slide, name: 'Sushi Talk')
      post :update, params: { id: slide.id, slide: slide.attributes.merge('name' => '') }
      expect(response.status).to eq(200)
      expect(response).to render_template :edit
      expect(Slide.find(slide.id).name).to eq('Sushi Talk')
    end
  end
end
