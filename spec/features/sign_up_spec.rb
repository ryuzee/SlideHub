require 'rails_helper'
RSpec.feature 'Sign Up', :devise do
  scenario 'visitor can sign up with valid email and password' do
    sign_up_with('test@example.com', 'password', 'password', 'testuser', 'testuser', 'bio')

    txts = [I18n.t('devise.registrations.signed_up'),
            I18n.t('devise.registrations.signed_up_but_unconfirmed')]
    expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
  end

  scenario 'visitor cannot sign up with invalid email address' do
    sign_up_with('email', 'password', 'password', 'testuser', 'testuser', 'bio')

    expect(page).to have_content('error prohibited this user from being saved')
  end

  scenario 'visitor cannot sign up without password' do
    sign_up_with('test@example.com', '', '', 'testuser', 'testuser', 'bio')

    expect(page).to have_content("Password can't be blank")
  end

  scenario 'visitor cannot sign up with a short password' do
    sign_up_with('test@example.com', '1234', '1234', 'testuser', 'testuser', 'bio')

    expect(page).to have_content('Password is too short (minimum is 8 characters)')
  end

  scenario 'visitor cannot sign up without password confirmation' do
    sign_up_with('test@example.com', 'password', '', 'testuser', 'testuser', 'bio')

    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  scenario 'visitor cannot sign up with mismatched password and confirmation' do
    sign_up_with('test@example.com', 'password', 'mismatch', 'testuser', 'testuser', 'bio')

    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  scenario 'visitor cannot sign up without username' do
    sign_up_with('test@example.com', 'password', 'password', '', 'testuser', 'bio')

    expect(page).to have_content('prohibited this user from being saved')
  end

  scenario 'visitor cannot sign up without display_name' do
    sign_up_with('test@example.com', 'password', 'password', 'testuser', '', 'bio')

    expect(page).to have_content('prohibited this user from being saved')
  end

  scenario 'visitor cannot sign up without biography' do
    sign_up_with('test@example.com', 'password', 'password', 'testuser', 'testuser', '')

    expect(page).to have_content('prohibited this user from being saved')
  end
end
