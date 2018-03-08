# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hotdogprincess/version'

Gem::Specification.new do |spec|
  spec.authors = ['Matthew Callis']
  spec.email = ['matthew.callis@gmail.com']

  spec.name = 'hotdogprincess'
  spec.description = %q{Integrate with the Parature API.}
  spec.summary = "Integrate with the Parature API. It's gunna be so flippin' awesome!"
  spec.homepage = 'https://github.com/MatthewCallis/hotdogprincess'

  spec.files = %w(LICENSE.md README.md Rakefile hotdogprincess.gemspec)
  spec.files += Dir.glob("lib/**/*.rb")
  spec.licenses = ['MIT']

  spec.add_development_dependency 'bundler', '~> 1.0'

  spec.add_runtime_dependency 'gyoku', '~> 1'
  spec.add_runtime_dependency 'nori', '~> 2'
  spec.add_runtime_dependency 'rest-client', '~> 2'

  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 1.9.2'
  spec.required_rubygems_version = '>= 1.3.5'

  spec.version = HotDogPrincess::VERSION.dup
end
