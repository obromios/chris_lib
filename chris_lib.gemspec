$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'chris_lib/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'chris_lib'
  s.version     = ChrisLib::VERSION
  s.authors     = ['Chris']
  s.email       = ['obromios@gmail.com']
  s.homepage    = 'https://github.com/obromios'
  # rubocop:disable LineLength
  s.summary     = 'This an eclectic collection of methods. It include maths, datetime, and rspec access test libraries.'
  s.description = 'It includes maths, datetime, and rspec access test libraries.'
  s.license     = 'MIT'
  s.metadata    = {
    'source_code_uri' => 'https://github.com/obromios/chris_lib',
    'changelog_uri' => 'https://github.com/obromios/chris_lib/blob/master/CHANGELOG.md'
  }
  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  # rubocop:enable LineLength
  s.add_dependency 'dotenv'
  s.add_dependency 'rails'
  s.add_dependency 'actionpack', '~> 6.1.5', '>= 6.1.5.1'
  s.add_dependency 'actionview', '~> 6.1.5', '>= 6.1.5.1'
  s.add_dependency 'quaternion'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'colorize'
end
