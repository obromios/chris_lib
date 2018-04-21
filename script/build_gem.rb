#!/usr/bin/env ruby
require '/Users/Chris/Sites/chris_lib/lib/chris_lib/version.rb'
include ChrisLib
`gem build chris_lib`
`git add .`
`git commit -m "Build v#{ChrisLib::VERSION} of chris_lib"`
puts "Build v#{ChrisLib::VERSION} of chris_lib"
`git push origin master`
`gem push chris_lib-#{ChrisLib::VERSION}.gem`
puts "pushed v#{ChrisLib::VERSION} to rubygems and github"
`git tag v#{ChrisLib::VERSION}`
`git push origin v#{ChrisLib::VERSION}`
puts "pushed v#{ChrisLib::VERSION} tag"