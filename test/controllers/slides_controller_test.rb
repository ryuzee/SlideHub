require 'test_helper'
require 'factory_girl_rails'

class SlidesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    Rails.cache.clear
  end

  def teardown
    Rails.cache.clear
  end

  def login
    @request.env['devise.mapping'] = Devise.mappings[:admin]
    sign_in FactoryGirl.create(:admin)
  end

  def logout
    @request.env['devise.mapping'] = Devise.mappings[:admin]
    sign_out FactoryGirl.create(:admin)
  end

  def custom_setting
    CustomSetting['site.display_login_link'] = '1'
    CustomSetting['site.only_admin_can_upload'] = '0'
    CustomSetting['site.signup_enabled'] = '1'
    CustomSetting['custom_content.center_top'] = ''
    CustomSetting['custom_content.center_bottom'] = ''
    CustomSetting['custom_content.right_top'] = ''
  end

  test 'should get index' do
    self.logout
    self.custom_setting
    get :index
    assert_response :success
    assert_no_match 'Admin Dashboard', response.body
    assert_match 'Signup', response.body
    assert_match 'Signin', response.body
    assert_no_match 'My Account', response.body
    assert_no_match 'Logout', response.body
  end

  test 'should get index with loggedin user' do
    self.login
    get :index
    assert_response :success
    assert_match 'Admin Dashboard', response.body
    assert_match 'My Account', response.body
    assert_match 'Logout', response.body
  end

  test 'should get popular' do
    get :popular
    assert_response :success
    assert_match 'Popular Slides', response.body
  end

  test 'should get latest' do
    get :latest
    assert_response :success
    assert_match 'Latest Slides', response.body
  end

  test 'should get search' do
    get :search
    assert_response :success
    assert_match 'Search Slides', response.body
  end
end
