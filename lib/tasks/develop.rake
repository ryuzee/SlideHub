namespace :develop do
  root = "#{File.dirname(__FILE__)}/../../"

  desc 'Run rspec on the application container'
  task :rspec do
    Dir.chdir(root) do
      cmd = "docker compose run --rm app bash -l -c 'bundle exec rspec'"
      sh cmd
    end
  end
end
