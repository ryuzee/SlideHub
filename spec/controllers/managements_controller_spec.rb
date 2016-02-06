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

    describe 'GET /managements/custom_contents_setting' do
      it 'works!' do
        get 'custom_contents_setting'
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'Managements_without_Login' do
    describe 'GET /managements/dashboard' do
      it 'redirect to login' do
        get 'dashboard'
        expect(response.status).to eq(302)
      end
    end
  end
end
