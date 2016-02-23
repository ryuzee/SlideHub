require 'rails_helper'

RSpec.describe ManagementsController, type: :controller do
  describe 'Managements' do
    let(:user_admin) { create(:user_admin) }
    before do
      login_by_admin_user user_admin
    end

    describe 'GET /managements/dashboard' do
      it 'works!' do
        get 'dashboard'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /managements/slide_list' do
      it 'works!' do
        get 'slide_list'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /managements/slide_edit/1' do
      it 'works!' do
        create(:slide)
        get 'slide_edit', id: '1'
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /managements/slide_update' do
      it 'works!' do
        create(:slide)
        data = Slide.find(1)
        update_name = 'SushiKuitai'
        data[:name] = update_name
        post :slide_update, slide: data.attributes
        expect(response.status).to eq(302)
        new_name = Slide.find(1).name
        expect(update_name).to eq(new_name)
      end
    end

    describe 'POST /managements/slide_update' do
      it 'move to edit screen' do
        create(:slide)
        data = Slide.find(1)
        update_name = '' # validation error
        data[:name] = update_name
        post :slide_update, slide: data.attributes
        expect(response.status).to eq(200)
        expect(response).to render_template :slide_edit
      end
    end

    describe 'GET /managements/user_list' do
      it 'works!' do
        get 'user_list'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /managements/site_setting' do
      it 'works!' do
        get 'site_setting'
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /managements/site_update' do
      it 'works!' do
        data = [{"var"=>"site.Neta1", "value"=>"Toro"}, {"var"=>"site.Neta2", "value"=>"Unit"}]
        post :site_update, settings: data
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/managements/site_setting'
        settings = CustomSetting.unscoped.where("var like 'site.Neta%'")
        expect(settings.length).to eq(2)
      end
    end

    describe 'GET /managements/custom_contents_setting' do
      it 'works!' do
        get 'custom_contents_setting'
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /managements/custom_contents_update' do
      it 'works!' do
        data = [{"var"=>"custom_content.Neta1", "value"=>"Toro"}, {"var"=>"custom_content.Neta2", "value"=>"Unit"}]
        post :custom_contents_update, settings: data
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/managements/custom_contents_setting'
        settings = CustomSetting.unscoped.where("var like 'custom_content.Neta%'")
        expect(settings.length).to eq(2)
      end
    end
  end

  describe 'Managements_without_Login' do
    describe 'GET /managements/dashboard' do
      it 'redirect to login' do
        get 'dashboard'
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'Prohibitted to access MC by normal user' do
    describe 'GET /managements/dashboard' do
      it 'redirect to login' do
        general_user = create(:general_user)
        login_by_user general_user
        get 'dashboard'
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end
end
