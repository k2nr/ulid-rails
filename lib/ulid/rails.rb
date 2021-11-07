require "active_record"
require "active_support/concern"
require "ulid"
require "base32/crockford"
require "ulid/rails/version"
require "ulid/rails/type"
require "ulid/rails/patch"

module ULID
  module Rails
    extend ActiveSupport::Concern

    class_methods do
      def ulid(column_name, primary_key: false, auto_generate: nil)
        attribute column_name, ULID::Rails::Type.new

        auto_generate = primary_key || auto_generate
        if auto_generate
          before_create do
            send("#{column_name}=", ULID.generate) if send(column_name).nil?
          end
        end
      end

      def ulid_extract_timestamp(ulid_column, timestamp_column = :created_at)
        define_method timestamp_column do
          at = begin
            super()
          rescue
            nil
          end
          if !at && (id_val = send(ulid_column))
            Time.zone.at((Base32::Crockford.decode(id_val) >> 80) / 1000.0)
          else
            at
          end
        end

        if timestamp_column.to_s == "created_at"
          define_singleton_method(:timestamp_attributes_for_create) do
            []
          end
        end
      end
    end

    case "#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"
    when "4.2"
      # Fixes missing primary_key in Rails 4.2 with mysql,sqlite adapter
      # https://github.com/rails/rails/commit/3cbfba6881fca957c62fecfc9467afd459f5a554
      ActiveRecord::ConnectionAdapters::AbstractAdapter::SchemaCreation.prepend(
        Module.new do
          def visit_ColumnDefinition(o)
            column_sql = super
            return column_sql if o.type == :primary_key

            adapter = ::ActiveRecord::Base.respond_to?(:connection_db_config) ? ::ActiveRecord::Base.connection_db_config.configuration_hash[:adapter] : ::ActiveRecord::Base.connection_config[:adapter]

            column_sql << " PRIMARY KEY" if o.primary_key == true && adapter != "postgresql"

            column_sql
          end
        end
      )
    else
      require "active_model/type"
      ActiveModel::Type.register(:ulid, ULID::Rails::Type)
    end

    ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Patch::Migrations
  end
end
