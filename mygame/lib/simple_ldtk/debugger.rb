module SimpleLdtk
  module Debugger
    # If this pattern starts growing we can extract out
    IntGridDebug = Struct.new(:level, :primitives) do
      def int_grid(name, type:, color: [255, 0, 0])
        primitives.concat(
          level.draw_int_grid(name, type: type, color: color)
        )
      end
    end

    def debug_int_grid
      primitives = []

      yield IntGridDebug.new(self, primitives)

      primitives
    end

    #
    # Draws a border around the cells of the given type in the int_grid.
    def draw_int_grid(name, type:, color: [255, 0, 0])
      r, g, b = color

      cells_for_type(name, type).map do |cell|
        {
          x: cell[:x],
          y: cell[:y],
          w: cell[:w],
          h: cell[:h],
          r: r,
          g: g,
          b: b,
          primitive_marker: :border
        }
      end
    end
  end
end
