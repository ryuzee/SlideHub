require 'rails_helper'

RSpec.describe ManagementsController, :type => :controller do
  describe 'Managements' do
    let(:user_admin) { create(:user_admin) }
    before do
      login_admin user_admin
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
end
