require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  describe 'Users' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/users/' do
      it 'lists the users' do
        create(:default_user)
        get 'index'
        expect(response.status).to eq(200)
        expect(response.body).to include('User01', 'user01@example.com')
      end
    end

    describe 'GET /admin/users/ with sorting' do
      it 'sorts by the sign-in count' do
        create(:default_user).update!(sign_in_count: 5)
        create(:another_user).update!(sign_in_count: 9)
        admin_user.update!(sign_in_count: 1)
        get 'index', params: { q: { s: 'sign_in_count desc' } }
        expect(assigns(:users).map(&:sign_in_count)).to eq([9, 5, 1])
      end

      it 'can search by the e-mail address' do
        create(:default_user)
        get 'index', params: { q: { email_cont: 'user01' } }
        expect(assigns(:users).map(&:email)).to eq(['user01@example.com'])
      end
    end

    describe 'GET /admin/users/edit/1' do
      it 'shows the form filled with the current user' do
        target = create(:default_user)
        get 'edit', params: { id: target.id }
        expect(response.status).to eq(200)
        expect(response.body).to include('value="User01"', 'value="user01"')
      end
    end

    describe 'POST /admin/users/update' do
      it 'updates the user' do
        target = create(:default_user)
        post :update, params: { id: target.id, user: { display_name: 'SushiKuitai' } }
        expect(response).to redirect_to admin_users_path
        expect(User.find(target.id).display_name).to eq('SushiKuitai')
      end

      it 'shows the form again and keeps the old name when the name is empty' do
        target = create(:default_user)
        post :update, params: { id: target.id, user: { display_name: '' } }
        expect(response.status).to eq(200)
        expect(response).to render_template :edit
        expect(User.find(target.id).display_name).to eq('User01')
      end
    end

    describe 'POST /admin/users/update (roles and ids)' do
      it 'can make another user an administrator' do
        target = create(:default_user)
        post :update, params: { id: target.id, user: { display_name: target.display_name, admin: '1' } }
        expect(User.find(target.id).admin).to be(true)
        expect(flash[:notice]).to eq(I18n.t(:user_was_updated))
      end

      it 'keeps the administrator role of the user who is signed in' do
        post :update, params: { id: admin_user.id, user: { display_name: admin_user.display_name, admin: '0' } }
        expect(User.find(admin_user.id).admin).to be(true)
        expect(flash[:notice]).to eq(I18n.t(:cannot_remove_own_admin))
      end

      it 'ignores the id sent from the form' do
        target = create(:default_user)
        post :update, params: { id: target.id, user: { id: target.id + 1000, display_name: 'Renamed' } }
        expect(User.find(target.id).display_name).to eq('Renamed')
        expect(User.exists?(target.id + 1000)).to be(false)
      end
    end

    describe 'DELETE /admin/users' do
      it 'deletes the user' do
        target = create(:default_user)
        delete :destroy, params: { id: target.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to admin_users_path
        expect(User.where(id: target.id).count).to eq(0)
      end
    end
  end
end
