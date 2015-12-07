require 'rails'
require "#{Rails.root}/app/controllers/concerns/sqs_usable"
include SqsUsable
require "#{Rails.root}/app/controllers/concerns/common"
include Common

namespace :ossjob do
  task :db_compatibility_check => :environment do
    if ActiveRecord::Base.connection.table_exists?('schema_migrations') && ActiveRecord::Base.connection.column_exists?('schema_migrations', 'type')
      ActiveRecord::Base.connection.execute('rename table schema_migrations to cakephp_schema_migrations')
    end
  end

  task :install => :environment do
    Rake::Task['ossjob:db_compatibility_check'].invoke
    Rake::Task['db:migrate'].invoke
  end
end
