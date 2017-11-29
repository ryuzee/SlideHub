class ChangeColumnTypeOfSettings < ActiveRecord::Migration[5.1]
  def up
    if ActsAsTaggableOn::Utils.using_mysql?
      execute('ALTER TABLE settings MODIFY value longtext CHARACTER SET utf8 COLLATE utf8_bin;')
    end
  end
end
