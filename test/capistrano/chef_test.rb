require 'minitest_helper'
require 'capistrano/chef'

# HACK until this DSL is scoped within a task
$extended_modules = (class << self; self end).included_modules

class Capistrano::ChefTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Capistrano::Chef::VERSION
  end

  def test_it_does_something_useful
    assert_includes $extended_modules, ::Capistrano::DSL::Chef
  end
end
