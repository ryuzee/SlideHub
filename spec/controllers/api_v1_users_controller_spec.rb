require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'API' do
    describe 'GET /users/998' do
      it 'works!' do
        create(:general_user)
        get 'show', params: { id: '998' }, format: 'json'
        expect(response.status).to eq(200)
        json = JSON.parse(response.body);
        keys = ['id', 'username', 'display_name', 'biography', 'slides_count']
        keys.each do |k|
          expect(json.has_key?(k)).to eq(true)
        end
      end
    end
  end
end
