# importmap-rails-css

Automatically vendors CSS files when pinning packages with [importmap-rails](https://github.com/rails/importmap-rails). If a pinned package declares a `style` field in its `package.json`, the corresponding CSS file is downloaded to `vendor/stylesheets/`.

## Installation

Add to your Gemfile:

```ruby
gem 'importmap-rails-css'
```

## Usage

Just run `bin/importmap pin` as usual:

```
$ bin/importmap pin flatpickr
Pinning "flatpickr" to vendor/javascript/flatpickr.js via download from https://ga.jspm.io/npm:flatpickr@4.6.13/dist/flatpickr.js
Pinning CSS "flatpickr" to vendor/stylesheets/flatpickr.css via download from https://cdn.jsdelivr.net/npm/flatpickr@4.6.13/dist/flatpickr.css
```

`bin/importmap update` and `bin/importmap pristine` also download CSS in the same way.

`bin/importmap unpin` removes the corresponding CSS file as well.

Packages without a `style` field in their `package.json` are silently skipped.

## Where CSS files are placed

Downloaded CSS files go into `vendor/stylesheets/`. This directory is automatically added to the asset path by the gem's Engine, so you can link them with `stylesheet_link_tag`:

```erb
<%= stylesheet_link_tag 'flatpickr' %>
```

## License

MIT
