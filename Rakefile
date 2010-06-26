# Tests are placed into *.task files in the tasks/ directory since
# the Rakefile was getting quite large and intimidating to approach.
tasks = %W[jeweler test yard rcov]
tasks.each do |task|
  load File.expand_path(File.join(File.dirname(__FILE__), "tasks", "#{task}.task"))
end
