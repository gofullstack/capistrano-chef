require 'minitest_helper'

class Capistrano::DSL::ChefTest < Minitest::Test

  include Capistrano::Chef::TestHelpers

  def test_chef_role
    user = "jimbo"
    hostname = "10.1.2.3"

    set :user, user
    stub_node :test_node_1 do |node|
      node.normal.ipaddress = hostname
    end

    chef_role :cachey, "name:test_node_1"

    servers_with_role :cachey do |server|
      assert_equal user,     server.user
      assert_equal hostname, server.hostname
    end
  end

  def test_chef_role_block
    user = "duder"
    hostname = "129.1.2.3"

    set :user, user
    stub_node :test_node_2 do |node|
      node.normal.ipaddress = "88.1.2.3"
      node.normal.network.interfaces.eth0.addresses[hostname].family = "inet"
    end

    chef_role :webbie, "name:test_node_2" do |node|
      node["network"]["interfaces"]["eth0"]["addresses"].map do |ipaddress, address|
        next ipaddress if address.family == "inet"
      end
    end

    servers_with_role :webbie do |server|
      assert_equal user,     server.user
      assert_equal hostname, server.hostname
    end
  end

end
