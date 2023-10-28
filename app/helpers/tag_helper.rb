module TagHelper
  def tag_bubble(tag)
    link_to(
      "##{tag.name}",
      search_path(search: { term: "##{tag.name}" }),
      class: %w[px-2 py-1 rounded-full
        transition-colors duration-100 ease-in
        text-xs
        bg-indigo-100 text-indigo-800
        hover:bg-indigo-300 hover:text-indigo-900
        dark:bg-yellow-300 dark:text-neutral-700
        dark:hover:bg-yellow-500 dark:hover:text-neutral-900
      ]
    )
  end
end
