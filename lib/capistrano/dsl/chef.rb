module Capistrano
  module DSL
    module Chef
      #
      # When module is included, provide a way to override the Chef query class
      # dependency.
      #
      def self.included(klass)
        klass.send :attr_writer, :chef_query_class
      end

      #
      # Set a Capistrano roles by searching a Chef Server for appropriate node
      # data
      #
      # @param name [String, Symbol, Array<String, Symbol>] roles to set
      # @param query [String] query for searching a chef server
      # @param options [Hash] optional role and search criteria
      # @param block [Proc] block used to filter search result nodes
      # @return [Array<Hash>] map of hashes of user and host pairs by role name
      #
      def chef_role(name, query='*:*', options={}, &block)
        attribute = options.delete(:attribute) || :ipaddress
        results_proc = block_given? ? block : results_by(attribute)
        user  = fetch(:user)
        hosts = chef_search(query).flat_map(&results_proc)

        Array(name).flat_map do |name|
          hosts.map do |host|
            user = [user, host].compact.join("@")
            role name, user, options
            next({ name => [user, host] })
          end
        end
      end

      #
      # Query a Chef Server to search for specific nodes
      #
      # @param [String] query string
      # @return [Array<Chef::Node>] list of node results found
      #
      def chef_search(query)
        chef_query_class.new.search(:node, query).first
      end

      private

      #
      # Interface dependency using Chef for searching by default
      #
      def chef_query_class
        @chef_query_class ||= ::Chef::Search::Query
      end

      #
      # Query a Chef Server to search for specific nodes
      #
      def results_by(attribute)
        case attribute
        when Symbol, String
          lambda { |node| node[attribute] }
        when Hash # not tested
          iface, family = attribute.keys.first.to_s, attribute.values.first.to_s
          lambda do |nodes|
            addresses = node["network"]["interfaces"][iface]["addresses"]
            addresses.select do |address, data|
              data["family"] == family
            end.to_a.first.first
          end
        else
          Proc.new {} # noop
        end
      end
    end
  end
end

