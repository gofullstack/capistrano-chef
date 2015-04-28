require_relative '../../spec_helper'
require 'chef/knife'
require 'chef/node'
require 'chef/search/query'
require 'capistrano/dsl/chef'

describe Capistrano::DSL::Chef do
  let(:cap) { Class.new { extend Capistrano::DSL::Chef } }
  context 'search without args' do
    before do
      @role_name = :app
      @user = 'test_user'
      @search_str = 'roles:test_search_role'

      # server_1 = double('nodes', ipaddress: '1.1.1.1')
      server_1 = { 'ipaddress' => '1.1.1.1' }

      expect(cap).to receive(:fetch).with(:user).and_return(@user)
      expect(Chef::Search::Query).to receive_message_chain(:new, :search).with(
        :node,
        @search_str
      ).and_return([[server_1]])
    end

    it 'gets a list of node ips' do
      expect(cap).to receive(:role).with([@role_name], ["#{@user}@1.1.1.1"])
      cap.chef_role(@role_name, @search_str)
    end
  end
end
