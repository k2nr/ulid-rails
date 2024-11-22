require "active_record"
require "active_record/fixtures"
require "active_support/concern"
require "active_model/type"
require "ulid"
require "base32/crockford"
require "ulid/rails/version"
require "ulid/rails/type"
require "ulid/rails/postgresql_type"
require "ulid/rails/sqlite_type"
require "ulid/rails/patch"

module ULID
  module Rails
    extend ActiveSupport::Concern

    class_methods do
      def ulid(column_name, auto_generate: false)
        attribute column_name, :ulid

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

    ActiveRecord::Type.register(:ulid, ULID::Rails::Type, override: false)
    ActiveRecord::Type.register(:ulid, ULID::Rails::PostgresqlType, adapter: :postgresql)
    ActiveRecord::Type.register(:ulid, ULID::Rails::SqliteType, adapter: :sqlite)
    ActiveRecord::Type.register(:ulid, ULID::Rails::SqliteType, adapter: :sqlite3)
    ActiveRecord::ConnectionAdapters::TableDefinition.include(Patch::Migrations)
    ActiveRecord::FixtureSet.singleton_class.prepend(Patch::FixtureSet)
  end
end
