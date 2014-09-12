$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "chris_lib/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "chris_lib"
  s.version     = ChrisLib::VERSION
  s.authors     = ["Chris"]
  s.email       = ["obromois@gmail.com"]
  s.homepage    = "https://github.com/obromios"
  s.summary     = %q{This is a library of shared classes and methods for Chris}
  s.description = %q{This library is for personal use only at this stage}
  s.license     = "MIT"
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.add_dependency "rails", "~> 4.1.5"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
