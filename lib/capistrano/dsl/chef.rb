module Capistrano
  module DSL
    # Module implemetns chef-search for capistrano
    module Chef
      def chef_role(name, query = '*:*', options = {})
        arg = options.delete(:attribute) || :ipaddress

        search_proc = choose_proc(arg)

        hosts = chef_search(query).map(&search_proc)

        name = [name] unless name.is_a?(Array)

        user = fetch(:user)

        add_proc = options.delete(:add_proc) || proc do |role_name, all_hosts, ssh_user|
          role(role_name, all_hosts.map { |host| "#{ssh_user ? "#{ssh_user}@" : ''}#{host}" })
        end
        name.each { |n| add_proc.call(n, hosts, user) }
      end

      private

      # method kept as is for upstream compatibility
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def choose_proc(arg)
        case arg
        when Proc
          arg
        when Hash
          iface = arg.keys.first.to_s
          family = arg.values.first.to_s
          proc do |n|
            addresses = n['network']['interfaces'][iface]['addresses']
            addresses.select { |_address, data| data['family'] == family }.to_a.first.first
          end
        when Symbol, String
          proc { |n| n[arg.to_s] }
        else
          fail ArgumentError, 'Search arguments must be Proc, Hash, Symbol, String.'
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def chef_search(query)
        Module.const_get(:Chef)::Search::Query.new.search(:node, query)[0].compact
      end
    end
  end
end
