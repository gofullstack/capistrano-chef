require 'spec_helper'
require 'capistrano/chef'

MOCK_NODE_DATA = [{
  "ipaddress" => '10.0.0.2',
  "fqdn" => 'localhost.localdomain',
  "hostname" => 'localhost',
  "network" => {
    "default_interface" => "eth0",
    "interfaces" => {
      "eth0" => {
        "addresses" => {
          "fe80::a00:27ff:feca:ab08" => {"scope" => "Link", "prefixlen" => "64", "family" => "inet6"},
          "10.0.0.2" => {"netmask" => "255.255.255.0", "broadcast" => "10.0.0.255", "family" => "inet"},
          "08:00:27:CA:AB:08" => {"family" => "lladdr"}
        },
      },
      "lo" => {
        "addresses" => {
          "::1" => {"scope" => "Node", "prefixlen" => "128", "family" => "inet6"},
          "127.0.0.1" => {"netmask" => "255.0.0.0", "family" => "inet"}
        },
      },
      "eth1" => {
        "addresses" => {
          "fe80::a00:27ff:fe79:83fc" => {"scope" => "Link", "prefixlen" => "64", "family" => "inet6"},
          "192.168.77.101" => {"netmask" => "255.255.255.0", "broadcast" => "192.168.77.255", "family" => "inet"},
          "08:00:27:79:83:FC" => {"family" => "lladdr"}
        },
      },
    },
  }
}]

describe Capistrano::Chef do
  before do
    # Stub knife config
    @knife = mock('Chef::Knife')
    Chef::Knife.stub!(:new).and_return(@knife)
    @knife.stub!(:configure_chef)
    @knife.stub!(:config=)

    # Load into capistrano configuration
    @configuration = Capistrano::Configuration.new
    Capistrano::Chef.load_into(@configuration)

    # Data bag items
    @other_item = mock('Chef::DataBagItem')
    Chef::DataBagItem.stub(:load).with(:other_data_bag, 'other_test').and_return @other_item
    @other_item.stub(:raw_data).and_return Mash.new({
      :id        => 'other_test',
      :deploy_to => '/dev/other_null'
    })

    @item = mock('Chef::DataBagItem')
    Chef::DataBagItem.stub(:load).with(:apps, 'test').and_return @item
    @item.stub(:raw_data).and_return Mash.new({
      :id        => 'test',
      :deploy_to => '/dev/null'
    })
  end

  it 'should be a module' do
    expect { described_class.to be_a Module }
  end

  describe 'search_chef_nodes' do
    before(:each) do
      Chef::Knife.new.configure_chef
      @search = mock('Chef::Search::Query')
      Chef::Search::Query.stub!(:new).and_return(@search)
      @search.stub!(:search).and_return([::MOCK_NODE_DATA, 0, 1])
    end

    specify 'without argument (will get :ipaddress)' do
      Capistrano::Chef.search_chef_nodes('*:*').should eql ['10.0.0.2']
    end

    # with Symbol(or String) will search top-level attributes
    specify 'with Symbol argument' do
      Capistrano::Chef.search_chef_nodes('*:*', :fqdn).should eql ['localhost.localdomain']
    end

    # with Hash, can specify "interface" and "family" by key and value.
    specify 'with Hash argument' do
      Capistrano::Chef.search_chef_nodes('*:*', {:eth0 => :inet}).should eql ['10.0.0.2']
    end

    # use Proc for more deep, complex attributes search.
    specify 'with Proc argument' do
      search_proc = Proc.new do |n|
        n["network"]["interfaces"]["eth1"]["addresses"].select{|address, data| data["family"] == "inet" }.to_a.first.first
      end
      Capistrano::Chef.search_chef_nodes('*:*', search_proc).should eql ['192.168.77.101']
    end
  end


  specify 'get_data_bag_item' do
    Capistrano::Chef.get_data_bag_item('test').should === Mash.new({
      :id        => 'test',
      :deploy_to => '/dev/null'
    })
    Capistrano::Chef.get_data_bag_item('other_test', :other_data_bag).should === Mash.new({
      :id        => 'other_test',
      :deploy_to => '/dev/other_null'
    })
  end

  specify 'set_from_data_bag' do
    expect { @configuration.set_from_data_bag }.to raise_error
    @configuration.set(:application, 'test')
    @configuration.set_from_data_bag
    @configuration.fetch(:deploy_to).should === '/dev/null'
    @configuration.fetch(:id).should === 'test'

    @configuration.set(:application, 'other_test')
    @configuration.set_from_data_bag :other_data_bag
    @configuration.fetch(:deploy_to).should === '/dev/other_null'
    @configuration.fetch(:id).should === 'other_test'
  end

  describe '#chef_role' do
    it 'add nodes to the role' do
      Capistrano::Chef.stub!(:search_chef_nodes).and_return(['10.0.0.2'])
      @search = mock('Chef::Search::Query')
      @configuration.should respond_to :chef_role

      @configuration.chef_role(:test)
      @configuration.roles.should have_key :test
      @configuration.roles[:test].to_a[0].host.should === '10.0.0.2'
    end

    it 'defaults to calling search with :ipaddress as the attribute and 1000 as the limit when giving a query' do
      query = "this is my chef query"
      Capistrano::Chef.should_receive(:search_chef_nodes).with(query, :ipaddress, 1000).and_return(['10.0.0.2'])
      @configuration.chef_role(:test, query)
    end

    it 'allows you to specify the attribute used in the query' do
      query = "this is my chef query"
      attribute = :my_attr
      Capistrano::Chef.should_receive(:search_chef_nodes).with(query, attribute, 1000).and_return(['10.0.0.2'])
      @configuration.chef_role(:test, query, :attribute => attribute)
    end

    it 'allows you to specify the limit used in the query' do
      query = "this is my chef query"
      limit = 55
      Capistrano::Chef.should_receive(:search_chef_nodes).with(query, :ipaddress, limit).and_return(['10.0.0.2'])
      @configuration.chef_role(:test, query, :limit => limit)
    end
  end
end
