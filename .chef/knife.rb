current_dir = File.dirname(__FILE__)

node_name       "capistrano-chef-test"
client_key      "#{current_dir}/stickywicket.pem"
chef_server_url "http://127.0.0.1:8889"
