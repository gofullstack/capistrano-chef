# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'capistrano/chef/version'

Gem::Specification.new do |s|
  s.name        = 'capistrano-chef'
  s.version     = CapistranoChef::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ['Ryan Oblak']
  s.email       = ['rroblak@gmail.com']
  s.homepage    = 'https://github.com/rroblak/capistrano-chef'
  s.summary     = 'Capistrano 3 extensions for Chef integration'
  s.description = 'Allows Capistrano to use Chef data for deployment'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.add_dependency 'capistrano', '>= 3'
  s.add_dependency 'chef', '>= 0.10.10'
end
