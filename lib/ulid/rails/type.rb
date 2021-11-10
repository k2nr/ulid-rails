require "ulid/rails/formatter"
require "ulid/rails/validator"
require "ulid/rails/errors"
require "ulid/rails/constants"

module ULID
  module Rails
    case RAILS_VERSION
    when "4.2"
      require "active_record/type"
      Binary = ActiveRecord::Type::Binary
    else
      require "active_model/type"
      Binary = ActiveModel::Type::Binary
    end

    class Type < Binary
      class Data < Binary::Data
        alias_method :hex, :to_s
      end

      def initialize(formatter = Formatter, validator = Validator)
        @formatter = formatter
        @validator = validator
        super()
      end

      def assert_valid_value(value)
        raise ArgumentError, "`#{value}` is not a ULID format" unless @validator.is_valid?(value)
      end

      def deserialize(value)
        return nil if value.nil?

        value = value.to_s if value.is_a?(Data)
        value = value.unpack1("H*") if value.encoding == Encoding::ASCII_8BIT
        value = value[2..-1] if value.start_with?("\\x")

        value.length == 32 ? @formatter.format(value) : super
      end

      def serialize(value)
        return if value.nil?

        case adapter
        when "mysql2", "sqlite3"
          Data.new(@formatter.unformat(value))
        when "postgresql"
          Data.new([@formatter.unformat(value)].pack("H*"))
        end
      end

      if RAILS_4_2
        alias_method :type_cast_for_database, :serialize
        alias_method :type_cast_from_database, :deserialize

        def type_cast_from_user(value)
          assert_valid_value(value)
          super
        end
      end

      private

      def adapter
        if ::ActiveRecord::Base.respond_to?(:connection_db_config)
          ::ActiveRecord::Base.connection_db_config.configuration_hash[:adapter]
        else
          ::ActiveRecord::Base.connection_config[:adapter]
        end
      end
    end
  end
end
