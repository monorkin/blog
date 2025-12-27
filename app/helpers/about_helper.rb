# frozen_string_literal: true

module AboutHelper
  def about_page_contact_link_content(title, img_path)
    content_tag(:div, class: 'group relative') do
      content_tag(
        :div,
        '',
        class: %(
          hidden md:block absolute inset-0 z-10
          transition-all duration-300 ease-out
          group-hover:bg-gradient-radial from-indigo-600/20 group-hover:from-10% group-hover:to-40%
          dark:from-yellow-500/20
        )
      ) +
        content_tag(:div, class: 'relative z-20 flex flex-col place-items-center') do
          image_tag(
            img_path,
            class: %w[
              object-contain w-10 h-10 m-3 mb-2 md:saturate-0 md:opacity-60
              group-hover:scale-110 group-hover:saturate-100 group-hover:opacity-100
              transition-all duration-300 ease-out
              drop-shadow-none group-hover:drop-shadow-lg
              dark:invert dark:group-hover:saturate-0
              dark:saturate-0
            ],
            alt: title
          ) +
            content_tag(
              :div,
              title,
              class: 'text-center font-semibold text-neutral-600 group-hover:text-indigo-600 dark:text-neutral-500 dark:group-hover:text-yellow-500'
            )
        end
    end
  end
end
