module SimpleLdtk
  module Configs
    class Entity
      attr_reader :name, :mapper

      def initialize(name, mapper)
        @name = name
        @mapper = mapper
      end

      #
      # Maps the given entity using the users configuration
      def map_entity(entity)
        return entity unless mapper

        mapper.call(entity)
      end
    end
  end
end
