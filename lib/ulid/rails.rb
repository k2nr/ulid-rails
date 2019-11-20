require "active_record"
require "active_support/concern"
require "active_model/type"
require "ulid"
require "base32/crockford"
require "ulid/rails/version"
require "ulid/rails/type"
require "ulid/rails/patch"

module ULID
  module Rails
    extend ActiveSupport::Concern

    class_methods do
      def ulid(column_name = :id, primary_key: false, auto_generate: false)
        attribute column_name, ULID::Rails::Type.new

        before_create do
          send("#{column_name}=", ULID.generate) if send(column_name).nil? && auto_generate
        end

        if primary_key
          define_method :created_at do
            at = super() rescue nil
            if !at && (id_val = send(column_name))
              Time.zone.at((Base32::Crockford.decode(id_val) >> 80) / 1000.0)
            else
              at
            end
          end

          define_singleton_method(:timestamp_attributes_for_create) do
            []
          end
        end
      end
    end

    ActiveModel::Type.register(:ulid, ULID::Rails::Type)
    ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Patch::Migrations
  end
end
