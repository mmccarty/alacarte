require File.expand_path('../boot', __FILE__)
require 'rails/all'

if defined?(Bundler)
  Bundler.require(:default, :assets, Rails.env)
end

module Alacarte
  class Application < Rails::Application
    config.autoload_paths += %W(
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
      #{config.root}/lib
    )

    config.time_zone = 'Eastern Time (US & Canada)'
    config.encoding = 'utf-8'

    config.filter_parameters += [:password, :password_confirmation, :onid, :email]

    config.log_level = :debug

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.generators do |g|
      g.test_framework :rspec,
        :fixtures => true,
        :view_specs => false,
        :helper_specs => false,
        :routing_specs => false,
        :controller_specs => true,
        :request_specs => true
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
  end
end
