# -*- encoding: utf-8 -*-
require File.expand_path("../lib/virtualbox/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = "virtualbox"
  s.version       = VirtualBox::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Mitchell Hashimoto"]
  s.email         = ["mitchell.hashimoto@gmail.com"]
  s.homepage      = "http://github.com/mitchellh/virtualbox"
  s.summary       = "Create and modify virtual machines in VirtualBox using pure ruby"
  s.description   = "Create and modify virtual machines in VirtualBox using pure ruby"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "virtualbox"

  s.add_dependency "ffi", "~> 1.0"
  s.add_development_dependency "contest", "~> 0.1.2"
  s.add_development_dependency "mocha", "~> 0.9.8"

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path  = 'lib'
end

