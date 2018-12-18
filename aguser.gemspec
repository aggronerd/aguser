$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "aguser/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aguser"
  s.version     = Aguser::VERSION
  s.authors     = ["Gregory Doran"]
  s.email       = ["greg@gregorydoran.co.uk"]
  s.homepage    = "https://bitbucket.org/aggronerd/aguser"
  s.summary     = "A authenication module for Ruby on Rails."
  s.description = "A authenication module for Ruby on Rails."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.11"

  s.add_development_dependency "sqlite3"
end
