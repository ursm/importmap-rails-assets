require 'importmap-rails'
require 'importmap/packager'

require_relative 'importmap_rails_css/version'
require_relative 'importmap_rails_css/packager_extension'
require_relative 'importmap_rails_css/engine'

Importmap::Packager.prepend ImportmapRailsCss::PackagerExtension
