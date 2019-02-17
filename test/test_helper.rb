begin
  require 'simplecov'
  require 'simplecov-rcov'
rescue LoadError => ex
  puts <<-"EOS"
  This test should be called only for redmine banner test.
    Test exit with LoadError --  #{ex.message}
  Please move redmine_banner/Gemfile.local to redmine_banner/Gemfile
  and run bundle install if you want to to run tests.
  EOS
  exit
end

if ENV['JENKINS'] == 'true'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  true
else
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter])
end

SimpleCov.coverage_dir('coverage/redmine_banner_test')

SimpleCov.start do
  add_filter do |source_file|
    # report this plugin only.
    !source_file.filename.include?('plugins/redmine_banner') || !source_file.filename.end_with?('.rb')
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

# TODO: Workaround: Fixtures_path could not be set temporary, so this has to do it
ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/',
                                         File.basename('banners', '.*'))
