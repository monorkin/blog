# frozen_string_literal: true

module LinkHelper
  SEARCH_PROVIDERS = {
    duck_duck_go: 'https://duckduckgo.com/?q=%{term}'
  }.freeze

  def backlink(host, url, provider: :duck_duck_go, **options)
    link_to(host,
            internet_search_url("#{url} site: #{host}", provider: provider),
            **options)
  end

  def internet_search_url(term, provider: :duck_duck_go)
    format(SEARCH_PROVIDERS[provider], term: CGI.escape(term))
  end
end
