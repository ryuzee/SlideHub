namespace :develop do
  root = "#{File.dirname(__FILE__)}/../../"

  desc 'Run rspec on the application container'
  task :rspec do
    Dir.chdir(root) do
      cmd = "docker-compose run app bash -l -c 'bundle exec rspec'"
      sh cmd
    end
  end

  desc 'Generate ER diagram on the application container'
  task :erd do
    Dir.chdir(root) do
      cmd = "docker-compose run app bash -l -c 'cd docs && bundle exec erd ..'"
      sh cmd
    end
  end
end
