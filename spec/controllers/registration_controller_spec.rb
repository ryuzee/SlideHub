require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  describe 'sign-up page' do
    before(:each) do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'with sign_up enabled' do
      render_views
      it 'shows the signup form' do
        ApplicationSetting['site.signup_enabled'] = '1'
        get :new
        expect(response.status).to eq(200)
        expect(response.body).to include('username', 'biography')
      end
    end

    context 'after signing in with X for the first time' do
      render_views
      let(:from_x) do
        { 'provider' => 'twitter', 'uid' => '987654', 'username' => 'newcomer', 'display_name' => 'New Comer',
          'biography' => 'Hello', 'email' => '', 'twitter_account' => 'newcomer' }
      end

      before do
        ApplicationSetting['site.signup_enabled'] = '1'
        session['devise.user_attributes'] = from_x
      end

      it 'explains what to fill in, instead of showing the sign-in buttons and an error' do
        get :new
        html = Nokogiri::HTML(response.body)
        expect(html.at('.sh-auth-notice').text).to eq(I18n.t(:signup_with_provider, provider: 'Twitter'))
        expect(html.at('.sh-auth-providers')).to be_nil
        expect(html.at('.sh-auth-divider')).to be_nil
        expect(html.at('.alert-danger')).to be_nil
        expect(html.at('input[name="user[username]"]')['value']).to eq('newcomer')
        expect(html.at('input[name="user[password]"]')).to be_nil
      end

      it 'shows what is still missing after the form is sent' do
        post :create, params: { user: { email: '', username: 'newcomer', display_name: 'New Comer', biography: 'Hello' } }
        html = Nokogiri::HTML(response.body)
        expect(html.at('.sh-auth-notice')).not_to be_nil
        expect(html.at('.alert-danger')).not_to be_nil
      end

      it 'creates the account linked to X when the e-mail address is filled in' do
        expect do
          post :create, params: { user: { email: 'newcomer@example.com', username: 'newcomer', display_name: 'New Comer', biography: 'Hello' } }
        end.to change(User, :count).by(1)
        expect(User.find_by(email: 'newcomer@example.com')).to have_attributes(provider: 'twitter', uid: '987654')
      end
    end

    context 'when opened directly' do
      render_views
      it 'shows the sign-in buttons of the external services' do
        ApplicationSetting['site.signup_enabled'] = '1'
        get :new
        html = Nokogiri::HTML(response.body)
        expect(html.at('.sh-auth-providers')).not_to be_nil
        expect(html.at('.sh-auth-notice')).to be_nil
      end
    end

    context 'with sign_up disabled' do
      render_views
      it 'does not show the signup form and shows 404 page' do
        ApplicationSetting['site.signup_enabled'] = '0'
        expect { get :new }.to raise_error(ActionController::RoutingError, 'Not Found')
      ensure
        ApplicationSetting['site.signup_enabled'] = '1'
      end
    end
  end

  describe '#update' do
    let!(:default_user) { create(:default_user) }
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in default_user
    end

    it 'changes attributes for the user who logs in the app via email/password' do
      put :update, params: { user: { email: 'user01new@example.com', biography: 'test', current_password: default_user.password } }
      subject.current_user.reload
      expect(assigns[:user]).not_to eq(be_new_record)
      expect(subject.current_user.email).to eq 'user01new@example.com'
      expect(subject.current_user.biography).to eq 'test'
    end

    it 'does not change user attributes because of lack of current_password' do
      put :update, params: { user: { email: 'user01new@example.com', biography: 'test' } }
      subject.current_user.reload
      expect(assigns[:user]).not_to eq(be_new_record)
      expect(subject.current_user.email).to eq 'user01@example.com'
      expect(subject.current_user.biography).to eq 'Bio'
    end
  end

  describe '#update (Facebook Login)' do
    let!(:default_user) { create(:default_user, provider: 'facebook') }
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in default_user
    end

    it 'changes user attributes' do
      put :update, params: { user: { email: 'user01new@example.com', biography: 'test' } }
      subject.current_user.reload
      expect(assigns[:user]).not_to eq(be_new_record)
      expect(subject.current_user.email).to eq 'user01new@example.com'
      expect(subject.current_user.biography).to eq 'test'
    end
  end
end
