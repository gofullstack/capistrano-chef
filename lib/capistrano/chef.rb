require 'capistrano'
require 'chef/knife'
require 'chef/search/query'

module Capistrano::Chef
  # Do a search on the Chef server and return an attary of the requested
  # matching attributes
  def self.search_chef_nodes(query = '*:*', options = {})
    # TODO: This can only get a node's top-level attributes. Make it get nested
    # ones.
    attr = options.delete(:attribute) || :ipaddress
    Chef::Search::Query.new.search(:node, query)[0].map {|n| n[attr] }
  end

  # Load into Capistrano
  def self.load_into(configuration)
    Chef::Knife.new.configure_chef
    configuration.set :capistrano_chef, self
    configuration.load do
      def chef_role(name, query = '*:*', options = {})
        role name, *capistrano_chef.search_chef_nodes(query), options
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Chef.load_into(Capistrano::Confiruation.instance)
end
