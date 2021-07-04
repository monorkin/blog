# frozen_string_literal: true

class Article
  class Statistic
    class Storage
      class MissingProviderError < ApplicationError
        attr_reader :name,
                    :class_name

        def initialize(name, class_name = nil)
          @name = name
          @class_name = class_name
        end

        def message
          "Could not find a storage provider for '#{name}'. " \
          "Please check if a provider class '#{class_name}' "\
          'exists and if you named the file correctly.'
        end
      end
    end
  end
end
