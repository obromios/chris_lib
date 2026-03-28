#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

ROOT = Pathname(__dir__).join('..').expand_path
$LOAD_PATH.unshift(ROOT.join('lib').to_s)

require 'chris_lib/version'

Dir.chdir(ROOT)

def run!(*command)
  success = system(*command)
  return if success

  abort("Command failed: #{command.join(' ')}")
end

version = ChrisLib::VERSION
gem_file = "chris_lib-#{version}.gem"
tag_name = "v#{version}"

puts "Preparing #{gem_file}"
puts 'This script assumes tests already passed and master is already pushed.'
puts 'RubyGems will prompt for OTP if MFA is enabled.'
puts 'Press enter to continue or ctrl-c to abort.'
$stdin.gets

run!('gem', 'build', 'chris_lib.gemspec')
run!('gem', 'push', gem_file)

existing_tags = `git tag --list #{tag_name}`.lines.map(&:strip)
if existing_tags.include?(tag_name)
  puts "#{tag_name} already exists locally, skipping tag creation."
else
  run!('git', 'tag', tag_name, '-m', tag_name)
end

run!('git', 'push', 'origin', tag_name)

puts "Published #{gem_file} and pushed #{tag_name}"
