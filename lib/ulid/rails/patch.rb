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
    end
  end
end
