# Put this in config/application.rb
require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module Alacarte
  class Application < Rails::Application
    config.autoload_paths += [config.root.join('lib')]
    config.encoding = 'utf-8'
    # Settings in config/environments/* take precedence those specified here
    
    # Skip frameworks you're not going to use (only works if using vendor/rails)
    # config.frameworks -= [ :action_web_service, :action_mailer ]
    
    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{RAILS_ROOT}/extras )
    
    # Force all environments to use the same logger level 
    # (by default production uses :info, the others :debug)
     config.log_level = :debug
  
    # Use the database for sessions instead of the file system
    # (create the session table with 'rake db:sessions:create')
     config.action_controller.session_store = :active_record_store
  
    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper, 
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql
  
    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector
  
    # Make Active Record use UTC-base instead of local time
    # config.active_record.default_timezone = :utc
    
    #Set the character set used for new e-mail with
    config.action_mailer.default_charset = "utf-8"

    config.filter_parameters += [:password, :password_confirmation, :onid, :email]
    
    # See Rails::Configuration for more options
  end
end
