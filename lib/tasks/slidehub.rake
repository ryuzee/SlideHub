require 'rails'

namespace :slidehub do
  desc 'Confirm that current database includes "schema_migration" table that has been used by CakePHP.'
  task :db_compatibility_check => :environment do
    if ActiveRecord::Base.connection.table_exists?('schema_migrations') && ActiveRecord::Base.connection.column_exists?('schema_migrations', 'type')
      ActiveRecord::Base.connection.execute('rename table schema_migrations to cakephp_schema_migrations')
    end
  end

  desc 'Proceed database migration with database compatibility checking.'
  task :install => :environment do
    Rake::Task['slidehub:db_compatibility_check'].invoke
    Rake::Task['db:migrate'].invoke
  end

  desc 'Update the page count for each slides'
  task :update_number_of_pages => :environment do
    @slides = Slide.where('convert_status = ?', Slide.convert_statuses[:converted])
    @slides.each do |s|
      page_list = s.page_list
      count = if page_list.instance_of?(Array)
                page_list.count
              else
                0
              end
      puts "id=#{s.id} key=#{s.key}"
      s.num_of_pages = count
      s.save
    end
  end
end
