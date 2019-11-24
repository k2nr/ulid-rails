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
        return nil if value.nil?

        value = value.to_s if value.is_a?(Data)
        value = value.unpack("H*")[0] if value.encoding == Encoding::ASCII_8BIT
        value = value[2..] if value.start_with?("\\x")

        value.length == 32 ? @formatter.format(value) : super
      end

      def serialize(value)
        return if value.nil?

        case ActiveRecord::Base.connection_config[:adapter]
        when "mysql2", "sqlite3"
          Data.new(@formatter.unformat(value))
        when "postgresql"
          Data.new([@formatter.unformat(value)].pack("H*"))
        end
      end
    end
  end
end
