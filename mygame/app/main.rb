require 'lib/simple_ldtk/level'
require 'app/camera'
require 'app/player'
require 'app/mob'
require 'app/mob_spawner'

module Main
  class Game
    attr_dr
    attr_accessor :level, :camera, :player, :scene, :mob_spawner

    def initialize
      create_level
      create_camera
      create_player
      create_mob_spawner
    end

    def tick
      handle_inputs
      update
      render
    end

    def handle_inputs
      camera.handle_camera_inputs(args)
    end

    def update
      player.tick(args)
      mob_spawner.update
      # args.state.mob.tick(args) if args.state.mob
      camera.resize_to_screen
      camera.follow(player, level)
    end

    def render
      scene = outputs[:scene]
      scene.w = level.w
      scene.h = level.h

      # args.state.mob ||= Mob.new

      scene.sprites << level.tilemap
      scene.sprites << player.animation_sprite
      mob_spawner.render(scene)

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
        end

        config.int_grid 'MobSpawns' do |grid|
          grid.value 1, as: :mob_spawn
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

    def create_mob_spawner
      self.mob_spawner = begin
        ms = MobSpawner.new(world: level, player: player)
        ms.args = args
        ms
      end
    end
  end

  def tick(args)
    $game ||= Game.new
    $game.args = args
    $game.tick
  end
end
