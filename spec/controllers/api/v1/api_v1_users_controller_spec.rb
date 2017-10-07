require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'API' do
    let!(:default_user) { create(:default_user) }

    describe 'GET /users/1' do
      it 'works!' do
        get 'show', params: { id: '1' }, format: 'json'
        expect(response.status).to eq(200)
        json = JSON.parse(response.body);
        keys = %w(id username display_name biography slides_count)
        keys.each do |k|
          expect(json.key?(k)).to eq(true)
        end
      end
    end
  end
end
