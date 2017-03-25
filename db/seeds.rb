# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if User.count.zero?
  User.create!(
    email: 'admin@example.com',
    password: 'passw0rd',
    password_confirmation: 'passw0rd',
    display_name: 'admin',
    biography: 'Administrator',
    admin: true,
    username: 'admin-default'
  )
end

if Category.count.zero?
  Category.create([
    { id: 1, name: 'Books' },
    { id: 2, name: 'Business' },
    { id: 3, name: 'Design' },
    { id: 4, name: 'Education' },
    { id: 5, name: 'Entertainment' },
    { id: 6, name: 'Finance' },
    { id: 7, name: 'Games' },
    { id: 8, name: 'Health' },
    { id: 9, name: 'How-to & DIY' },
    { id: 10, name: 'Humor' },
    { id: 11, name: 'Photos' },
    { id: 12, name: 'Programming' },
    { id: 13, name: 'Research' },
    { id: 14, name: 'Science' },
    { id: 15, name: 'Technology' },
    { id: 16, name: 'Travel' },
  ])
end

if CustomSetting.count.zero?
  CustomSetting.create([
    { id: 1, var: 'site.display_login_link', value: '1' },
    { id: 2, var: 'site.only_admin_can_upload', value: '0' },
    { id: 3, var: 'site.signup_enabled', value: '1' },
    { id: 4, var: 'custom_content.center_bottom', value: '' },
    { id: 5, var: 'custom_content.center_top', value: '' },
    { id: 6, var: 'custom_content.right_top', value: '' },
    { id: 7, var: 'site.name', value: 'SlideHub2' }
  ])
end
