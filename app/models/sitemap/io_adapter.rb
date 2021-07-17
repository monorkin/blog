# frozen_string_literal: true

class Sitemap
  class IoAdapter
    attr_reader :data

    def write(_location, raw_data)
      @data = raw_data
    end
  end
end
