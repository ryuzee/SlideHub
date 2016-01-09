require 'rails_helper'

describe 'Users' do
  describe 'GET /users/sign_in' do
    it 'works!' do
      get '/users/sign_in'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /users/sign_up' do
    it 'works!' do
      get '/users/sign_up'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /users/1' do
    it 'works!' do
      create(:slide)
      get '/users/1'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /users/view/1 (Backward Compatibility)' do
    it 'works!' do
      create(:slide)
      get '/users/view/1'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /users/new' do
    it 'does not exist!' do
      expect { get '/users/new' }.to raise_error(AbstractController::ActionNotFound)
    end
  end
end
