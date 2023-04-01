# frozen_string_literal: true

module ComponentHelper
  def component(component_path, options = {}, &block)
    partial_path = "shared/#{component_path}"

    if block.present?
      content = capture { block.call }
      render(partial_path, options) { content }
    else
      render(partial_path, options)
    end
  end
end
