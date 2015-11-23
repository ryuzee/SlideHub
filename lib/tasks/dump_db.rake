desc 'Dump database'
task :dump_db do
  system('bundle exec rake db:schema:dump')
end
