require 'net/http'
require 'json'
require 'fileutils'

module ImportmapRailsCss
  module PackagerExtension
    def download(package, url)
      super

      version = extract_package_version_from(url)&.delete_prefix('@')
      return unless version

      style = fetch_style_field(package, version)
      return unless style

      download_css(package, version, style)
    end

    def remove(package)
      super

      css_path = vendored_css_path(package)
      FileUtils.rm_f(css_path) if css_path.exist?
    end

    private

    def fetch_style_field(package, version)
      uri = URI("https://registry.npmjs.org/#{package}/#{version}")

      response = Net::HTTP.get_response(uri)
      return unless response.is_a?(Net::HTTPSuccess)

      metadata = JSON.parse(response.body)
      metadata['style']
    rescue JSON::ParserError
      nil
    end

    def download_css(package, version, style)
      uri = URI("https://cdn.jsdelivr.net/npm/#{package}@#{version}/#{style}")

      response = Net::HTTP.get_response(uri)
      return unless response.is_a?(Net::HTTPSuccess)

      ensure_css_vendor_directory_exists

      File.open(vendored_css_path(package), 'w+') do |f|
        f.write "/* #{package}@#{version} downloaded from #{uri} */\n\n"
        f.write response.body.dup.force_encoding('UTF-8')
      end

      puts %(Pinning CSS "#{package}" to #{css_vendor_path}/#{css_filename(package)} via download from #{uri})
    end

    def css_vendor_path
      @css_vendor_path ||= Pathname.new('vendor/stylesheets')
    end

    def vendored_css_path(package)
      css_vendor_path.join(css_filename(package))
    end

    def css_filename(package)
      package.gsub('/', '--') + '.css'
    end

    def ensure_css_vendor_directory_exists
      FileUtils.mkdir_p css_vendor_path
    end
  end
end
