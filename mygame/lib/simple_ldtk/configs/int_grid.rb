module SimpleLdtk
  module Configs
    class IntGrid
      attr_reader :name, :values

      def initialize(name)
        @name = name
        @values = {}
      end

      def value(raw_value, as:)
        values[raw_value] = as
      end

      def type_for(raw_value)
        values[raw_value]
      end
    end
  end
end
