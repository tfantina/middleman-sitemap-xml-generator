# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)
require 'middleman-sitemap-xml-generator/version'

Gem::Specification.new do |s|
  s.name          = 'middleman-sitemap-xml-generator'
  s.version       = Middleman::SitemapXmlGenerator::VERSION
  s.authors       = ['AT-AT']
  s.email         = ['dec.alpha21264@gmail.com']
  s.homepage      = 'https://github.com/AT-AT/middleman-sitemap-xml-generator'
  s.summary       = %q{Adds a sitemap.xml file to your Middleman site for search engines.}
  s.description   = %q{Adds a sitemap.xml file to your Middleman site for search engines.}
  s.license       = 'MIT'
  s.files         = `git ls-files -z`.split("\0")
  s.test_files    = `git ls-files -- {test,spec,features,fixtures}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  
  # The version of middleman-core your extension depends on
  s.add_runtime_dependency 'middleman-core', '~> 3.4.1'
  s.add_runtime_dependency 'builder'

  # Additional dependencies
  s.add_development_dependency 'bundler', '~> 1.5'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'nokogiri'
end
