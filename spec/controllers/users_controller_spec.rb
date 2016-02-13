require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'When logged in' do
    let(:general_user) { create(:general_user) }
    before do
      login_by_user general_user
    end

    describe 'GET /users/index' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /users/statistics' do
      it 'works!' do
        get 'statistics'
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'No Login' do
    describe 'GET /users/998' do
      it 'works!' do
        create(:general_user)
        get 'show', id: '998'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /users/index' do
      it 'redirect to login' do
        get 'index'
        expect(response.status).to eq(302)
      end
    end

    describe 'GET /users/statistics' do
      it 'redirect to login' do
        get 'index'
        expect(response.status).to eq(302)
      end
    end
  end
end
