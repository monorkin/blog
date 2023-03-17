# frozen_string_literal: true

module Blog
  MAJOR = 3
  PATCH = 0
  CANDIDATE = nil
  VERSION = [MAJOR, PATCH, CANDIDATE].compact.join('.').freeze
end
