require "base32/crockford"

module ULID
  module Rails
    module Formatter
      def self.format(v)
        if v.length == 32
          Base32::Crockford.encode(v.hex)
        else
          v
        end
      end

      def self.unformat(v)
        Base32::Crockford.decode(v).to_s(16).rjust(32, "0")
      end

      def self.regexp
        /\A[[:alnum:]]{25}\z/
      end
    end
  end
end
