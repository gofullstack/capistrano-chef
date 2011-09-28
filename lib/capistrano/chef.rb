require 'chef/knife'
require 'chef/search/query'

Capistrano::Configuration.instance.load do
  Chef::Knife.new.configure_chef

  # Define a role for capistrano, but instead of a list of addresses, use a chef
  # query to search nodes.
  def chef_role(name, query = "*:*", options = {})
    # TODO: This can only get a node's top-level attributes. Make it get nested
    # ones.
    attr = options.delete(:attribute) || :ipaddress
    nodes = Chef::Search::Query.new.search(:node, query)[0].map {|n| n[attr] }
    role name, *nodes, options
    nodes
  end
end
