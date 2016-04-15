xml.instruct!
xml.urlset 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  resources_for_sitemap.each do |page|
    xml.url do
      xml.loc url_proc.call(File.join(url_root, page.url))
      xml.lastmod(File.mtime(page.source_file).iso8601) if page.source_file
      xml.changefreq page.data.changefreq || changefreq_proc.call(page.url)
      xml.priority page.data.priority || priority_proc.call(page.url)
    end
  end
end
