#!/usr/bin/env ruby
# pushes tag to travis so it pushes new
# gem to rubytems
require '/Users/Chris/Sites/chris_lib/lib/chris_lib/version.rb'
include ChrisLib
`git tag v#{ChrisLib::VERSION} -a`
`git push origin v#{ChrisLib::VERSION}`
puts "pushed v#{ChrisLib::VERSION} tag"