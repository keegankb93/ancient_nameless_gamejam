require 'lib/simple_ldtk/level'
require 'app/camera'
require 'app/player'

module Main
  class Game
    attr_dr
    attr_accessor :level, :camera, :player, :scene, :initted

    def tick
      init unless initted
      handle_inputs
      update
      render
    end

    def init
      create_level
      create_camera
      create_player

      self.initted = true
    end

    def handle_inputs
      camera.handle_camera_inputs(args)
    end

    def update
      player.tick(args)
      camera.follow(player, level)
    end

    def render
      scene = outputs[:scene]
      scene.w = level.width
      scene.h = level.height
      scene.sprites << level.tilemap
      scene.sprites << player

      scene.debug << level.debug_int_grid do |debug|
        debug.int_grid 'Collisions', type: :solid, color: [255, 0, 0]
        debug.int_grid 'Collisions', type: :ladder, color: [0, 255, 255]
      end

      outputs.sprites << camera.viewport_for(:scene)
    end

    private

    def create_level
      @level = ::SimpleLdtk::Level.load('maps/city') do |config|
        config.tile_size = 8

        config.int_grid 'Collisions' do |grid|
          grid.value 1, as: :solid
          grid.value 2, as: :ladder
          grid.value 3, as: :solid
        end

        config.entity 'Player' do |e|
          Player.new(x: e.x, y: e.y, w: e.w, h: e.h, path: :solid, r: 0, g: 0, b: 255)
        end
      end
    end

    def create_camera
      @camera = Camera.new
    end

    def create_player
      @player = level.entity('Player')
    end
  end

  def tick(args)
    $game ||= Game.new
    $game.args = args
    $game.tick
  end
end
