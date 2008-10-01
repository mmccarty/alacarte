# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  #adding gems path
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
     File.directory?(lib = "#{dir}/lib") ? lib : dir
  end
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
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

#Config module types. Uncommit the lines to add more modules.
#General Install. 
MODULE_TYPES_ARRAY = ['Comments' ,'Course Assignment', 'Course Widget',  'Custom Content', 'Instructor Profile', 'Librarian Profile', 'Plagiarism Information', 'Recommendations', 'RSS Feeds',   'Style Guides'] 

#Just database - see install instructions before uncommiting the next line. 
#MODULE_TYPES_ARRAY = MODULE_TYPES_ARRAY + ['Databases']

#full feature - see install instructions before uncommiting the next line. 
#MODULE_TYPES_ARRAY = MODULE_TYPES_ARRAY + ['Course Reserves', 'LibraryFind Search', 'Databases']


#config the mailer. add your domain without the http or www
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "localhost",
  :port => 25,
  :domain => "your.domain.edu"
} 

#recaptcha variables
RCC_PUB = "YOUR RECAPTCH PUBLIC KEY"
RCC_PRIV= "YOUR RECAPTCH PRIVATE KEY"



