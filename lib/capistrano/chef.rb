require 'capistrano'
require 'chef/knife'
require 'chef/data_bag_item'
require 'chef/search/query'

module Capistrano::Chef
  # Set up chef configuration
  def self.configure_chef
    knife = Chef::Knife.new
    # If you don't do this it gets thrown into debug mode
    knife.config = { :verbosity => 1 }
    knife.configure_chef
  end

  # Do a search on the Chef server and return an attary of the requested
  # matching attributes
  def self.search_chef_nodes(query = '*:*', options = {})
    # TODO: This can only get a node's top-level attributes. Make it get nested
    # ones.
    attr = options.delete(:attribute) || :ipaddress
    Chef::Search::Query.new.search(:node, query)[0].map {|n| n[attr] }
  end

  def self.get_apps_data_bag_item(id)
    Chef::DataBagItem.load(:apps, id).raw_data
  end

  # Load into Capistrano
  def self.load_into(configuration)
    self.configure_chef
    configuration.set :capistrano_chef, self
    configuration.load do
      def chef_role(name, query = '*:*', options = {})
        role name, *capistrano_chef.search_chef_nodes(query), options
      end

      def set_from_data_bag
        raise ':application must be set' if fetch(:application).nil?
        capistrano_chef.get_apps_data_bag_item(application).each do |k, v|
          set k, v
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Chef.load_into(Capistrano::Configuration.instance)
end
