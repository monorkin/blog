# frozen_string_literal: true

module LinkHelper
  IGNORED_HOSTS = [
    'localhost',
    /^(.+\.)?flipboard\..+$/,
    /^com\.google\.android\..+$/,
    'com.laurencedawson.reddit_sync',
    'app.mailbrew.com',
    /^(.+\.)?feedly\..+$/,
    /^(.+\.)?inoreader\..+$/,
    /^(.+\.)?stanko\.io$/
  ].freeze

  SEARCH_ENGINES = [
    /^(.+\.)?google\..+$/,
    /^(.+\.)?bing\..+$/,
    /^(.+\.)?yahoo\..+$/,
    /^(.+\.)?baiu\..+$/,
    /^(.+\.)?duckduckgo\..+$/,
    /^(.+\.)?wolframalpha\..+$/,
    /^(.+\.)?yandex\..+$/,
    /^(.+\.)?search\..+$/,
    /^(.+\.)?startpage\..+$/
  ].freeze

  SEARCH_PROVIDERS = {
    duck_duck_go: 'https://duckduckgo.com/?q=%{term}'
  }.freeze

  HOST_MAPPINGS = {
    't.co' => {
      name: 't.co (Twitter)',
      url: 'twitter.com'
    },
    'old.reddit.com' => {
      name: 'old.reddit.com',
      url: 'reddit.com'
    },
    'out.reddit.com' => {
      name: 'out.reddit.com',
      url: 'reddit.com'
    }
  }.freeze

  def backlink(host, url, provider: :duck_duck_go, **options)
    return host if ignored_host?(host) || search_engine?(host)

    mapping = HOST_MAPPINGS.fetch(host, { name: host, url: host })

    link_to(mapping[:name],
            internet_search_url("#{url} site: #{mapping[:url]}", provider: provider),
            **options)
  end

  def internet_search_url(term, provider: :duck_duck_go)
    format(SEARCH_PROVIDERS[provider], term: CGI.escape(term))
  end

  def search_engine?(url)
    SEARCH_ENGINES.any? { |engine| engine.match?(url) }
  end

  def ignored_host?(url)
    IGNORED_HOSTS.any? { |host| host.match?(url) }
  end
end
