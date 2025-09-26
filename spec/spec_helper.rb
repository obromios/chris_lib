# This file is copied to spec/ when you run 'rails generate rspec:install'
begin
  require 'bundler/setup'
  Bundler.setup
rescue LoadError, NoMethodError => e
  warn "Bundler setup skipped: #{e.message}"
end

%w[base64 bigdecimal logger ostruct].each do |lib|
  begin
    require lib
  rescue LoadError => e
    warn "Optional stdlib dependency #{lib} skipped: #{e.message}"
  end
end

require 'pry'

begin
  require 'rails'
rescue LoadError => e
  warn "Rails not available for specs: #{e.message}"
end
require 'chris_lib'

RSpec.configure do |config|
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.filter_gems_from_backtrace
  config.backtrace_exclusion_patterns = [
      /\/lib\d*\/ruby\//,
      /bin\//,
      /gems/,
      /spec\/spec_helper\.rb/,
      /lib\/rspec\/(core|expectations|matchers|mocks)/
    ]
end
