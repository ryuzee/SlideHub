require 'rails_helper'

RSpec.describe SlidesController, type: :controller do
  let(:first_user) { create(:first_user) }

  describe 'GET #index' do
    it 'render index' do
      get :index
      expect(response.status).to eq(200)
      expect(response).to render_template :index
    end

    it 'assigns the @latest_slides' do
      @latest_slides = create_list(:slide, 2)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:latest_slides).to_a).to eq(@latest_slides)
    end
  end

  describe 'GET #show' do
    it 'assigns @comment if user logged in' do
      slide = create(:slide)
      login_by_user first_user
      get :show, id: slide.id
      expect(assigns(:comment)).to be_an_instance_of(Comment)
    end
  end

  describe 'GET #latest' do
    it 'render latest' do
      get :latest
      expect(response.status).to eq(200)
      expect(response).to render_template :latest
    end
  end

  describe 'GET #popular' do
    it 'render popular' do
      get :popular
      expect(response.status).to eq(200)
      expect(response).to render_template :popular
    end
  end

  describe 'GET #search' do
    it 'render search' do
      get :search
      expect(response.status).to eq(200)
      expect(response).to render_template :search
    end
  end

  describe 'GET #category' do
    it 'render category' do
      create(:slide)
      create(:first_category)
      get :category, category_id: '1'
      expect(response.status).to eq(200)
      expect(response).to render_template :category
    end
  end

  describe 'GET #new' do
    it 'render new' do
      login_by_user first_user
      get :new
      expect(response.status).to eq(200)
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    it 'succeed to create record' do
      allow_any_instance_of(SlidesController).to receive(:send_message).and_return(true)
      data = build(:slide)
      login_by_user first_user
      post :create, slide: data.attributes
      id = Slide.where(key: data.key).first.id
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{id}"
    end

    it 'faled to create record because of validation' do
      allow_any_instance_of(SlidesController).to receive(:send_message).and_return(true)
      data = build(:slide)
      data.category_id = nil # cause validation error
      login_by_user first_user
      post :create, slide: data.attributes
      expect(response.status).to eq(200)
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    it 'render edit' do
      create(:slide)
      login_by_user first_user
      slide_id = Slide.where("user_id = #{first_user.id}").first.id
      get :edit, id: slide_id
      expect(response.status).to eq(200)
      expect(response).to render_template :edit
    end
  end

  describe 'GET #edit' do
    it 'redirect to show' do
      create(:slide)
      general_user = create(:general_user)
      login_by_user general_user
      slide_id = Slide.where("user_id = #{first_user.id}").first.id
      get :edit, id: slide_id
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{slide_id}"
    end
  end
end
