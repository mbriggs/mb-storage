# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = "mb-storage"
  s.version = "0.0.0"
  s.summary = " "
  s.description = " "

  s.authors = ["matt@mattbriggs.net"]
  s.homepage = "http://gelaskins.com"
  s.licenses = ["UNLICENSED"]

  s.require_paths = ["lib"]
  s.files = Dir.glob("{lib}/**/*")
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = ">= 2.7"

  s.add_runtime_dependency "evt-dependency"
  s.add_runtime_dependency "evt-configure"
  s.add_runtime_dependency "evt-settings"
  s.add_runtime_dependency "evt-virtual"
  s.add_runtime_dependency "evt-log"

  s.add_runtime_dependency 'aws-sdk-s3'

  s.add_development_dependency "test_bench"
end
