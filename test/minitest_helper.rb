$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'
require 'chef_zero/server'
require 'capistrano/chef'
require 'capistrano/chef/test_case'
