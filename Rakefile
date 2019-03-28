#require "bundler/gem_tasks"
#require "require_all"
#task :default => :spec

#def reload!
#  load_all "./config" if Dir.exists?("./config")
#  load_all "./app" if Dir.exists?("./app")
  #load_all "./lib" if Dir.exists?("./lib")

#  load_all "./*.rb" if Dir.entries(".").include?(/\.rb/)
#end

#task :console do
#  puts "Loading your application environment..."
#  reload!
#  puts "Console started:"
#  Pry.start
#end
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "./config/environment.rb"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
