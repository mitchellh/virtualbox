begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "virtualbox"
    gemspec.summary = "Manage virtual machines in VirtualBox from Ruby"
    gemspec.description = "Manage virtual machines in VirtualBox from Ruby"
    gemspec.email = "mitchell.hashimoto@gmail.com"
    gemspec.homepage = "http://github.com/mitchellh/virtualbox"
    gemspec.authors = ["Mitchell Hashimoto"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = ['--main', 'Readme.md', '--markup', 'markdown', '--files', 'TODO']
  end
rescue LoadError
  puts "Yard not available. Install it with: gem install yard"
end