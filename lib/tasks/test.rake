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
