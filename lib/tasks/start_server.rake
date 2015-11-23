desc 'Start Server'
task :start do
  system('bundle exec rails server -b 0.0.0.0')
end

desc 'Start Development Server'
task :start_dev do
  system('bundle exec rails server -b 0.0.0.0 -e development')
end

desc 'Start Development Console'
task :console_dev do
  system('bundle exec rails console -e development')
end
