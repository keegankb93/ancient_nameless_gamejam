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
      after_exit :clear_current_direction
    end
    state :blocked

    event :spawn_finished do
      transition from: :spawning, to: :idling
    end

    event :idle_finished, if: :finished_idling do
      transition from: :idling, to: :wandering
    end

    # For now it doesn't really seem that bad if they try to run into a wall again
    # I'm not going to add extra code unless it becomes a gameplay problem
    # event :wander_blocked do
    #   transition from: :wandering, to: :blocked
    # end

    event :wander_finished, if: :finished_wandering do
      transition from: :wandering, to: :idling
    end
  end

  SPEED = 0.5
  WANDER_TIME = 90
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

    @current_direction = nil
    @facing = :down

    play_animation :appear
  end

  def tick
    case current_state
    when :spawning
      spawn_finished if animation_finished?
    when :idling
      idle
    when :wandering
      wander
    end
  end

  def idle
    play_animation :idle_down_right

    idle_finished
  end

  def wander
    dx, dy = @current_direction

    update_facing(dx, dy)
    play_animation(:"walk_#{@facing}")

    move_x(dx * SPEED)
    move_y(dy * SPEED)

    wander_finished
  end

  private

  def update_facing(_dx, dy)
    return if dy.zero?

    @facing = dy.positive? ? :up : :down
  end

  def set_current_direction
    @current_direction = DIRECTIONS.sample
  end

  def clear_current_direction
    @current_direction = nil
  end

  def finished_idling
    state_elapsed >= IDLE_TIME
  end

  def finished_wandering
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

    @x += dx if can_move?(next_rect)
  end

  def move_y(dy)
    next_rect = rect_at(x: @x, y: @y + dy)

    @y += dy if can_move?(next_rect)
  end

  def can_move?(next_rect)
    inbounds?(next_rect) && !@level.collides?(next_rect, grid_name: 'Collisions', type: :solid)
  end

  def inbounds?(next_rect)
    next_rect.x >= 0 && next_rect.y >= 0 && next_rect.x + next_rect.w <= @level.width && next_rect.y + next_rect.h <= @level.height
  end
end
