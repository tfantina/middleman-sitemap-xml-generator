# Middleman-Sitemap-Xml-Generator


This extension is a forked and slightly extended version of [Middleman Search Engine Sitemap by Pete Nicholls](https://github.com/Aupajo/middleman-search_engine_sitemap).

Note that this extension has been forked from the release [tagged as v1.3.0](https://github.com/Aupajo/middleman-search_engine_sitemap/releases/tag/v1.3.0) to support Middleman-v3.

Please refer to [the original](https://github.com/Aupajo/middleman-search_engine_sitemap) if you want to get the latest release or a version for Middleman-v4.


### Why forked from v1.3.0?

Because I'm not be planning to use Middleman-v4 yet. 8-)


## Installation

Add the following line to the Gemfile of your Middleman project:

```ruby
gem 'middleman-sitemap-xml-generator'
```

Then as usual, run:

```sh
bundle install
```


## Usage

To activate and configure this extension, add the following configuration block to Middleman's config.rb:

```ruby
set :url_root, 'http://example.com'
activate :sitemap_xml_generator
```


### Options

| Option             | Default                | Description
| ---                | ---                    | ---
| default_changefreq | 'monthly'              | Default page priority
| default_priority   | 0.5                    | Default page priority
| sitemap_xml_path   | 'sitemap.xml'          | Path to the sitemap.xml
| exclude_attr       | 'hide_from_sitemap'    | Attribute in `Frontmatter` to exclude from the sitemap
| process_url        | nil                    | Callable object(responds to #call) to process a URL
| process_changefreq | nil                    | Callable object to determine a changefreq
| process_priority   | nil                    | Callable object to determine a priority
| exclude_if         | ->(resource) { false } | Callable object to exclude from the sitemap
| extra_ext          | []                     | Extensions allowed to be in the sitemap<br>(needed prefixed "dot")
| discard_ext        | []                     | Extensions removed from "loc" tag<br>(needed prefixed "dot")


## Determination of "changefreq" and "priority"

A value of `changefreq` and `priority` in the sitemap.xml is determined in the following priority.

1. **(Higher)** `Frontmatter` attributes in each file

    ```yaml
    ---
    changefreq: daily
    priority: 1.0
    ---
    ```

1. Processing in a `process_changefreq` and a `process_priority` option

    ```ruby
    activate :sitemap_xml_generator do |f|
      f.process_changefreq = ->(path, default) {
        path.end_with?('.foo') ? 'yearly' : default
      }
      f.process_priority = ->(path, default) {
        path.end_with?('.foo') ? 0.9 : default
      }
    end
    ```

    | Argument | Description
    | ---      | ---
    | path     | A path prefixed "/" from **Web** root. e.g. `/foo.html`
    | default  | The same value as `default_changefreq` or `default_priority`

1. **(Lower)** A value in a `default_changefreq` and a `default_priority` option


## Excluding pages


### Specify in Frontmatter

You can add a `hide_from_sitemap` attribute to `Frontmatter` in the page which is omitted from the sitemap.xml:

```yaml
---
hide_from_sitemap: true
---
```

If you would like to use a different `Frontmatter` attribute, you can specify it in a `exclude_attr` option:

```ruby
activate :sitemap_xml_generator do |f|
  f.exclude_attr = 'invisible'
end
```

Then you can omit a page the following way:

```yaml
---
invisible: true
---
```


### Use custom processor

You can also use a `exclude_if` option to exclude pages based on conditions you want:

```ruby
# Exclude all pages which have a date that's after today
activate :sitemap_xml_generator do |f|
  f.exclude_if = ->(resource) {
    resource.data.date && resource.data.date > Date.today
  }
end
```

| Argument | Description
| ---      | ---
| resource | A resource object (`Middleman::Sitemap::Resource`)


## Processing a URL in "loc" tag

You can use a `process_url` option to process a URL in "loc" tag in each page in the sitemap.xml:

```ruby
# This Proc removes a trailing slash from a URL in all "loc" tag.
activate :sitemap_xml_generator do |f|
  f.process_url = ->(url) { url.chomp('/') }
end
```

| Argument | Description
| ---      | ---
| url      | The URL of each page


## Adding file in addition to HTML

Only HTML file is added to the sitemap.xml with the default setting.

You can use a `extra_ext` option to add any file to the sitemap.xml:

```ruby
# This setting adds every file suffixed ".foo" to the sitemap.xml.
activate :sitemap_xml_generator do |f|
  f.extra_ext = ['.foo'] # prefixed dot is required.
end
```


## Excluding a content extension

You can use a `discard_ext` option to exclude a content extension from a address in "loc" tag in the sitemap.xml:

```ruby
# This setting removes suffixed ".foo" from "loc" tag in the sitemap.xml.
activate :sitemap_xml_generator do |f|
  f.discard_ext = ['.foo'] # prefixed dot is required.
end
```

Note that this process is executed before the process designated in a `process_url` option.


## Workaround for the template reference issue

This extension deals with that [issue](https://github.com/Aupajo/middleman-search_engine_sitemap/issues/5) by [this workaround](https://github.com/Aupajo/middleman-search_engine_sitemap/issues/2#issuecomment-46701165).


## Thanks

All ideas, logics, hints and prizes belong to the original author, Pete Nicholls.

And all mistakes belong to me.


## License

(c) 2016 AT-AT. MIT Licensed, see [LICENSE](LICENSE.md) for details.
