require 'rails_helper'

describe 'Users' do
  describe 'GET /users/sign_in' do
    it 'shows the sign-in form' do
      get '/users/sign_in'
      expect(response.status).to eq(200)
      expect(response.body).to include('name="user[email]"', 'name="user[password]"')
    end
  end

  describe 'GET /users/sign_up' do
    it 'shows the sign-up form' do
      get '/users/sign_up'
      expect(response.status).to eq(200)
      expect(response.body).to include('name="user[email]"', 'name="user[username]"')
    end
  end

  describe 'GET /users/1' do
    it 'shows the profile and the slides of the user' do
      slide = create(:slide, name: 'Sushi Talk')
      get "/users/#{slide.user_id}"
      expect(response.status).to eq(200)
      expect(response.body).to include('User01', 'Sushi Talk')
    end
  end

  describe 'GET /users/view/1 (Backward Compatibility)' do
    it 'shows the same profile at the old URL' do
      slide = create(:slide, name: 'Sushi Talk')
      get "/users/view/#{slide.user_id}"
      expect(response.status).to eq(200)
      expect(response.body).to include('User01', 'Sushi Talk')
    end
  end
end
