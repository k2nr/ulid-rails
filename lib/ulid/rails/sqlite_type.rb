require_relative "type"

module ULID
  module Rails
    class SqliteType < Type
      class Data < ULID::Rails::Type::Data
        alias_method :to_s, :hex
      end

      private

      def cast_string_to_ulid(value)
        if value.is_a?(String) && value.length == 32
          Data.from_serialized(value)
        else
          super(value, data_class: SqliteType::Data)
        end
      end
    end
  end
end
