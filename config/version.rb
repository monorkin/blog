# frozen_string_literal: true

module Blog
  MAJOR = 1
  PATCH = 11
  CANDIDATE = nil
  VERSION = [MAJOR, PATCH, CANDIDATE].compact.join('.').freeze
end
