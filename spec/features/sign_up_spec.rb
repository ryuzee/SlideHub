require 'rails_helper'
RSpec.feature 'Sign Up', :devise do
  scenario 'visitor can sign up with valid email and password' do
    sign_up_with(email: 'test@example.com', password: 'password', confirmation: 'password', username: 'testuser', display_name: 'testuser', biography: 'bio')

    txts = [I18n.t('devise.registrations.signed_up'),
            I18n.t('devise.registrations.signed_up_but_unconfirmed')]
    expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
  end

  scenario 'visitor cannot sign up with invalid email address' do
    sign_up_with(email: 'email', password: 'password', confirmation: 'password', username: 'testuser', display_name: 'testuser', biography: 'bio')

    expect(page).to have_content('Email is invalid')
  end

  scenario 'visitor cannot sign up without password' do
    sign_up_with(email: 'test@example.com', password: '', confirmation: '', username: 'testuser', display_name: 'testuser', biography: 'bio')

    expect(page).to have_content("Password can't be blank")
  end

  scenario 'visitor cannot sign up with a short password' do
    sign_up_with(email: 'test@example.com', password: '1234', confirmation: '1234', username: 'testuser', display_name: 'testuser', biography: 'bio')

    expect(page).to have_content('Password is too short (minimum is 8 characters)')
  end

  scenario 'visitor cannot sign up without password confirmation' do
    sign_up_with(email: 'test@example.com', password: 'password', confirmation: '', username: 'testuser', display_name: 'testuser', biography: 'bio')

    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  scenario 'visitor cannot sign up with mismatched password and confirmation' do
    sign_up_with(email: 'test@example.com', password: 'password', confirmation: 'mismatch', username: 'testuser', display_name: 'testuser', biography: 'bio')

    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  scenario 'visitor cannot sign up without username' do
    sign_up_with(email: 'test@example.com', password: 'password', confirmation: 'password', username: '', display_name: 'testuser', biography: 'bio')

    expect(page).to have_content('Username is too short')
  end

  scenario 'visitor cannot sign up without display_name' do
    sign_up_with(email: 'test@example.com', password: 'password', confirmation: 'password', username: 'testuser', display_name: '', biography: 'bio')

    expect(page).to have_content("Display Name can't be blank")
  end

  scenario 'visitor cannot sign up without biography' do
    sign_up_with(email: 'test@example.com', password: 'password', confirmation: 'password', username: 'testuser', display_name: 'testuser', biography: '')

    expect(page).to have_content("Biography can't be blank")
  end
end
