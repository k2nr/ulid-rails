module ULID
  module Rails
    module Patch
      module Migrations
        def virtual_ulid_timestamp(timestamp_column_name, ulid_column_name)
          virtual timestamp_column_name,
            type: :datetime,
            as: "FROM_UNIXTIME(CONV(HEX(#{ulid_column_name} >> 80), 16, 10) / 1000.0)"
        end
      end

      module FixtureSet
        def identify(label, column_type = :integer)
          if column_type == :ulid
            ULID::Rails::Type.new.serialize(label.to_s)
          else
            super
          end
        end
      end
    end
  end
end
