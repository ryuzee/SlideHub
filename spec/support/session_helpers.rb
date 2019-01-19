module SessionHelpers
  def sign_up_with(email: '', password: '', confirmation: '', username: '', display_name: '', biography: '')
    visit new_user_registration_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: confirmation
    fill_in 'user_username', with: username
    fill_in 'user_display_name', with: display_name
    fill_in 'user_biography', with: biography
    click_button 'Sign up'
  end

  def sign_in(email, password)
    visit new_user_session_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_button 'Log in'
  end
end
