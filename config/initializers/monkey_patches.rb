# frozen_string_literal: true

require 'monkey_patches/array/maximum'
Array.include(MonkeyPatches::Array::Maximum)
