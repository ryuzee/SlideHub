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
      allow(AWSEngine).to receive(:send_message).and_return(true)
      data = build(:slide)
      login_by_user first_user
      post :create, slide: data.attributes
      id = Slide.where(key: data.key).first.id
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{id}"
    end

    it 'faled to create record because of validation' do
      allow(AWSEngine).to receive(:send_message).and_return(true)
      data = build(:slide)
      data.category_id = nil # cause validation error
      login_by_user first_user
      post :create, slide: data.attributes
      expect(response.status).to eq(200)
      expect(response).to render_template 'slides/aws/new'
    end
  end

  describe 'GET #edit' do
    it 'render edit' do
      create(:slide)
      login_by_user first_user
      slide_id = Slide.where("user_id = #{first_user.id}").first.id
      get :edit, id: slide_id
      expect(response.status).to eq(200)
      expect(response).to render_template 'slides/aws/edit'
    end

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

  describe 'POST #update' do
    it 'failed to update record because the user is not the owner' do
      data = create(:slide)
      general_user = create(:general_user)
      login_by_user general_user
      post :update, { id: data.id, slide: data.attributes }
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{data.id}"
    end

    it 'failed to update the record because of validation error and then render edit' do
      data = create(:slide)
      data.convert_status = 100
      data.name = nil
      login_by_user first_user
      post :update, { id: data.id, slide: data.attributes }
      expect(response.status).to eq(200)
      expect(response).to render_template 'slides/aws/edit'
    end

    it 'succeeds to update the record without running conversion' do
      data = create(:slide)
      data.convert_status = 100
      data.name = 'Engawa'
      login_by_user first_user
      post :update, { id: data.id, slide: data.attributes }
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{data.id}"
      saved_record = Slide.find(data.id)
      expect(saved_record.name).to eq(data.name)
    end

    it 'succeeds to update the record with running conversion' do
      allow(AWSEngine).to receive(:send_message).and_return(true)
      data = create(:slide)
      data.convert_status = 0 # Not converted yet...
      data.name = 'Engawa'
      login_by_user first_user
      post :update, { id: data.id, slide: data.attributes }
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{data.id}"
      saved_record = Slide.find(data.id)
      expect(saved_record.name).to eq(data.name)
    end
  end

  describe 'DELETE #destroy' do
    it 'failed to delete the slide because the user is not the owner' do
      data = create(:slide)
      general_user = create(:general_user)
      login_by_user general_user
      delete :destroy, { id: data.id }
      expect(response.status).to eq(302)
      expect(response).to redirect_to '/slides/index'
    end

    it 'succeeds to update the record with running conversion' do
      allow(AWSEngine).to receive(:delete_slide).and_return(true)
      allow(AWSEngine).to receive(:delete_generated_files).and_return(true)
      data = create(:slide)
      login_by_user first_user
      delete :destroy, { id: data.id }
      expect(response.status).to eq(302)
      expect(response).to redirect_to '/slides/index'
      expect(Slide.exists?(data.id)).to eq(false)
    end
  end

  describe 'GET #update_view' do
    it 'succeeds to retrieve json' do
      allow_any_instance_of(Slide).to receive(:page_list).and_return(['a'])
      slide = create(:slide)
      get :update_view, id: slide.id
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['page_count']).to eq(1)
    end

    it 'returns 0' do
      allow_any_instance_of(Slide).to receive(:page_list).and_return(['a'])
      get :update_view, id: 65535
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['page_count']).to eq(0)
    end
  end
end
