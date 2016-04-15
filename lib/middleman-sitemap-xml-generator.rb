require 'middleman-core'

::Middleman::Extensions.register(:sitemap_xml_generator) do
  require 'middleman-sitemap-xml-generator/extension'
  ::Middleman::SitemapXmlGenerator::Extension
end
