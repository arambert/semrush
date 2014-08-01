$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "semrush/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "semrush"
  s.version     = Semrush::VERSION
  s.authors     = ["arambert"]
  s.email       = ["adrien@rambert.me"]
  s.homepage    = "http://adrienrambert.com"
  s.summary     = "This gem is a ruby client for the SemRush API."
  s.description = "This gem is a ruby client for the SemRush API."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activesupport", ">= 3.2.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", ">= 2.0.0"
end
