require 'rails'

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

  task :update_number_of_pages => :environment do
    @slides = Slide.published
    @slides.each do |s|
      page_list = s.page_list
      if page_list.instance_of?(Array)
        count = page_list.count
      else
        count = 0
      end
      puts "id=#{s.id} key=#{s.key}"
      s.num_of_pages = count
      s.save
    end
  end
end
