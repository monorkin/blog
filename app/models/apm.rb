# frozen_string_literal: true

class Apm < ApplicationModel
  attr_accessor :current_transaction

  after_initialize do
    self.current_transaction ||= Sentry.get_current_scope&.get_transaction
  end

  def span(name, options = {}, &block)
    return block.call(nil) if current_transaction.blank?

    options[:op] = name
    current_transaction.with_child_span(options) do |span|
      block.call(span)
    end
  end
end
