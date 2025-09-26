#!/usr/bin/env ruby
require '/Users/Chris/Sites/chris_lib/lib/chris_lib/version.rb'
require './lib/chris_lib/shell_methods.rb'
require 'colorize'
include ChrisLib
include ShellMethods
msg = "Build v#{ChrisLib::VERSION} of chris_lib".colorize(:green)
puts msg
puts 'Assuming all tests passed'.colorize(:yellow)
puts 'Assuming you have run bundle exec yard doc'.colorize(:yellow)
puts "Assuming version is higher than deployed version".colorize(:yellow)
puts "press any key to continue or ctrl-c to abort".colorize(:red)
$stdin.getch
`gem build chris_lib`.colorize(:yellow)
`git add .`
`git commit -m "#{msg}"`
puts "Pushing to github - may need personal access token".colorize(:yellow)
puts "create at github/settings/developer".colorize(:yellow)
`git push origin master`
puts 'Push to rubygems, need to enter OTP from Google Authenticator'.colorize(:yellow)
system "gem push chris_lib-#{ChrisLib::VERSION}.gem"
puts "pushed v#{ChrisLib::VERSION} to rubygems and github"
`git tag v#{ChrisLib::VERSION} -m msg`
`git push --tags`
puts "pushed v#{ChrisLib::VERSION} tag"
git_sha = `git log --pretty=format:'%h' -n 1`
puts "Bump version, remove *.gem files, update changelog with #{git_sha} #{time_hash}"
