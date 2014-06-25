require "sshkit"
require "capistrano/configuration"
require "chef_zero/server"

module Capistrano
  module Chef
    module TestHelpers

      include Capistrano::DSL::Chef

      extend Forwardable

      def_delegators ::Capistrano::Configuration, :env, :reset!

      def setup
        chef_server!
        super
      end

      def teardown
        reset!
        chef_server!
        super
      end

      def chef_server!
        if server.running?
          server.stop
        else
          server.start_background
        end
      end

      def server
        @server ||= ::ChefZero::Server.new \
          port: 8889,
          debug: !!ENV['DEBUG'],
          single_org: false
      end

      def servers
        env.send(:servers)
      end

      def servers_with_role(role)
        servers.map do |server|
          next unless server.properties.roles.include?(role)
          yield server if block_given?
          server
        end
      end

      def nodes
        @nodes ||= {}
      end

      def stub_node(name, &block)
        name = name.to_s || "test_node_#{nodes.keys.size}"
        nodes[name] = ::Chef::Node.build(name).tap(&block)
        data = ::JSON.fast_generate(nodes[name])
        server.load_data({ "nodes" => { name => data }})
        nodes[name]
      end

      def method_missing(name, *args)
        if env.respond_to?(name)
          env.__send__(name, *args)
        else
          super name, *args
        end
      end

    end
  end
end
