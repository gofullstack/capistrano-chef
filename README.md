# Capistrano Chef

[![Build Status](https://secure.travis-ci.org/cramerdev/capistrano-chef.png?branch=master)](http://travis-ci.org/cramerdev/capistrano-chef)

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
    chef_role :db, 'roles:database_master', :primary => true,
                                            :attribute => :private_ip

This defines the same roles using Chef's [search feature](http://wiki.opscode.com/display/chef/Search). Nodes are searched using the given query. The node's `ipaddress` attribute is used by default, but another (top-level) attribute can be specified in the options. The rest of the options are the same as those used by Capistrano.

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
