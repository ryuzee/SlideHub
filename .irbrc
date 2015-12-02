if defined? Rails::Console
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  if defined? Hirb
    Hirb.enable
  end
end
