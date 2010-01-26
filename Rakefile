begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "virtualbox"
    gemspec.summary = "Create and modify virtual machines in VirtualBox using pure ruby."
    gemspec.description = "Create and modify virtual machines in VirtualBox using pure ruby."
    gemspec.email = "mitchell.hashimoto@gmail.com"
    gemspec.homepage = "http://github.com/mitchellh/virtualbox"
    gemspec.authors = ["Mitchell Hashimoto"]
    gemspec.executables = []
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

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.libs << "test"
    t.test_files = FileList["test/**/*_test.rb"]
    t.output_dir = "test/coverage"
    t.verbose = true
  end
rescue LoadError
  puts "Rcov not available. Coverage data tasks not available."
  puts "Install it with: gem install rcov"
end