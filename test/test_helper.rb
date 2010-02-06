begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

# ruby-debug, not necessary, but useful if we have it
begin
  require 'ruby-debug'
rescue LoadError; end

require 'contest'
require 'mocha'

# The actual library
require File.join(File.dirname(__FILE__), '..', 'lib', 'virtualbox')