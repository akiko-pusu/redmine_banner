namespace :redmine_banner do
  desc 'Run test for redmine_banner plugin.'
  task default: :test

  desc 'Run test for redmine_banner plugin.'
  Rake::TestTask.new(:test) do |t|
    t.libs << 'lib'
    t.pattern = 'plugins/redmine_banner/test/**/*_test.rb'
    t.verbose = false
    t.warning = false
  end
end
