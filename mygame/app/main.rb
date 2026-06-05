require 'lib/simple_ldtk/level'
require 'app/camera'
require 'app/player'
require 'app/mob'

module Main
  class Game
    attr_dr
    attr_accessor :level, :camera, :player, :scene, :initiated

    def tick
      init unless initiated
      handle_inputs
      update
      render
    end

    def init
      create_level
      create_camera
      create_player

      self.initiated = true
    end

    def handle_inputs
      camera.handle_camera_inputs(args)
    end

    def update
      player.tick(args)
      args.state.mob.tick(args) if args.state.mob
      camera.follow(player, level)
    end

    def render
      scene = outputs[:scene]
      scene.w = level.width
      scene.h = level.height

      # args.state.mob ||= Mob.new

      scene.sprites << level.tilemap
      scene.sprites << player.animation_sprite
      scene.sprites << args.state.mob.animation_sprite if args.state.mob

      # scene.debug << level.debug_int_grid do |debug|
      #  debug.int_grid 'Collisions', type: :solid, color: [255, 0, 0]
      #  debug.int_grid 'Collisions', type: :ladder, color: [0, 255, 255]
      # end

      outputs.sprites << camera.viewport_for(:scene)
    end

    private

    def create_level
      self.level = ::SimpleLdtk::Level.load('maps/city') do |config|
        config.tile_size = 8

        config.int_grid 'Collisions' do |grid|
          grid.value 1, as: :solid
          grid.value 2, as: :mob_trigger
        end

        config.entity 'Player' do |e|
          Player.new(x: e.x, y: e.y, w: e.w, h: e.h)
        end
      end
    end

    def create_camera
      self.camera = Camera.new
    end

    def create_player
      self.player = level.entity('Player')
    end
  end

  def tick(args)
    $game ||= Game.new
    $game.args = args
    $game.tick
  end
end
