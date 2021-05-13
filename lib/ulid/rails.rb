require "active_record"
require "active_support/concern"
require "ulid"
require "base32/crockford"
require "ulid/rails/version"
require "ulid/rails/type"
require "ulid/rails/patch"

RAILS_BELOW_5 = ActiveRecord::VERSION::MAJOR < 5

if RAILS_BELOW_5
  require 'active_record/type'
else
  require 'active_model/type'
end

module ULID
  module Rails
    extend ActiveSupport::Concern

    class_methods do
      def ulid(column_name, primary_key: false, auto_generate: nil)
        attribute column_name, ULID::Rails::Type.new

        auto_generate = primary_key ? primary_key : auto_generate
        if auto_generate
          before_create do
            send("#{column_name}=", ULID.generate) if send(column_name).nil?
          end
        end
      end

      def ulid_extract_timestamp(ulid_column, timestamp_column = :created_at)
        define_method timestamp_column do
          at = super() rescue nil
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

    ActiveModel::Type.register(:ulid, ULID::Rails::Type) unless RAILS_BELOW_5
    ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Patch::Migrations
  end
end
