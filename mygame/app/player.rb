class Player
  attr_sprite

  def initialize(x:, y:, w:, h:, path: :solid, r: 0, g: 0, b: 255)
    @x = x
    @y = y
    @w = w
    @h = h
    @path = path
    @r = r
    @g = g
    @b = b
  end

  def tick(args)
    direction = args.inputs.directional_angle
    return unless direction

    dx = direction.vector_x * 2
    dy = direction.vector_y * 2
    level = $game.level

    move_x(dx, level)
    move_y(dy, level)

    @x = @x.clamp(0, level.width - @w)
    @y = @y.clamp(0, level.height - @h)
  end

  private

  def move_x(dx, level)
    next_rect = rect_at(x: @x + dx, y: @y)
    @x += dx unless level.collides?(next_rect)
  end

  def move_y(dy, level)
    next_rect = rect_at(x: @x, y: @y + dy)
    @y += dy unless level.collides?(next_rect)
  end

  def rect_at(x:, y:)
    { x: x, y: y, w: @w, h: @h }
  end
end
