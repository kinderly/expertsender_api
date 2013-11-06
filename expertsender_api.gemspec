$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = "expertsender_api"
  s.version = "0.0.1"
  s.authors = ["kinderly"]
  s.email = ["beorc@httplab.ru"]
  s.homepage = "http://github.com/kinderly/expertsender_api"

  s.summary = %q{A wrapper for ExpertSender API}
  s.description = %q{A wrapper for  ExpertSender API}
  s.license = "MIT"

  s.rubyforge_project = "expertsender_api"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('httparty')
  s.add_dependency('nokogiri')

  s.add_development_dependency 'rake'
  s.add_development_dependency "rspec"
end
