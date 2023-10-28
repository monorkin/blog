# frozen_string_literal: true

module HeaderNavHelper
  def header_nav(&block)
    desktop_header_nav(&block) +
    mobile_header_nav(&block)
  end

  def desktop_header_nav(&block)
    content_tag(:nav, class: "hidden md:flex py-2 lg:py-4 px-2 lg:px-4 flex-row items-center gap-x-4 justify-between") do
      content_tag(:ul, class: "flex flex-row items-center gap-x-4 grow-0") do
        concat(header_about_nav_item)
        block.call
      end +
      content_tag(:div) do
        content_tag(:ul, class: "flex flex-row items-center gap-x-4 grow-0") do
          header_nav_item(
            search_path,
            class: "lg:gap-x-4",
            data: {
              controller: "modal-action",
              modal_action_frame_name_value: :search,
              modal_action_class_value: "absolute top-0 bottom-0 left-0 right-0 md:bottom-auto md:top-8",
              modal_action_data_attributes_value: { "closeButton" => true }.to_json
            }
          ) do
            search_icon(class: "w-6 h-6") + content_tag(:span, "Search", class: "sr-only")
          end
        end +
        content_tag(:div, class: "fixed bottom-9 right-4") do
          link_to(
            settings_path,
            class: "p-2 block group bg-white dark:bg-neutral-900 dark:border dark:border-neutral-800 shadow-lg rounded-full text-indigo-600 hover:text-indigo-800 dark:text-yellow-500 dark:hover:text-yellow-400",
            data: { controller: "modal-action", modal_action_frame_name_value: :settings, modal_action_data_attributes_value: { "closeButton" => true }.to_json }
          ) do
            settings_icon(class: "group-hover:animate-spin w-6 h-6") +
            content_tag(:span, t(".settings"), class: "sr-only")
          end
        end
      end
    end
  end

  def mobile_header_nav(&block)
    content_tag(:nav, class: "flex md:hidden py-2 px-2 flex-row items-center gap-x-4 justify-between") do
      content_tag(:div) do
        header_about_nav_item
      end +
      content_tag(:div, data: { controller: "navigation", navigation_dialog_outlet: "#navigation-dialog" }) do
        content_tag(:a, class: "round text-indigo-600 dark:text-yellow-500 cursor-pointer", data: { action: "navigation#openMenu" }) do
          menu_icon(class: "w-6 h-6")
        end +
        content_tag(
          :dialog,
          class: "aboslute inset-0 w-full h-full rounded-lg backdrop:backdrop-blur-lg dark:bg-black dark:border-neutral-500 dark:border",
          id: "navigation-dialog",
          data: { controller: "dialog" },
          "aria-label" => "Navigation menu"
        ) do
          content_tag(:div, class: "flex flex-col gap-y-4 justify-between divide-y h-full") do
            turbo_frame_tag(:search, src: search_path, class: "grow-0 group dark:border-neutral-500", loading: :lazy, data: { close_button: false }) +
            content_tag(:ul, class: "flex flex-col items-center gap-y-4 py-4 grow dark:border-neutral-500") do
              concat(header_nav_item(root_path) { t(".about") })
              block.call
              concat(header_nav_item(settings_path, data: { controller: "modal-action", modal_action_frame_name_value: :settings }) { t(".settings") })
            end +
            content_tag(:ul, class: "flex flex-col items-center gap-y-4 py-4 grow-0 dark:border-neutral-500") do
              concat(header_nav_item(root_path, data: { action: "dialog#close" }) { t(".close") })
            end
          end
        end
      end
    end
  end

  def header_about_nav_item
    header_nav_item(root_path, class: "lg:gap-x-4") do
      profile_image_tag(class: "h-8 w-8 rounded-full shadow", version: :small, srcset: false) +
      content_tag(:div, class: "inline") do
        content_tag(:span, "Stanko") +
        content_tag(:span, "K.R.", class: "ml-1 text-xs")
      end
    end
  end

  def header_nav_item(url, **options, &block)
    wrapper_options = options.delete(:wrapper) || {}

    options[:class] = "flex flex-row items-center gap-x-2 font-mono font-semibold uppercase text-indigo-600 dark:text-yellow-500 #{options[:class]}"

    content_tag(:li, class: wrapper_options[:class]) do
      link_to(url, options, &block)
    end
  end
end
