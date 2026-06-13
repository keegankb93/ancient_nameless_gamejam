require 'lib/simple_ldtk/level'
require 'app/camera'
require 'app/player'
require 'app/mob'
require 'app/mob_spawner'
require 'app/fragment'
require 'app/fragment_spawner'

module Main
  class Game
    attr_dr
    attr_accessor :level, :camera, :player, :scene, :mob_spawner, :fragment_spawner

    def start
      create_level
      create_camera
      create_player
      create_mob_spawner
      create_fragment_spawner
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
      fragment_spawner.update
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
      mob_spawner.render(scene)
      scene.sprites << player.animation_sprite
      fragment_spawner.render(scene)

      # scene.debug << level.debug_int_grid do |debug|
      #  debug.int_grid 'Collisions', type: :solid, color: [255, 0, 0]
      #  debug.int_grid 'Collisions', type: :ladder, color: [0, 255, 255]
      # end

      outputs.sprites << camera.viewport_for(:scene)
      render_progress_bar(Grid.allscreen_left + 20, Grid.allscreen_bottom + 20)
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

    def create_fragment_spawner
      self.fragment_spawner = begin
        fs = FragmentSpawner.new
        fs.args = args
        fs
      end
    end

    def create_mob_spawner
      self.mob_spawner = begin
        ms = MobSpawner.new(world: level, player: player)
        ms.args = args
        ms
      end
    end

    def render_progress_bar(x, y, max: 20, w: 200, h: 20)
      current = player.fragments_collected
      ratio = max.zero? ? 0 : current.fdiv(max)
      text = "#{current}/#{max}"
      cx = x + w / 2
      cy = y + h / 2

      # dark track so the fill contrasts
      args.outputs.sprites << { x: x, y: y, w: w, h: h, r: 20, g: 25, b: 35, path: :solid }
      # light blue fill
      args.outputs.sprites << { x: x, y: y, w: (w * ratio).to_i, h: h, r: 90, g: 180, b: 255, path: :solid }
      # bright border
      args.outputs.borders << { x: x, y: y, w: w, h: h, r: 220, g: 230, b: 245 }
      # label
      args.outputs.labels << { x: cx + 1, y: cy - 1, text: text, size_enum: 2,
                               alignment_enum: 1, vertical_alignment_enum: 1,
                               r: 0, g: 0, b: 0 }
      # text
      args.outputs.labels << { x: cx, y: cy, text: text, size_enum: 2,
                               alignment_enum: 1, vertical_alignment_enum: 1,
                               r: 255, g: 255, b: 255 }
    end
  end

  def start(args)
    $game ||= Game.new
    $game.args = args
    $game.start
    args.state.game = $game
  end

  def tick
    $game.tick
  end
end
