require 'rails'
require "#{Rails.root}/app/controllers/concerns/sqs_usable"
include SqsUsable
require "#{Rails.root}/app/controllers/concerns/common"
include Common

namespace :ossjob do
  desc 'Handling SQS messages to convert slides...'
  task :handle_slides => :environment do
    Oss::BatchLogger.info('Start convert process')
    resp = receive_message(1)
    if !resp.instance_of?(Array) || resp.count == 0
      Oss::BatchLogger.info('No SQS message found')
    end
    resp.messages.each do |msg|
      obj = JSON.parse(msg.body)
      Oss::BatchLogger.info("Start converting slide. id=#{obj['id']} key=#{obj['key']}")
      result = convert_slide(obj['key'])
      if result
        Oss::BatchLogger.info("Delete message from SQS. id=#{obj['id']} key=#{obj['key']}")
        delete_message(msg)
      else
        Oss::BatchLogger.error("Slide conversion failed. id=#{obj['id']} key=#{obj['key']}")
      end
    end
  end

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
