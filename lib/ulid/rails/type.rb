require "active_model/type"
require "base32/crockford"
require "ulid/rails/errors"

module ULID
  module Rails
    class Type < ActiveModel::Type::Binary
      def assert_valid_value(value)
        raise ArgumentError, "`#{value}` is not a ULID format" unless Data.valid_ulid?(value)
      end

      def cast(value)
        return nil if value.nil?

        str = value.is_a?(Data) ? value.value : value

        cast_string_to_ulid(str).value
      end

      def serialize(value)
        return value if value.is_a?(Data)
        return Data.null unless value.is_a?(String)

        cast_string_to_ulid(value)
      end

      def deserialize(value)
        return nil if value.nil?

        super
      end

      private

      def cast_string_to_ulid(value, data_class: Data)
        raise ArgumentError if !value.is_a?(String)

        if data_class.valid_ulid?(value)
          data_class.new(value)
        else
          data = value.unpack1("H*")
          data_class.from_serialized(data)
        end
      end

      class Data < ActiveModel::Type::Binary::Data
        def self.null
          new(nil)
        end

        def self.from_serialized(data)
          deserialized = Base32::Crockford.encode(data.hex).rjust(26, "0")
          new(deserialized)
        end

        def self.valid_ulid?(str)
          return true if str.nil?

          str.length == 26 && Base32::Crockford.valid?(str)
        end

        def initialize(value)
          @value = nil
          super if self.class.valid_ulid?(value)
        end

        attr_reader :value

        def hex
          return nil if @value.nil?

          hexed = Base32::Crockford.decode(@value).to_s(16).rjust(32, "0")
          raise ArgumentError if hexed.length > 32

          hexed
        end
      end
    end
  end
end
