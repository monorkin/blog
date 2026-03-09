xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @snaps.find_each do |snap|
    xml.url do
      xml.loc snap_url(snap)
      xml.lastmod snap.updated_at.iso8601
      xml.priority 0.5
    end
  end
end
