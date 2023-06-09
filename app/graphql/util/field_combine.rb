module Util
  # Renamed from FieldCombiner because of Zeitwerk
  class FieldCombine
    def self.combine(query_types)
      Array(query_types).inject({}) do |acc, query_type|
        acc.merge!(query_type.fields)
      end
    end
  end
end
