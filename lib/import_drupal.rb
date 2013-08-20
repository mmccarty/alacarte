#!/usr/bin/env ruby
require File.expand_path('../../config/environment', __FILE__)

owner = User.first

nodes = YAML.load_file '/Users/eric/src/spew/drupal.yml'
nodes.each do |node|
  mod = MiscellaneousResource.create module_title: node['title'], content: node['body']
  owner.create_and_add_resource mod
end
