# Capistrano Chef [![Build Status](https://secure.travis-ci.org/cramerdev/capistrano-chef.png?branch=master)](http://travis-ci.org/cramerdev/capistrano-chef)

A common use-case for applications is to have [Chef](http://www.opscode.com/chef/) configure your systems and use [Capistrano](http://capify.org/) to deploy the applications that run on them.

Capistrano Chef is a Capistrano extension that makes Chef and Capistrano get along like best buds.

## Roles

The Capistrano configuration has a facility to specify the roles for your application and which servers are members of those roles. Chef has its own roles. If you're using both Chef and Capistrano, you don't want to have to tell them both about which servers you'll be deploying to, especially if they change often.

capistrano-chef provides some helpers to query your Chef server from Capistrano to define these roles.

### Examples

A normal `deploy.rb` in an app using capistrano defines a roles like this:

    role :web, '10.0.0.2', '10.0.0.3'
    role :db, '10.0.0.2', :primary => true

Using capistrano-chef, you can do this:

    require 'capistrano/chef'
    chef_role :web 'roles:web'
    chef_role :db, 'roles:database_master', :primary   => true,
                                            :attribute => :private_ip,
                                            :limit     => 1

Use a Hash to get a specific network interface:
(the Hash must be in the form of { 'interface-name' => 'network-family-name' })

    chef_role :web, 'roles:web', :attribute => { :eth1 => :inet }

For a more deep and complex attribute search, use a Proc object:

(Example, to get 'eth1.inet.ipaddress': http://wiki.opscode.com/display/chef/Search#Search-SearchonlyreturnsIPAddressoftheNode%2Cnotofaspecificinterface)

    chef_role :web, 'roles:web', :attribute => Proc.new do |n|
      n["network"]["interfaces"]["eth1"]["addresses"].select{|address, data| data["family"] == "inet" }.keys.first
    end

This defines the same roles using Chef's [search feature](http://wiki.opscode.com/display/chef/Search). Nodes are searched using the given query. The node's `ipaddress` attribute is used by default, but other attributes can be specified in the options as shown in the examples above. The rest of the options are the same as those used by Capistrano.

The `limit` attribute of the options hash will make it so only that the given number of items will be returned from a search.

## Data Bags

Chef [Data Bags](http://wiki.opscode.com/display/chef/Data+Bags) let you store arbitrary JSON data. A common pattern is to use an _apps_ data bag to store data about an application for use in configuration and deployment.

Chef also has a [Deploy Resource](http://wiki.opscode.com/display/chef/Deploy+Resource) described in one of their blog posts, [Data Driven Application Deployment with Chef](http://www.opscode.com/blog/2010/05/06/data-driven-application-deployment-with-chef/). This is one method of deploying, but, if you're reading this, you're probably interested in deploying with Capistrano.

If you create an _apps_ data bag item (let's call it _myapp_), Capistrano Chef will let you use the data in your Capistrano recipes with the `set_from_data_bag` method.

This will allow you to store all of your metadata about your app in one place.

### Example

In normal Capistrano `deploy.rb`:

    set :application, 'myapp'
    set :user, 'myapp'
    set :deploy_to, '/var/apps/myapp'
    set :scm, :git
    ... # and so on

With Capistrano Chef, an _apps_ data bag item:

    {
        "id": "myapp",
        "user": "myapp",
        "deploy_to": "/var/apps/myapp",
        "scm": "git",
        ... // and so on
    }

And in the`deploy.rb`:

    set :application, 'myapp'
    set_from_data_bag

If you want to use a data bag other than _apps_, you can do `set_from_data_bag :my_other_data_bag`.

## Chef Configuration

A Chef server is expected to be available and [Knife](http://wiki.opscode.com/display/chef/Knife) is used to configure the extension, looking for knife.rb the keys needed in .chef in the current directory or one its parent directories.

If you're using [Opscode Hosted Chef](http://www.opscode.com/hosted-chef/) these files will be provided for you. If not, the configuration can be generated with `knife configure -i`. See the [Chef Documentation](http://wiki.opscode.com/display/chef/Chef+Repository#ChefRepository-Configuration) for more details.

## Requirements

Tested with Ruby Enterprise Edition 1.8.7, Ruby 1.9.2 and 1.9.3. Should work with Capistrano 2 or greater.

## License

Copyright (c) 2011-2012 Cramer Development, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
