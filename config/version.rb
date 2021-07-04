# frozen_string_literal: true

module Blog
  MAJOR = 1
  PATCH = 0
  CANDIDATE = :dev
  VERSION = [MAJOR, PATCH, CANDIDATE].compact.join('.').freeze
end
