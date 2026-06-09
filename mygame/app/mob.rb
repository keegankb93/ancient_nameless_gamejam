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

    event :spawn do
      transition from: :spawning, to: :idling
    end

    event :idle do
      transition from: :idling, to: :idling
    end
  end

  def initialize(x: 200, y: 100, w: 32, h: 32)
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
      play_animation :idle_down_right
    end
  end
end
