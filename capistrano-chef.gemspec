# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capistrano/chef/version"

Gem::Specification.new do |s|
  s.name        = "capistrano-chef"
  s.version     = Capistrano::Chef::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ['Ryan Oblak', 'Justin Reagor']
  s.email       = ['rroblak@gmail.com', 'cheapRoc@gmail.com']
  s.homepage    = "https://github.com/cheapRoc/capistrano-chef"
  s.summary     = %q{Capistrano 3 extensions for Chef integration}
  s.description = %q{Allows Capistrano to use Chef data for deployment}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "capistrano", "~> 3.2.1"
  s.add_dependency "chef",       "~> 11.12.8"

  s.add_development_dependency "bundler", "~> 1.6"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "chef-zero"
end

