desc 'generate all model'
task :generate_model do
  %w[user slide category tag config comment custom_content].each do |m|
    system("bundle exec rails g model #{m} --migration=false")
  end
end

desc 'generate all controller'
task :generate_controller do
  %w[users slides categories].each do |c|
    system("bundle exec rails g controller #{c}")
  end
end
