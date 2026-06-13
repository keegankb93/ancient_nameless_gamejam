require 'lib/animatable'

class Player
  include Animatable

  attr_sprite

  define_animations(tile_w: 16, tile_h: 16) do
    folder('sprites/characters/player') do
      anim :idle_up,   frames: 1, hold_for: 1
      anim :idle_down, frames: 1, hold_for: 1
      anim :idle_side, frames: 1, hold_for: 1
      anim :walk_up,   frames: 4, hold_for: 20, start_frame: 1
      anim :walk_down, frames: 4, hold_for: 20, start_frame: 1
      anim :walk_side, frames: 4, hold_for: 20, start_frame: 1
    end
  end

  attr_reader :fragments_collected

  def initialize(x:, y:, w:, h:)
    @x = x
    @y = y
    @w = w
    @h = h

    @facing = :down
    @side_direction = 1
    @fragments_collected = 0

    play_animation(:idle_down)
  end

  def tick(args)
    dx = 0
    dy = 0

    dx += 1 if args.inputs.keyboard.right
    dx -= 1 if args.inputs.keyboard.left
    dy += 1 if args.inputs.keyboard.up
    dy -= 1 if args.inputs.keyboard.down

    unless dx != 0 || dy != 0
      play_animation(:"idle_#{@facing}")

      return
    end

    update_facing(dx, dy)
    play_animation(:"walk_#{@facing}")

    speed = 1
    level = $game.level

    move_x(dx * speed, level)
    move_y(dy * speed, level)

    handle_fragment_collision

    @x = @x.clamp(0, level.width - @w)
    @y = @y.clamp(0, level.height - @h)
  end

  def collect_fragment(fragment)
    @fragments_collected += 1

    fragment_spawner.remove_fragment(fragment)
  end

  def handle_fragment_collision
    fragment = Geometry.find_intersect_rect(rect_at(x: @x, y: @y), fragment_spawner.fragments)

    return unless fragment

    collect_fragment(fragment)
  end

  def fragment_spawner
    $game.fragment_spawner
  end

  def flip_animation?
    @facing == :side && @side_direction.negative?
  end

  def center_x
    @x + (@w * 0.5)
  end

  def center_y
    @y + (@h * 0.5)
  end

  private

  def update_facing(dx, dy)
    if dx != 0
      @facing = :side
      @side_direction = dx
    elsif dy.positive?
      @facing = :up
    elsif dy.negative?
      @facing = :down
    end
  end

  # TODO: Clean up this class and the level arg

  def move_x(dx, level)
    next_rect = rect_at(x: @x + dx, y: @y)

    @x += dx if can_move?(next_rect, level)
  end

  def move_y(dy, level)
    next_rect = rect_at(x: @x, y: @y + dy)

    @y += dy if can_move?(next_rect, level)
  end

  def can_move?(next_rect, level)
    !level.collides?(next_rect, grid_name: 'Collisions', type: :solid)
  end

  def rect_at(x:, y:)
    { x: x, y: y, w: @w, h: @h }
  end
end
