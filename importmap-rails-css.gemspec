require_relative 'lib/importmap_rails_css/version'

Gem::Specification.new do |spec|
  spec.name    = 'importmap-rails-css'
  spec.version = ImportmapRailsCss::VERSION
  spec.authors = ['ursm']

  spec.summary  = 'Automatically vendor CSS from pinned importmap packages'
  spec.homepage = 'https://github.com/ursm/importmap-rails-css'
  spec.license  = 'MIT'

  spec.required_ruby_version = '>= 3.3'

  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md']

  spec.add_dependency 'importmap-rails', '>= 2.0'
  spec.add_dependency 'railties',        '>= 7.0'

end
