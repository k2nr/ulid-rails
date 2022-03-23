require "base32/crockford"

module ULID
  module Rails
    module Validator
      INVALID_CHARACTERS_REGEX = /[ilou]/i.freeze

      def self.is_valid?(v)
        return true if v.nil?
        return false unless v.length == 26
        return false if INVALID_CHARACTERS_REGEX.match?(v)
        
        Base32::Crockford.valid?(v)
      end
    end
  end
end
