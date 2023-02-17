# frozen_string_literal: true

module Blog
  MAJOR = 2
  PATCH = 11
  CANDIDATE = nil
  VERSION = [MAJOR, PATCH, CANDIDATE].compact.join('.').freeze
end
