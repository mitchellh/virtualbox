# Gems required for testing only. To install run
# gem bundle test
only :test do
  gem "contest", ">= 0.1.2"
  gem "mocha"
  gem "ruby-debug", ">= 0.10.3" if RUBY_VERSION < '1.9'
  gem "ruby-debug19", ">= 0.11.6" if RUBY_VERSION >= '1.9'
end

# Makes sure that our code doesn't request gems outside
# of our dependency list.
disable_system_gems