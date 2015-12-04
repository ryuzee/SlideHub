class AddInitialUserData < ActiveRecord::Migration
  def up
    if User.count == 0
      User.create(email: 'admin@example.com', password: 'passw0rd', password_confirmation: 'passw0rd', display_name: 'admin', biography: 'Administrator', admin: true)
    end
  end
end
