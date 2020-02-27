#!/usr/bin/env ruby
require '/Users/Chris/Sites/chris_lib/lib/chris_lib/version.rb'
include ChrisLib
msg = "Build v#{ChrisLib::VERSION} of chris_lib"
puts msg
`gem build chris_lib`
`git add .`
`git commit -m "#{msg}"`
`git push origin master`
puts 'Push to rubygems, need to enter OTP from Google Authenticator'
system "gem push chris_lib-#{ChrisLib::VERSION}.gem"
puts "pushed v#{ChrisLib::VERSION} to rubygems and github"
`git tag v#{ChrisLib::VERSION} -m msg`
`git push --tags`
puts "pushed v#{ChrisLib::VERSION} tag"
puts 'Bump version, update changelog with git_sha'