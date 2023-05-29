require "base32/crockford"

module ULID
  module Rails
    module Formatter
      def self.format(v)
        sanitized = v.delete("-").hex
        Base32::Crockford.encode(sanitized).rjust(26, "0")
      end

      def self.unformat(v)
        decoded_i = Base32::Crockford.decode(v.to_s).to_i
        decoded_i.to_s(16).rjust(32, "0")
      end
    end
  end
end
