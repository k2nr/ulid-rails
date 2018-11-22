require "active_model/type"
require "ulid/rails/formatter"

module ULID
  module Rails
    class Type < ActiveModel::Type::Binary
      class Data < ActiveModel::Type::Binary::Data
        alias_method :hex, :to_s
      end

      def initialize(formatter = Formatter)
        @formatter = formatter
        super()
      end

      def cast(value)
        if value.is_a?(Data)
          @formatter.format(value.to_s)
        elsif value&.encoding == Encoding::ASCII_8BIT
          @formatter.format(value.unpack("H*")[0])
        else
          super
        end
      end

      def serialize(value)
        return if value.nil?
        Data.new(@formatter.unformat(value))
      end
    end
  end
end
