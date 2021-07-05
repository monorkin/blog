# frozen_string_literal: true

module MonkeyPatches
  module Array
    module Maximum
      def maximum(attribute)
        map { |element| element.try(attribute) || element.try(:[], attribute) }
          .compact
          .max
      end
    end
  end
end
