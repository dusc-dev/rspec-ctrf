Gem::Specification.new do |s|
  s.name        = 'rspec-ctrf'
  s.version     = '0.0.1'
  s.required_ruby_version = '>= 3.0'
  s.summary     = 'RSpec formatter to output test results in CTRF (https://www.ctrf.io/) JSON format.'
  s.description = 'A custom RSpec formatter that supports outputting of test results in CTRF (https://www.ctrf.io/) JSON format, including support for flaky tests.'
  s.authors     = ['James Meneghello', 'DUSC']
  s.email       = 'james@dusc.dev'
  s.homepage    = 'https://github.com/dusc-dev/rspec-ctrf'
  s.license = 'MIT'

  s.add_dependency 'rspec', '~> 3.0'

  s.add_development_dependency 'rake', '~> 13.2'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-json_matchers'
  s.add_development_dependency 'rubocop', '~> 1.61.0'
  s.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  s.add_development_dependency 'rubocop-rspec', '~> 2.25.0'

  s.files = Dir['README.md', 'LICENSE', 'lib/ctrf/r_spec_formatter.rb']
  s.require_path = 'lib'
  s.metadata['rubygems_mfa_required'] = 'true'
end
