# frozen_string_literal: true

class Article
  class Statistic
    class Storage < ApplicationModel
      attr_accessor :article,
                    :expected_size,
                    :error_rate,
                    :options

      validates :article,
                presence: true
      validates :expected_size,
                numericality: { only_integer: true, greater_than: 0 }
      validates :error_rate,
                numericality: { greater_than: 0, less_than: 1 }

      def self.find(provider)
        "#{name.deconstantize}::#{provider.classify}Storage".constantize
      end

      def remembers?(fingerprint)
        raise NotImplementedError
      end

      def remember!(fingerprint)
        raise NotImplementedError
      end
    end
  end
end
