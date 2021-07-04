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
        class_name = "#{name.deconstantize}::Storage::#{provider.classify}Storage"
        class_name.constantize
      rescue NameError
        raise MissingProviderError.new(provider, class_name)
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
