# frozen_string_literal: true

module LinkHelper
  SEARCH_ENGINES = Set.new(
    %w[
      www.google.com
      www.bing.com
      search.yahoo.com
      www.baidu.com
      duckduckgo.com
      ask.com
      www.wolframalpha.com
      yandex.com
      www.search.com
    ]
  ).freeze

  SEARCH_PROVIDERS = {
    duck_duck_go: 'https://duckduckgo.com/?q=%{term}'
  }.freeze

  def backlink(host, url, provider: :duck_duck_go, **options)
    return host if SEARCH_ENGINES.include?(host)

    link_to(host,
            internet_search_url("#{url} site: #{host}", provider: provider),
            **options)
  end

  def internet_search_url(term, provider: :duck_duck_go)
    format(SEARCH_PROVIDERS[provider], term: CGI.escape(term))
  end
end
