require 'ulid/rails/formatter'

RAILS_BELOW_5 = ActiveRecord::VERSION::MAJOR < 5

if RAILS_BELOW_5
  require 'active_record/type'
  TYPE_BINARY = ActiveRecord::Type::Binary
else
  require 'active_model/type'
  TYPE_BINARY = ActiveModel::Type::Binary
end

module ULID
  module Rails
    class Type < TYPE_BINARY
      class Data < TYPE_BINARY::Data
        alias hex to_s
      end

      def initialize(formatter = Formatter)
        @formatter = formatter
        super()
      end

      if RAILS_BELOW_5
        def type_cast(value)
          return nil if value.nil?

          value = value.to_s if value.is_a?(Data)
          value = value.unpack1('H*') if value.encoding == Encoding::ASCII_8BIT && value.length == 16
          value = value[2..-1] if value.start_with?('\\x')

          value.length == 32 ? @formatter.format(value) : super
        end

        def type_cast_for_database(value)
          return if value.nil?

          case ActiveRecord::Base.connection_config[:adapter]
          when 'sqlite3'.freeze
            value
          when 'mysql2'.freeze
            Data.new(@formatter.unformat(value))
          when 'postgresql'.freeze
            Data.new([@formatter.unformat(value)].pack("H*"))
          end
        end
      end

      unless RAILS_BELOW_5
        def cast(value)
          return nil if value.nil?

          value = value.to_s if value.is_a?(Data)
          value = value.unpack1('H*') if value.encoding == Encoding::ASCII_8BIT
          value = value[2..-1] if value.start_with?('\\x')

          value.length == 32 ? @formatter.format(value) : super
        end

        def serialize(value)
          return if value.nil?

          case ActiveRecord::Base.connection_config[:adapter]
          when 'mysql2', 'sqlite3'
            Data.new(@formatter.unformat(value))
          when 'postgresql'
            Data.new([@formatter.unformat(value)].pack('H*'))
          end
        end
      end
    end
  end
end
