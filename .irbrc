if defined? Rails::Console
  ActiveRecord::Base.logger = Logger.new($stdout)

  if defined? Hirb
    Hirb.enable
  end
end
