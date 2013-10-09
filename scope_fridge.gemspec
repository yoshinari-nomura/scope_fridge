$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "scope_fridge/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "scope_fridge"
  s.version     = ScopeFridge::VERSION
  s.authors     = ["Yoshinari Nomura"]
  s.email       = ["nom@quickhack.net"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ScopeFridge."
  s.description = "TODO: Description of ScopeFridge."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.6"

  s.add_development_dependency "sqlite3"
end
