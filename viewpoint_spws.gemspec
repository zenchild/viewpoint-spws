# -*- encoding: utf-8 -*-
require 'date'

version = File.read(File.expand_path("../VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'viewpoint_spws'
  s.version = version
  s.date    = Date.today.to_s
  s.summary = "A Ruby client access library for Microsoft Sharepoint Web Services (SPWS)"
  s.description	= <<-EOF
    A Ruby client access library for Microsoft Sharepoint Web Services (SPWS).  It is a work in progress.  Methods are still being added from the Sharepoint API docs.
  EOF
  s.required_ruby_version = '>= 1.8.7'
  s.author = 'Dan Wanek'
  s.email = 'dan.wanek@gmail.com'
  s.homepage = "http://github.com/zenchild/viewpoint_spws"
  s.rubyforge_project = nil

  s.extra_rdoc_files = %w(README.md LICENSE)
  s.files = `git ls-files`.split(/\n/)
  s.require_path = 'lib'
  s.rdoc_options = %w(-x spec/)

  s.add_runtime_dependency  'nokogiri',   '~> 1.5.0'
  s.add_runtime_dependency  'httpclient', '~> 2.2.4'
  s.add_runtime_dependency  'logging',    '~> 1.6.1'
  s.add_runtime_dependency  'rubyntlm'
end
