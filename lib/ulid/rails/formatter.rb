require "base32/crockford"

module ULID
  module Rails
    module Formatter
      def self.format(v)
        v.length == 32 ? Base32::Crockford.encode(v.hex).rjust(26, "0") : v
      end

      def self.unformat(v)
        Base32::Crockford.decode(v).to_s(16).rjust(32, "0")
      end
    end
  end
end
