module Capistrano
  module DSL
    module Chef
      def chef_role(name, query = '*:*', **options)
        arg = options.delete(:attribute) || :ipaddress

        search_proc = case arg
                      when Proc
                        arg
                      when Hash
                        iface, family = arg.keys.first.to_s, arg.values.first.to_s
                        Proc.new do |n|
                          addresses = n["network"]["interfaces"][iface]["addresses"]
                          addresses.select{|address, data| data["family"] == family }.to_a.first.first
                        end
                      when Symbol, String
                        Proc.new{|n| n[arg.to_s]}
                      else
                        raise ArgumentError, 'Search arguments must be Proc, Hash, Symbol, String.'
                      end

        hosts = chef_search(query).map(&search_proc)

        name = [name] unless name.is_a?(Array)

        user = fetch(:user)

        name.each { |n| role(name, hosts.map { |h| "#{user ? "#{user}@" : ''}#{h}" }) }
      end

      def chef_search(query)
        Module.const_get(:Chef)::Search::Query.new.search(:node, query)[0].compact
      end
    end
  end
end

