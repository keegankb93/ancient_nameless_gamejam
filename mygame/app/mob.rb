require 'lib/animatable'
require 'lib/body'
require 'lib/switchboard'

class Mob
  include Switchboard
  include Animatable
  include Body
  attr_sprite

  SPRITE_DIR = 'sprites/mobs/observer'

  define_animations(tile_w: 32, tile_h: 32) do
    sheet("#{SPRITE_DIR}/appear.png", columns: 32) do
      anim :appear, start: [0, 0], frames: 17, hold_for: 5, repeat: false
    end

    sheet("#{SPRITE_DIR}/idle.png", columns: 6) do
      anim :idle_down_right, start: [0, 0], frames: 18, hold_for: 10
    end

    sheet("#{SPRITE_DIR}/walk.png", columns: 6) do
      anim :walk_up, start: [3, 0], frames: 4, hold_for: 20
      anim :walk_down, start: [0, 0], frames: 6, hold_for: 10
    end
  end

  switchboard do
    state :spawning, initial: true
    state :idling

    event :spawn do
      transition from: :spawning, to: :idling
    end
  end

  SPEED = 0.5
  MOVE_TIME = 90
  IDLE_TIME = 30
  COLLISION_W = 20
  COLLISION_H = 20
  DIRECTIONS = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
    [-1, -1],
    [-1, 1],
    [1, -1],
    [1, 1]
  ]

  attr_accessor :neighbors

  def initialize(level:, x: 200, y: 100, w: 32, h: 32)
    @level = level
    @neighbors = []
    @x = x
    @y = y
    @w = w
    @h = h

    play_animation :appear
  end

  def tick
    case current_state
    when :spawning
      spawn if animation_finished?
    when :idling
      idle
    end
  end

  def idle
    wander
  end

  def collision_rect
    collision_rect_for(rect)
  end

  def inbounds?
    @x + @w >= 0 && @y + @h >= 0 && @x <= @level.width && @y <= @level.height
  end

  private

  def wander
    if resting?
      play_animation :idle_down_right
      return
    end

    if move_time_finished?
      rest
      play_animation :idle_down_right
      return
    end

    pick_direction unless @direction_x

    moved = move_in_any_direction

    rest unless moved

    play_animation(moved ? :walk_down : :idle_down_right)
  end

  def resting?
    return false unless @rest_until
    return true if Kernel.tick_count < @rest_until

    @rest_until = nil
    false
  end

  def move_time_finished?
    @change_direction_at && Kernel.tick_count >= @change_direction_at
  end

  def rest
    @direction_x = nil
    @direction_y = nil
    @change_direction_at = nil
    @rest_until = Kernel.tick_count + IDLE_TIME
  end

  def pick_direction(direction = DIRECTIONS.sample)
    @direction_x, @direction_y = direction
    @change_direction_at = Kernel.tick_count + MOVE_TIME
  end

  def move_in_any_direction
    return true if move_in_current_direction

    DIRECTIONS.shuffle.each do |direction|
      next if direction == [@direction_x, @direction_y]

      pick_direction(direction)
      return true if move_in_current_direction
    end

    false
  end

  def move_in_current_direction
    try_move(@direction_x * SPEED, @direction_y * SPEED)
  end

  def try_move(dx, dy)
    future = future_position(dx, dy)
    collision = future_collision(future)
    moved = false

    unless collision.dx_collision
      @x = collision.x
      moved = true
    end

    unless collision.dy_collision
      @y = collision.y
      moved = true
    end

    moved
  end

  def future_position(dx, dy)
    {
      dx: rect_at(x: @x + dx, y: @y),
      dy: rect_at(x: @x, y: @y + dy)
    }
  end

  def future_collision(future)
    {
      dx_collision: blocked?(future.dx),
      x: future.dx.x,
      dy_collision: blocked?(future.dy),
      y: future.dy.y
    }
  end

  def blocked?(rect)
    solid?(rect) || mob_at?(collision_rect_for(rect))
  end

  def solid?(rect)
    @level.collides?(rect, grid_name: 'Collisions', type: :solid)
  end

  def mob_at?(rect)
    current = collision_rect

    neighbors.any? do |mob|
      next false if mob.equal?(self)
      next false if current.intersect_rect?(mob.collision_rect)

      rect.intersect_rect?(mob.collision_rect)
    end
  end

  def collision_rect_for(source)
    {
      x: source.x + ((source.w - COLLISION_W) * 0.5),
      y: source.y + ((source.h - COLLISION_H) * 0.5),
      w: COLLISION_W,
      h: COLLISION_H
    }
  end
end
