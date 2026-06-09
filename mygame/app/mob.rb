require 'lib/animatable'
require 'lib/switchboard'

class Mob
  include Switchboard
  include Animatable
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
    state :chasing
    state :searching

    event :spawn do
      transition from: :spawning, to: :idling
    end

    event :spot_target do
      transition from: %i[idling searching], to: :chasing
    end

    event :lose_target do
      transition from: :chasing, to: :searching
    end

    event :give_up do
      transition from: :searching, to: :idling
    end
  end

  SIGHT_RANGE = 160
  SIGHT_STEP = 8
  SPEED = 0.5

  attr_accessor :target

  def initialize(level:, x: 200, y: 100, w: 32, h: 32, target: nil)
    @level = level
    @target = target
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
    when :chasing
      chase
    when :searching
      search
    end
  end

  def idle
    play_animation :idle_down_right

    spot_target if can_see_target?
  end

  def chase
    unless can_see_target?
      lose_target
      return
    end

    @target_x = target.x
    @target_y = target.y

    chase_target
  end

  def search
    if can_see_target?
      spot_target
      return
    end

    unless @target_x && @target_y
      give_up
      return
    end

    chase_target

    give_up if close_to?(@target_x, @target_y)
  end

  private

  def can_see_target?
    return false unless target
    return false unless within_sight_range?

    clear_line_of_sight?
  end

  def chase_target
    dx = @target_x - @x
    dy = @target_y - @y

    length = Math.sqrt((dx * dx) + (dy * dy))
    return if length.zero?

    vx = dx / length
    vy = dy / length

    move_x(vx * SPEED)
    move_y(vy * SPEED)

    play_animation :walk_down
  end

  def move_x(dx)
    next_rect = rect_at(x: @x + dx, y: @y)

    @x += dx unless solid?(next_rect)
  end

  def move_y(dy)
    next_rect = rect_at(x: @x, y: @y + dy)

    @y += dy unless solid?(next_rect)
  end

  def solid?(rect)
    @level.collides?(rect, grid_name: 'Collisions', type: :solid)
  end

  def close_to?(x, y)
    (@x - x).abs < 4 && (@y - y).abs < 4
  end

  def rect_at(x:, y:)
    {
      x: x,
      y: y,
      w: @w,
      h: @h
    }
  end

  def within_sight_range?
    distance_squared(center_x, center_y, target.center_x, target.center_y) <= SIGHT_RANGE * SIGHT_RANGE
  end

  def distance_squared(ax, ay, bx, by)
    dx = ax - bx
    dy = ay - by

    dx * dx + dy * dy
  end

  def center_x
    @x + (@w * 0.5)
  end

  def center_y
    @y + (@h * 0.5)
  end

  def clear_line_of_sight?
    start_x = center_x # 10
    start_y = center_y # 10

    end_x = target.center_x # 5
    end_y = target.center_y # 5

    dx = end_x - start_x # 5 - 10 = -5
    dy = end_y - start_y # 5 - 10 = -5

    distance = Math.sqrt((dx * dx) + (dy * dy)) # 5 * 5 + 5 * 5 = 50 -> sqrt(50) = 7.07
    steps = (distance / SIGHT_STEP).ceil # 7.07 / 8 = 0.88 -> ceil = 1 "grid tile"

    1.upto(steps) do |i|
      t = i / steps.to_f

      x = start_x + dx * t
      y = start_y + dy * t

      return false if sight_blocked_at?(x, y)
    end

    true
  end

  def sight_blocked_at?(x, y)
    sight_rect = {
      x: x,
      y: y,
      w: 2,
      h: 2
    }

    @level.collides?(sight_rect, grid_name: 'Collisions', type: :solid)
  end
end
