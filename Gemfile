source "http://rubygems.org"

# External Dependencies
gem "ffi"

# Gems required for development only.
group :development do
  # Gem and docs
  gem "jeweler"
  gem "yard"

  # Unit tests
  gem "contest", ">= 0.1.2"
  gem "mocha"
  gem "rcov"

  # Integration tests
  gem "cucumber", "~> 0.8.0"
  gem "aruba", "~> 0.1.9"
  gem "rspec"

  # Generally good to have
  gem "ruby-debug", ">= 0.10.3" if RUBY_VERSION < '1.9'
  gem "ruby-debug19", ">= 0.11.6" if RUBY_VERSION >= '1.9'
end
