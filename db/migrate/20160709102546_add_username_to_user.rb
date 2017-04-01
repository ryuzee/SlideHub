class AddUsernameToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :username, :string
    User.find_each do |user|
      self.update_username(user)
    end
    change_column_null :users, :username, false, ''
    add_index :users, :username, unique: true
  end

  def self.update_username(user)
    username = user.email
    username = username.match(/(.+?)@(.+?)/)
    username = username[1]
    say "#{username} was set"
    loop do
      if User.where('username = ?', username).where('id != ?', user.id).count == 0
        execute("update users set username = '#{username}' where id = #{user.id}")
        break
      else
        username = username + '-' + Digest::MD5.hexdigest(SecureRandom.hex + Time.now.strftime('%Y%m%d%H%M%S'))
      end
    end
    true
  end

  def self.down
    remove_column :users, :username
  end
end
