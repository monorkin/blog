# frozen_string_literal: true

module HeaderNavHelper
  def header_nav(&block)
    desktop_header_nav(&block) +
      mobile_header_nav(&block)
  end

  def desktop_header_nav(&block)
    content_tag(:nav, class: "header__desktop") do
      content_tag(:ul, class: "header__nav-list") do
        concat(header_about_nav_item)
        block.call
      end +
        content_tag(:div) do
          content_tag(:ul, class: "header__nav-list") do
            header_nav_item(
              search_path,
              class: "header__nav-item--wide-gap",
              data: {
                controller: "modal-action hotkey",
                modal_action_frame_name_value: :search,
                modal_action_class_value: "dialog--overlay",
                modal_action_data_attributes_value: { "closeButton" => true }.to_json,
                action: "click->modal-action#openModal keydown.ctrl+k@document->hotkey#click keydown.meta+k@document->hotkey#click"
              }
            ) do
              search_icon(class: "icon") + content_tag(:span, "Search", class: "visually-hidden")
            end
          end +
            content_tag(:div, class: "header__settings-btn") do
              link_to(
                settings_path,
                data: {
                  controller: "modal-action",
                  modal_action_frame_name_value: :settings,
                  modal_action_class_value: "dialog--overlay dialog--overlay-settings",
                  modal_action_data_attributes_value: { "closeButton" => true }.to_json,
                  action: "click->modal-action#openModal"
                }
              ) do
                settings_icon(class: "icon") +
                  content_tag(:span, t(".settings"), class: "visually-hidden")
              end
            end
        end
    end
  end

  def mobile_header_nav(&block)
    content_tag(:nav, class: "header__mobile") do
      content_tag(:ul) do
        header_about_nav_item
      end +
        content_tag(:div, data: { controller: "navigation", navigation_dialog_outlet: "#navigation-dialog" }) do
          content_tag(:a, class: "header__menu-btn",
                          data: { action: "navigation#openMenu" }) do
            menu_icon(class: "icon")
          end +
            content_tag(
              :dialog,
              class: "header__mobile-dialog",
              id: "navigation-dialog",
              data: { controller: "dialog" },
              "aria-label" => "Navigation menu"
            ) do
              content_tag(:div, class: "header__mobile-menu") do
                turbo_frame_tag(:mobile_search, src: search_path, class: "header__mobile-search",
                                         loading: :lazy, data: { close_button: false }) +
                  content_tag(:ul, class: "header__mobile-nav-list") do
                    concat(header_nav_item(root_path) { t(".about") })
                    block.call
                    concat(header_nav_item(settings_path, data: {
                                             controller: "modal-action",
                                             modal_action_frame_name_value: :settings,
                                             modal_action_class_value: "dialog--overlay-mobile",
                                             action: "click->modal-action#openModal"
                                           }) { t(".settings") })
                  end +
                  content_tag(:ul, class: "header__mobile-footer") do
                    concat(header_nav_item(root_path, data: { action: "dialog#close" }) { t(".close") })
                  end
              end
            end
        end
    end
  end

  def header_about_nav_item
    header_nav_item(root_path, class: "header__nav-item--wide-gap") do
      profile_image_tag(class: "header__profile-img", version: :small, srcset: false) +
        content_tag(:div, class: "inline") do
          content_tag(:span, "Stanko") +
            content_tag(:span, "K.R.", class: "header__profile-name-suffix")
        end
    end
  end

  def header_nav_item(url, **options, &block)
    wrapper_options = options.delete(:wrapper) || {}

    options[:class] = "header__nav-item #{options[:class]}"

    content_tag(:li, class: wrapper_options[:class]) do
      if options.key?(:method)
        button_to(url, options, &block)
      else
        link_to(url, options, &block)
      end
    end
  end
end
