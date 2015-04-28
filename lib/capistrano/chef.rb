require 'chef/knife'
require 'chef/node'
require 'chef/search/query'
require 'capistrano/dsl/chef'

knife = Chef::Knife.new
# If you don't do this it gets thrown into debug mode
knife.configure_chef

self.extend Capistrano::DSL::Chef

