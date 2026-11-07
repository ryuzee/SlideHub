# == Schema Information
#
# Table name: slides
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  name           :string(255)      not null
#  description    :text(65535)      not null
#  downloadable   :boolean          default(FALSE), not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime
#  key            :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#

require 'rails_helper'

RSpec.describe SlidesController, type: :controller do
  render_views
  let(:default_user) { create(:default_user) }

  before do
    CloudConfig.provider = SlideHub::Cloud::Engine::Aws
    CloudHelpers.switch_to_aws
  end

  describe 'GET #index' do
    it 'shows the latest and popular sections' do
      create(:slide, name: 'Fresh Sushi')
      get :index
      expect(response.status).to eq(200)
      expect(response).to render_template :index
      expect(response.body).to include(I18n.t(:latest_slides), I18n.t(:popular_slides), 'Fresh Sushi')
    end

    it 'assigns the @latest_slides' do
      @latest_slides = create_list(:slide, 2)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:slide_index).latest_slides).to eq(@latest_slides)
    end

    it 'returns collect resource strings' do
      request.env['HTTP_ACCEPT_LANGUAGE'] = 'ja'
      get :index
      expect(response.status).to eq(200)
      expect(response.body).to include(I18n.t(:popular_slides))
    end

    it 'returns collect header' do
      theme = ApplicationSetting['site.theme']
      ApplicationSetting['site.theme'] = 'default'
      inverse = ApplicationSetting['site.header_inverse']
      ApplicationSetting['site.header_inverse'] = 1
      get :index
      expect(response.status).to eq(200)
      expect(response.body).to include('site-header-inverse navbar-dark')
      begin
        ApplicationSetting['site.header_inverse'] = 0
        get :index
        expect(response.body).not_to include('site-header-inverse')
      ensure
        ApplicationSetting['site.header_inverse'] = inverse
        ApplicationSetting['site.theme'] = theme
      end
    end
  end

  describe 'GET #show' do
    it 'shows the slide and a comment form to a signed-in user' do
      slide = create(:slide, name: 'Sushi Talk')
      login_by_user default_user
      get :show, params: { id: slide.id }
      expect(response.status).to eq(200)
      expect(assigns(:comment)).to be_an_instance_of(Comment)
      expect(response.body).to include('Sushi Talk', 'name="comment[comment]"')
    end

    it 'counts the page view' do
      slide = create(:slide)
      expect { get :show, params: { id: slide.id } }.to change { slide.reload.page_view }.by(1)
    end
  end

  describe 'GET #new' do
    it 'shows the upload form' do
      login_by_user default_user
      get :new
      expect(response.status).to eq(200)
      expect(response).to render_template :new
      expect(response.body).to include('id="file"', 'name="slide[name]"', 'id="SlideKey"')
    end
  end

  describe 'POST #create' do
    it 'creates the slide for the signed-in user and asks to convert it' do
      data = build(:slide, name: 'New Talk')
      login_by_user default_user
      expect(CloudConfig.provider).to receive(:send_message) do |message|
        expect(JSON.parse(message)['object_key']).to eq(data.object_key)
      end
      post :create, params: { slide: data.attributes }
      created = Slide.find_by(object_key: data.object_key)
      expect(response).to redirect_to "/slides/#{created.id}"
      expect(created).to have_attributes(name: 'New Talk', user_id: default_user.id)
    end

    it 'shows the form again without creating anything when the category is missing' do
      data = build(:slide)
      data.category_id = nil
      login_by_user default_user
      expect(CloudConfig.provider).not_to receive(:send_message)
      expect { post :create, params: { slide: data.attributes } }.not_to change(Slide, :count)
      expect(response.status).to eq(200)
      expect(response).to render_template "slides/#{CloudConfig.service_name}/new"
    end

    it 'does not create a second slide with a key that is already used' do
      existing = create(:slide)
      data = build(:slide, object_key: existing.object_key)
      login_by_user default_user
      expect(CloudConfig.provider).not_to receive(:send_message)
      expect { post :create, params: { slide: data.attributes } }.not_to change(Slide, :count)
      expect(response).to redirect_to slides_path
    end
  end

  describe 'GET #edit' do
    it 'shows the form, with a new key for replacing the file' do
      slide = create(:slide, name: 'Sushi Talk', user: default_user)
      login_by_user default_user
      get :edit, params: { id: slide.id }
      expect(response.status).to eq(200)
      expect(response).to render_template "slides/#{CloudConfig.service_name}/edit"
      expect(response.body).to include('value="Sushi Talk"')
      upload_key = response.body[/id="key" name="key" value='([0-9a-f]{32})'/, 1]
      expect(upload_key).to be_present
      expect(upload_key).not_to eq(slide.object_key)
    end

    it 'redirect to show' do
      create(:slide)
      another_user = create(:another_user)
      login_by_user another_user
      slide_id = Slide.where("user_id = #{default_user.id}").first.id
      get :edit, params: { id: slide_id }
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{slide_id}"
    end
  end

  describe 'POST #update' do
    it 'failed to update record because the user is not the owner' do
      data = create(:slide)
      another_user = create(:another_user)
      login_by_user another_user
      post :update, params: { id: data.id, slide: data.attributes.merge('name' => 'Taken over') }
      expect(response).to redirect_to "/slides/#{data.id}"
      expect(Slide.find(data.id).name).to eq(data.name)
    end

    it 'failed to update the record because of validation error and then render edit' do
      data = create(:slide)
      data.converted!
      data.name = nil
      login_by_user default_user
      post :update, params: { id: data.id, slide: data.attributes }
      expect(response.status).to eq(200)
      expect(response).to render_template "slides/#{CloudConfig.service_name}/edit"
      expect(Slide.find(data.id).name).to eq('Hoge')
    end

    it 'succeeds to update the record without running conversion' do
      data = create(:slide)
      data.converted!
      data.name = 'Engawa'
      login_by_user default_user
      post :update, params: { id: data.id, slide: data.attributes }
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/slides/#{data.id}"
      saved_record = Slide.find(data.id)
      expect(saved_record.name).to eq(data.name)
    end

    it 'does not run conversion when only the text is changed, even if the slide is not converted' do
      data = create(:slide)
      data.unconverted!
      data.name = 'Engawa'
      login_by_user default_user
      expect(CloudConfig.provider).not_to receive(:send_message)
      post :update, params: { id: data.id, slide: data.attributes }
      expect(response).to redirect_to "/slides/#{data.id}"
      expect(Slide.find(data.id).name).to eq('Engawa')
    end

    it 'runs conversion with the previous key when the file is replaced with a new key' do
      data = create(:slide)
      data.converted!
      previous_key = data.object_key
      login_by_user default_user
      expect(CloudConfig.provider).to receive(:send_message) do |message|
        expect(JSON.parse(message)).to eq('id' => data.id, 'object_key' => 'replacedkey', 'previous_object_key' => previous_key)
      end
      post :update, params: { id: data.id, slide: data.attributes.merge('object_key' => 'replacedkey') }
      expect(response).to redirect_to "/slides/#{data.id}"
      saved_record = Slide.find(data.id)
      expect(saved_record.object_key).to eq('replacedkey')
      expect(saved_record.convert_status).to eq('unconverted')
    end

    it 'ignores the convert status sent from the browser' do
      data = create(:slide)
      data.converted!
      login_by_user default_user
      expect(CloudConfig.provider).not_to receive(:send_message)
      post :update, params: { id: data.id, slide: data.attributes.merge('convert_status' => 'unconverted') }
      expect(Slide.find(data.id).convert_status).to eq('converted')
    end
  end

  describe 'DELETE #destroy' do
    it 'failed to delete the slide because the user is not the owner' do
      data = create(:slide)
      another_user = create(:another_user)
      login_by_user another_user
      delete :destroy, params: { id: data.id }
      expect(response).to redirect_to "/slides/#{data.id}"
      expect(Slide.exists?(data.id)).to be(true)
    end

    it 'deletes the slide and its files' do
      data = create(:slide)
      expect(CloudConfig.provider).to receive(:delete_slide).with(data.object_key)
      expect(CloudConfig.provider).to receive(:delete_generated_files).with(data.object_key)
      login_by_user default_user
      delete :destroy, params: { id: data.id }
      expect(response.status).to eq(302)
      expect(response).to redirect_to '/slides'
      expect(Slide.exists?(data.id)).to eq(false)
    end
  end
end
