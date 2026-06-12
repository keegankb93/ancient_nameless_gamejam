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

    sheet("#{SPRITE_DIR}/idle.png", columns: 18) do
      anim :idle_down_right, start: [0, 0], frames: 36, hold_for: 15
    end

    sheet("#{SPRITE_DIR}/walk.png", columns: 6) do
      anim :walk_down, start: [0, 0], frames: 11, hold_for: 10
      anim :walk_up, start: [2, 0], frames: 11, hold_for: 10
    end
  end

  switchboard do
    state :spawning, initial: true
    state :idling
    state :wandering do
      before_enter :set_current_direction
      after_exit :clear_directions
    end
    state :blocked

    event :idle do
      transition from: :spawning, to: :wandering, if: :animation_finished?
      transition from: :wandering, to: :idling, if: :finished_wandering?
      transition from: :blocked, to: :idling
    end

    event :wander do
      transition from: :idling, to: :wandering, if: :finished_idling?
    end

    event :block do
      transition from: :wandering, to: :blocked
      after :recover_from_block
    end
  end

  SPEED = 0.5
  WANDER_TIME = 90
  IDLE_TIME = 90
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

    @current_direction = nil
    @available_directions = nil
    @facing = :down

    play_animation :appear
  end

  def tick
    case current_state
    when :spawning
      idle
    when :idling
      idle_behavior
      wander
    when :wandering
      wander_behavior
      idle
    end
  end

  def idle_behavior
    play_animation :idle_down_right
  end

  def wander_behavior
    dx, dy = @current_direction

    update_facing(dx, dy)
    play_animation(:"walk_#{@facing}")

    move_x(dx * SPEED)
    return unless current_state == :wandering

    move_y(dy * SPEED)
    nil unless current_state == :wandering
  end

  private

  def recover_from_block
    # We could probably remove the already known bad direcions out of here, but it's not like this is a heavy op
    @available_directions = DIRECTIONS.select do |dir|
      dx, dy = dir

      next_x = @x + (dx * SPEED)
      next_y = @y + (dy * SPEED)

      can_move_x = can_move?(rect_at(x: next_x, y: @y))
      can_move_y = can_move?(rect_at(x: @x, y: next_y))

      can_move_x && can_move_y
    end

    idle
  end

  def update_facing(_dx, dy)
    return if dy.zero?

    @facing = dy.positive? ? :up : :down
  end

  def set_current_direction
    @current_direction = @available_directions&.sample || DIRECTIONS.sample
  end

  def clear_current_direction
    @current_direction = nil
  end

  def clear_available_directions
    @available_directions = nil
  end

  def clear_directions
    clear_current_direction
    clear_available_directions
  end

  def finished_idling?
    state_elapsed >= IDLE_TIME
  end

  def finished_wandering?
    state_elapsed >= WANDER_TIME
  end

  def state_elapsed
    Kernel.tick_count - state_entered_at
  end

  def rect_at(x:, y:)
    { x: x, y: y, w: @w, h: @h }
  end

  def move_x(dx)
    next_rect = rect_at(x: @x + dx, y: @y)

    unless can_move?(next_rect)
      block
      return
    end

    @x += dx
  end

  def move_y(dy)
    next_rect = rect_at(x: @x, y: @y + dy)

    unless can_move?(next_rect)
      block
      return
    end

    @y += dy
  end

  def can_move?(next_rect)
    inbounds?(next_rect) && !@level.collides?(next_rect, grid_name: 'Collisions', type: :solid)
  end

  def inbounds?(next_rect)
    next_rect.x >= 0 && next_rect.y >= 0 && next_rect.x + next_rect.w <= @level.width && next_rect.y + next_rect.h <= @level.height
  end
end
