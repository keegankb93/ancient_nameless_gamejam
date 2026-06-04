require 'lib/simple_ldtk/configs/int_grid'
require 'lib/simple_ldtk/configs/entity'

module SimpleLdtk
  class Config
    attr_accessor :tile_size

    attr_reader :int_grid_configs, :entity_configs

    def initialize
      @tile_size = 16
      @int_grid_configs = {}
      @entity_configs = {}
    end

    #
    # Defines an integer grid configuration for the given name.
    def int_grid(name)
      grid_config = Configs::IntGrid.new(name)

      yield grid_config if block_given?

      int_grid_configs[name] = grid_config
    end

    #
    # Defines an entity configuration for the given name.
    def entity(name, &block)
      entity_configs[name] = Configs::Entity.new(name, block)
    end
  end
end
