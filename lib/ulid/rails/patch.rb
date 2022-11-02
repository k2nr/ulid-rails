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

      module FinderMethods
        def limited_ids_for(relation)
          id_rows = super
          if klass.attribute_types[primary_key].is_a? ULID::Rails::Type
            id_rows.map do |id|
              klass.attribute_types[primary_key].deserialize id
            end
          else
            id_rows
          end
        end
      end

      module SchemaStatements
        def distinct_relation_for_primary_key(relation) # :nodoc:
          values = columns_for_distinct(
            visitor.compile(relation.table[relation.primary_key]),
            relation.order_values
          )

          limited = relation.reselect(values).distinct!
          limited_ids = select_rows(limited.arel, "SQL").map(&:last)

          if relation.klass.attribute_types[relation.primary_key].is_a? ULID::Rails::Type
            limited_ids.map! do |id|
              relation.klass.attribute_types[relation.primary_key].deserialize id
            end
          end

          if limited_ids.empty?
            relation.none!
          else
            relation.where!(relation.primary_key => limited_ids)
          end

          relation.limit_value = relation.offset_value = nil
          relation
        end
      end
    end
  end
end
