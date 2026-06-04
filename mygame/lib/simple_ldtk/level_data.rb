module SimpleLdtk
  #
  # Represents the data for a single level
  class LevelData
    attr_reader :dir,
                :data,
                :width,
                :height,
                :bg_color,
                :composite_path,
                :int_grids,
                :entities

    def initialize(dir:, data:, composite_path:, int_grids:, entities:)
      @dir = dir
      @data = data
      @width = data['width']
      @height = data['height']
      @bg_color = data['bgColor']
      @composite_path = composite_path
      @int_grids = int_grids
      @entities = entities
    end

    #
    # This is the composite image for the level set to a default of 0,0
    # Width and height are taken from the level data and the composite path
    # is set when the level is loaded.
    def tilemap(x: 0, y: 0)
      {
        x: x,
        y: y,
        w: width,
        h: height,
        path: composite_path
      }
    end

    #
    # Returns the integer grid for the given name.
    def int_grid(name)
      int_grids[name] || []
    end

    #
    # Returns all entities of the given name.
    def entities_for(name)
      entities[name] || []
    end

    #
    # Returns the first entity of the given name.
    # Mainly a helper for entities where you know you will only have one of a given type.
    # For example, you might have a single player entity, so you can call `entity('Player')` to get it.
    def entity(name)
      entities_for(name).first
    end

    #
    # Returns all cells of the given type for the given grid.
    # example: cells_for(:collisions, :solid) will return all solid collision cells for the collisions grid.
    #
    # We probably don't need to memoize this into a registry unless we see use cases where
    # we're calling the same grid/type combination multiple times.
    def cells_for(grid_name, type)
      int_grid(grid_name).select { |cell| cell[:type] == type }
    end

    # Quick and dirty collision detection
    def collides?(rect, grid_name: 'Collisions', type: :solid)
      cells_for(grid_name, type).any? do |cell|
        rect.intersect_rect?(cell)
      end
    end
  end
end
