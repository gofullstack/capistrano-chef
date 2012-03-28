require 'spec_helper'
require 'capistrano/chef'

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

    # Data bag item
    @item = mock('Chef::DataBagItem')
    Chef::DataBagItem.stub(:load).and_return @item
    @item.stub(:raw_data).and_return Mash.new({
      :id        => 'test',
      :deploy_to => '/dev/null'
    })
  end

  it 'should be a module' do
    expect { described_class.to be_a Module }
  end

  specify 'search_chef_nodes' do
    Chef::Knife.new.configure_chef
    @search = mock('Chef::Search::Query')
    Chef::Search::Query.stub!(:new).and_return(@search)
    @search.stub!(:search).and_return([[{ :ipaddress => '10.0.0.2' }], 0, 1])
    Capistrano::Chef.search_chef_nodes('*:*').should eql ['10.0.0.2']
  end

  specify 'get_apps_data_bag_item' do
    Capistrano::Chef.get_apps_data_bag_item('test').should === Mash.new({
      :id        => 'test',
      :deploy_to => '/dev/null'
    })
  end

  specify 'set_from_data_bag' do
    expect { @configuration.set_from_data_bag }.to raise_error
    @configuration.set(:application, 'test')
    @configuration.set_from_data_bag
    @configuration.fetch(:deploy_to).should === '/dev/null'
    @configuration.fetch(:id).should === 'test'
  end

  specify 'chef_role' do
    Capistrano::Chef.stub!(:search_chef_nodes).and_return(['10.0.0.2'])
    @search = mock('Chef::Search::Query')
    @configuration.should respond_to :chef_role

    @configuration.chef_role(:test)
    @configuration.roles.should have_key :test
    @configuration.roles[:test].to_a[0].host.should === '10.0.0.2'
  end
end
