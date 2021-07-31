# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'bundler/setup'
Bundler.setup

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
