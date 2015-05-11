# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'mt940_parser'
  module_type :class
  path_name   'mt940'
  path_module 'MT940'
  author      [ "Thies C. Arntzen", "Phillip Oertel" ]
  email       'developers@betterplace.org'
  homepage    "http://github.com/betterplace/mt940_parser"
  summary     'MT940 parses account statements in the SWIFT MT940 format.'
  description 'Ruby library that parses account statements in the SWIFT MT940 format.'
  test_dir    'test'
  test_files  Dir['test/**/test_*.rb']
  spec_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', '.rvmrc', 'coverage',
    '.DS_Store', '.ruby-gemset', '.ruby-version', '.bundle', '.AppleDouble'

  readme      'README.rdoc'
  licenses    'MIT'

  development_dependency 'test-unit'
  development_dependency 'simplecov'
end

task :default => :test
