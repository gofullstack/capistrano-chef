# Chef For Capistrano 3

A common use-case for applications is to have [Chef](http://www.opscode.com/chef/) configure your systems and use [Capistrano](http://capistranorb.com/) to deploy the applications that run on them.

Capistrano Chef is a Capistrano 3 extension that makes Chef and Capistrano 3 get along like best buds.

Note: this latest version of this gem will not work for Capistrano versions prior to 3.  Please use [version 0.1.0](http://rubygems.org/gems/capistrano-chef/versions/0.1.0) or earlier if you want to use Capistrano Chef with Capistrano 2.

## Roles

The Capistrano configuration has a facility to specify the roles for your application and which servers are members of those roles. Chef has its own roles. If you're using both Chef and Capistrano, you don't want to have to tell them both about which servers you'll be deploying to, especially if they change often.

capistrano-chef provides some helpers to query your Chef server from Capistrano to define these roles.

### Examples

A normal `deploy.rb` in an app using capistrano defines a roles like this:

    role :web, '10.0.0.2', '10.0.0.3'
    role :db, '10.0.0.2', :primary => true

Using capistrano-chef, you can do this:

    require 'capistrano/chef'
    chef_role :web 'role:web'
    chef_role :db, 'role:database_master', :primary   => true,
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

You can also define multiple roles at the same time if the host list is identical. Instead of running multiple searches to the Chef server, you can pass an Array to `chef_role`:

    chef_role [:web, :app], 'roles:web'

## Chef Configuration

A Chef server is expected to be available and [Knife](http://wiki.opscode.com/display/chef/Knife) is used to configure the extension, looking for knife.rb the keys needed in .chef in the current directory or one its parent directories.

If you're using [Opscode Hosted Chef](http://www.opscode.com/hosted-chef/) these files will be provided for you. If not, the configuration can be generated with `knife configure -i`. See the [Chef Documentation](http://wiki.opscode.com/display/chef/Chef+Repository#ChefRepository-Configuration) for more details.

## License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

