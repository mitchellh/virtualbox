require "rubygems"
require "bundler/setup"
Bundler::GemHelper.install_tasks

# Tests are placed into *.task files in the tasks/ directory since
# the Rakefile was getting quite large and intimidating to approach.
Dir[File.join(File.dirname(__FILE__), "tasks", "**", "*.task")].each do |f|
  load f
end
