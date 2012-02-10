# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "viewpoint/spws/version"

Gem::Specification.new do |s|
  s.name        = "viewpoint-spws"
  s.version     = Viewpoint::SPWS::VERSION
  s.date        = Date.today.to_s
  s.author      = "Dan Wanek"
  s.email       = "dan.wanek@gmail.com"
  s.homepage    = "http://github.com/zenchild/viewpoint-spws"
  s.summary     = "A Ruby client access library for Microsoft Sharepoint Web Services (SPWS)"
  s.description = %q{TODO: Write a gem description}
  s.description	= <<-EOF
    A Ruby client access library for Microsoft Sharepoint Web Services (SPWS).  It is a work in progress.  Methods are still being added from the Sharepoint API docs.
  EOF
  s.required_ruby_version = '>= 1.8.7'

  s.rubyforge_project = nil

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.rdoc_options  = %w(-x spec/)
  s.extra_rdoc_files = %w(README.md LICENSE)

  s.add_runtime_dependency  'nokogiri',   '~> 1.5.0'
  s.add_runtime_dependency  'httpclient', '~> 2.2.4'
  s.add_runtime_dependency  'logging',    '~> 1.6.1'
  s.add_runtime_dependency  'rubyntlm'
end
