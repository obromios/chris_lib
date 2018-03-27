$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "chris_lib/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "chris_lib"
  s.version     = ChrisLib::VERSION
  s.authors     = ["Chris"]
  s.email       = ["obromios@gmail.com"]
  s.homepage    = "https://github.com/obromios"
  s.summary     = %q{This an eclectic collection of methods. It include maths, datetime, and rspec access test libraries.}
  s.description = %q{It include maths, datetime, and rspec access test libraries. It include maths, datetime, and rspec access test libraries.}
  s.license     = "MIT"
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.add_dependency "rails", '~> 5.1.4'
  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails', '~> 3.7.2'
  s.add_dependency "dotenv"
end
