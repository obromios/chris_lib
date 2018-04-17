#!/usr/bin/env ruby
`gem build chris_lib`
`git add .`
`git commit -m "Build v#{ChrisLib::VERSION} of chris_lib"`
`git push origin master`
`gem push chris_lib-#{ChrisLib::VERSION}.gem`
`git tag v#{ChrisLib::VERSION}`
`git push origin v#{ChrisLib::VERSION}`