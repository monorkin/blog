# frozen_string_literal: true

module Blog
  MAJOR = 1
  PATCH = 5
  CANDIDATE = nil
  VERSION = [MAJOR, PATCH, CANDIDATE].compact.join('.').freeze
end
