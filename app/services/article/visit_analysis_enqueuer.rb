# frozen_string_literal: true

class Article
  class VisitAnalysisEnqueuer < ApplicationService
    def initialize(article:, request:)
      @article = article
      @request = request
    end

    def call
      # TODO
    end

    protected

    attr_reader :article,
                :request
  end
end
