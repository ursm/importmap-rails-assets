require 'test_helper'

class PackagerExtensionTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @importmap_path = File.join(@dir, 'config', 'importmap.rb')

    FileUtils.mkdir_p File.join(@dir, 'config')
    File.write @importmap_path, ''

    @vendor_js  = File.join(@dir, 'vendor', 'javascript')
    @vendor_css = File.join(@dir, 'vendor', 'stylesheets')

    @packager = Importmap::Packager.new(@importmap_path, vendor_path: @vendor_js)
  end

  def teardown
    FileUtils.remove_entry @dir
  end

  def test_download_fetches_css_when_style_field_exists
    stub_js_download
    stub_npm_registry('flatpickr', '4.6.13', style: 'dist/flatpickr.css')
    stub_request(:get, 'https://cdn.jsdelivr.net/npm/flatpickr@4.6.13/dist/flatpickr.css')
      .to_return(body: 'body { color: red; }')

    Dir.chdir(@dir) do
      @packager.download('flatpickr', 'https://ga.jspm.io/npm:flatpickr@4.6.13/dist/flatpickr.js')
    end

    css_path = File.join(@vendor_css, 'flatpickr.css')
    assert File.exist?(css_path), 'CSS file should be created'

    content = File.read(css_path)
    assert_includes content, '/* flatpickr@4.6.13 downloaded from'
    assert_includes content, 'body { color: red; }'
  end

  def test_download_skips_css_when_no_style_field
    stub_js_download
    stub_npm_registry('lodash', '4.17.21', style: nil)

    Dir.chdir(@dir) do
      @packager.download('lodash', 'https://ga.jspm.io/npm:lodash@4.17.21/lodash.js')
    end

    refute File.exist?(File.join(@vendor_css, 'lodash.css'))
  end

  def test_download_handles_scoped_package
    stub_js_download
    stub_npm_registry('@scope/pkg', '1.0.0', style: 'dist/style.css')
    stub_request(:get, 'https://cdn.jsdelivr.net/npm/@scope/pkg@1.0.0/dist/style.css')
      .to_return(body: '.pkg {}')

    Dir.chdir(@dir) do
      @packager.download('@scope/pkg', 'https://ga.jspm.io/npm:@scope/pkg@1.0.0/index.js')
    end

    css_path = File.join(@vendor_css, '@scope--pkg.css')
    assert File.exist?(css_path), 'CSS file should be created with -- separator'
  end

  def test_remove_deletes_css_file
    Dir.chdir(@dir) do
      FileUtils.mkdir_p @vendor_css
      File.write File.join(@vendor_css, 'flatpickr.css'), 'body {}'
      File.write @importmap_path, %(pin "flatpickr" # @4.6.13\n)

      @packager.remove('flatpickr')
    end

    refute File.exist?(File.join(@vendor_css, 'flatpickr.css'))
  end

  def test_remove_succeeds_when_no_css_file
    Dir.chdir(@dir) do
      File.write @importmap_path, %(pin "flatpickr" # @4.6.13\n)

      @packager.remove('flatpickr')
    end
  end

  def test_download_skips_css_when_npm_registry_fails
    stub_js_download
    stub_request(:get, 'https://registry.npmjs.org/broken/1.0.0')
      .to_return(status: 500)

    Dir.chdir(@dir) do
      @packager.download('broken', 'https://ga.jspm.io/npm:broken@1.0.0/index.js')
    end

    refute File.exist?(File.join(@vendor_css, 'broken.css'))
  end

  def test_download_skips_css_when_cdn_fails
    stub_js_download
    stub_npm_registry('pkg', '1.0.0', style: 'dist/style.css')
    stub_request(:get, 'https://cdn.jsdelivr.net/npm/pkg@1.0.0/dist/style.css')
      .to_return(status: 404)

    Dir.chdir(@dir) do
      @packager.download('pkg', 'https://ga.jspm.io/npm:pkg@1.0.0/index.js')
    end

    refute File.exist?(File.join(@vendor_css, 'pkg.css'))
  end

  private

  def stub_js_download
    stub_request(:get, /ga\.jspm\.io/).to_return(body: '// js')
  end

  def stub_npm_registry(package, version, style:)
    body = {name: package, version: version}
    body[:style] = style if style

    stub_request(:get, "https://registry.npmjs.org/#{package}/#{version}")
      .to_return(body: body.to_json)
  end
end
