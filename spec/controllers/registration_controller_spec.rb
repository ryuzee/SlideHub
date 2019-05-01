# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(32)       not null
#  display_name           :string(128)      not null
#  password               :string(255)      default(""), not null
#  admin                  :boolean          default(FALSE), not null
#  disabled               :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime
#  biography              :text(65535)
#  slides_count           :integer          default(0)
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  avatar_file_name       :string(255)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#

require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  describe '#new' do
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

    context 'with sign_up disabled' do
      render_views
      it 'does not show the signup form and shows 404 page' do
        begin
          ApplicationSetting['site.signup_enabled'] = '0'
          expect { get :new }.to raise_error(ActionController::RoutingError, 'Not Found')
        ensure
          ApplicationSetting['site.signup_enabled'] = '1'
        end
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
