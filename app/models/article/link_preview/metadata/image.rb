class Article::LinkPreview::Metadata::Image
  USER_AGENT = "stanko.io/1.0.0 link_preview_bot/1.0.0"
  REQUEST_TIMEOUT = 10
  MAX_FILE_SIZE = 10.megabytes

  attr_reader :url, :data, :content_type_header

  def self.from_url(url)
    return nil if url.blank?

    image = new(url)
    image.download

    if image.data.present?
      image
    end
  end

  def initialize(url)
    @url = url
    @data = nil
    @content_type_header = nil
  end

  def download
    response = http_client.get(url)
    return if response.is_a?(HTTPX::ErrorResponse)

    if (200...300).include?(response.status)
      @content_type_header = response.headers["content-type"]

      if image_content_type?
        body = response.body.to_s

        if body.bytesize <= MAX_FILE_SIZE
          @data = body
        end
      end
    end
  rescue SocketError, OpenSSL::SSL::SSLError, ArgumentError => e
    Rails.logger.warn("Failed to download image from #{url}: #{e.message}")
    nil
  end

  def file
    return nil if data.blank?

    StringIO.new(data)
  end

  def filename
    return nil if url.blank?

    uri = URI.parse(url)
    basename = File.basename(uri.path)

    if File.extname(basename).blank?
      extension = extension_from_content_type
      basename = "#{basename}#{extension}" if extension.present?
    end

    basename.presence || "image#{extension_from_content_type}"
  end

  def content_type
    @content_type_header&.split(";")&.first&.strip || guess_content_type
  end

  private
    def http_client
      @http_client ||= HTTPX
        .plugin(:follow_redirects)
        .with(timeout: { operation_timeout: REQUEST_TIMEOUT })
        .with(headers: { "user-agent" => USER_AGENT, "accept" => "image/*" })
    end

    def image_content_type?
      return false if content_type_header.blank?

      content_type_header.start_with?("image/")
    end

    def extension_from_content_type
      case content_type
      when "image/jpeg", "image/jpg" then ".jpg"
      when "image/png" then ".png"
      when "image/gif" then ".gif"
      when "image/webp" then ".webp"
      when "image/svg+xml" then ".svg"
      else ".jpg"
      end
    end

    def guess_content_type
      ext = File.extname(URI.parse(url).path).downcase

      case ext
      when ".jpg", ".jpeg" then "image/jpeg"
      when ".png" then "image/png"
      when ".gif" then "image/gif"
      when ".webp" then "image/webp"
      when ".svg" then "image/svg+xml"
      else "image/jpeg"
      end
    rescue
      "image/jpeg"
    end
end
