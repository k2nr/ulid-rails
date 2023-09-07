require_relative "type"

module ULID
  module Rails
    class PostgresqlType < Type
      class Data < ULID::Rails::Type::Data
        def hex
          hexed = super
          return nil if hexed.nil?
          [hexed].pack("H*")
        end

        alias_method :to_s, :hex
      end

      # Inspired by active_record/connection_adapters/postgresql/oid/bytea
      def deserialize(value)
        case value
        when nil
          nil
        when ULID::Rails::Type::Data
          super(value.value)
        else
          super(PG::Connection.unescape_bytea(value))
        end
      end

      private

      def cast_string_to_ulid(value)
        if value.is_a?(String) && value.length == 34 && value.start_with?("\\x")
          Data.from_serialized(value[2..])
        else
          super(value, data_class: PostgresqlType::Data)
        end
      end
    end
  end
end
