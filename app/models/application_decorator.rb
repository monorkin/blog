# frozen_string_literal: true

class ApplicationDecorator
  delegate_missing_to :@object

  attr_accessor :object

  def initialize(object)
    self.object = object
  end
end
