module IconHelper
  def text_with_icon(icon, text, **options)
    raise ArgumentError, "Unknown icon: #{icon}" unless respond_to?("#{icon}_icon")

    options[:wrapper] ||= {}
    position = options.delete(:position)&.to_sym
    icon_html = send("#{icon}_icon", **options)

    content_tag(:span, class: "flex flex-row items-center gap-x-2 " + options[:wrapper].fetch(:class, "")) do
      if position == :after
        concat(text)
        concat(icon_html)
      else
        concat(icon_html)
        concat(text)
      end
    end
  end

  def arrow_long_right_icon(**options)
    options[:alt] ||= "Arrow long right"
    icon_svg('<path stroke-linecap="round" stroke-linejoin="round" d="M17.25 8.25L21 12m0 0l-3.75 3.75M21 12H3" />', **options)
  end

  def arrow_long_left_icon(**options)
    options[:alt] ||= "Arrow long left"
    icon_svg('<path stroke-linecap="round" stroke-linejoin="round" d="M6.75 15.75L3 12m0 0l3.75-3.75M3 12h18" /> ', **options)
  end

  def search_icon(**options)
    options[:alt] ||= "Search icon"
    options[:fill] ||= "none"
    icon_svg('<path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />', **options)
  end

  def close_icon(**options)
    options[:alt] ||= "Close icon"
    options[:fill] ||= "none"
    icon_svg('<path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />', **options)
  end

  def menu_icon(**options)
    options[:alt] ||= "Menu icon"
    options[:fill] ||= "none"
    icon_svg('<path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />', **options)
  end

  def rss_icon(**options)
    options[:alt] ||= "RSS icon"
    options[:fill] ||= "none"
    icon_svg('<path stroke-linecap="round" stroke-linejoin="round" d="M12.75 19.5v-.75a7.5 7.5 0 00-7.5-7.5H4.5m0-6.75h.75c7.87 0 14.25 6.38 14.25 14.25v.75M6 18.75a.75.75 0 11-1.5 0 .75.75 0 011.5 0z" />', **options)
  end

  def settings_icon(**options)
    options[:alt] ||= "Settings icon"
    options[:fill] ||= "none"
    icon_svg('<path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12a7.5 7.5 0 0015 0m-15 0a7.5 7.5 0 1115 0m-15 0H3m16.5 0H21m-1.5 0H12m-8.457 3.077l1.41-.513m14.095-5.13l1.41-.513M5.106 17.785l1.15-.964m11.49-9.642l1.149-.964M7.501 19.795l.75-1.3m7.5-12.99l.75-1.3m-6.063 16.658l.26-1.477m2.605-14.772l.26-1.477m0 17.726l-.26-1.477M10.698 4.614l-.26-1.477M16.5 19.794l-.75-1.299M7.5 4.205L12 12m6.894 5.785l-1.149-.964M6.256 7.178l-1.15-.964m15.352 8.864l-1.41-.513M4.954 9.435l-1.41-.514M12.002 12l-3.75 6.495" />', **options)
  end

  def sun_icon(**options)
    options[:alt] ||= "Sun icon"
    options[:fill] ||= "none"
    icon_svg('<path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" />', **options)
  end

  def moon_icon(**options)
    options[:alt] ||= "Moon icon"
    options[:fill] ||= "none"
    icon_svg('<path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z" />', **options)
  end

  def computer_icon(**options)
    options[:alt] ||= "Computer icon"
    options[:fill] ||= "none"
    icon_svg('<path stroke-linecap="round" stroke-linejoin="round" d="M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 15V5.25m18 0A2.25 2.25 0 0018.75 3H5.25A2.25 2.25 0 003 5.25m18 0V12a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 12V5.25" />', **options)
  end

  def icon_svg(path, **options)
    content_tag(
      :svg,
      "xmlns" => "http://www.w3.org/2000/svg",
      "fill" => options.fetch(:fill, nil),
      "viewBox" => options.fetch(:view_box, "0 0 24 24"),
      "stroke-width" => options.fetch(:stroke_width, "1.5"),
      "stroke" => options.fetch(:stroke, "currentColor"),
      "class" => options.fetch(:class, "h-4"),
      "alt" => options.fetch(:alt, nil),
      "aria-label" => options.fetch(:alt, nil),
    ) do
      path.html_safe
    end
  end
end
