# frozen_string_literal: true

module AboutHelper
  def about_page_contact_link_content(title, img_path)
    content_tag(:div, class: "about__contact") do
      content_tag(:div, "", class: "about__contact-glow") +
        content_tag(:div, class: "about__contact-inner") do
          image_tag(img_path, class: "about__contact-icon", alt: title) +
            content_tag(:div, title, class: "about__contact-label")
        end
    end
  end
end
