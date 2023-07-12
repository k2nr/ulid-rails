require "base32/crockford"

module ULID
  module Rails
    module Formatter
      def self.format(v)
        # v is 32 lowercase hex
        # sanitized is 37 integers
        sanitized = v.delete("-").hex
        Base32::Crockford.encode(sanitized).rjust(26, "0")
      end

      def self.unformat(v)
        decoded_i = Base32::Crockford.decode(v.to_s).to_i
        # v is 26 digits/uppercase letters
        # decoded_i is 37 integers
        decoded_i.to_s(16).rjust(32, "0")
      end
    end
  end
end
