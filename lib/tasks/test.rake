=begin
namespace :redmine_banner do
  desc 'Run test for redmine_banner plugin.'
  task :test do |task_name|
    next unless ENV['RAILS_ENV'] == 'test' && task_name.name == 'redmine_banner:test'
  end

  Rake::TestTask.new(:test) do |t|
    t.libs << 'lib'
    t.pattern = 'plugins/redmine_banner/test/**/*_test.rb'
    t.verbose = false
    t.warning = false
  end
end
=end

require 'rake/testtask'

namespace :redmine_banner do
  desc 'Run test for redmine_banner plugin.'
  task :test do |task_name|
    next unless ENV['RAILS_ENV'] == 'test' && task_name.name == 'redmine_banner:test'
  end

  Rake::TestTask.new(:test) do |t|
    t.libs << 'lib'
    t.pattern = 'plugins/redmine_banner/test/**/*_test.rb'
    t.verbose = false
    t.warning = false
  end

  desc 'Run spec for redmine_banner plugin'
  task :spec do |task_name|
    next unless ENV['RAILS_ENV'] == 'test' && task_name.name == 'redmine_banner:spec'
    begin
      require 'rspec/core'
      path = 'plugins/redmine_banner/spec/'
      options = ['-I plugins/redmine_banner/spec']
      options << '--format'
      options << 'documentation'
      options << path
      RSpec::Core::Runner.run(options)
    rescue LoadError => ex
      puts "This task should be called only for redmine_banner spec. #{ex.message}"
    end
  end
end
