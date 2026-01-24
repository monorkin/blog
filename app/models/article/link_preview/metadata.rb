class Article::LinkPreview::Metadata
  attr_reader :title, :description, :image

  def initialize(title: nil, description: nil, image_url: nil)
    @title = title
    @description = description
    @image = Article::LinkPreview::Metadata::Image.from_url(image_url) if image_url.present?
  end
end
