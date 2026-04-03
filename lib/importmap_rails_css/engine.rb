module ImportmapRailsCss
  class Engine < ::Rails::Engine
    initializer 'importmap_rails_css.assets' do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << Rails.root.join('vendor/stylesheets')
      end
    end
  end
end
