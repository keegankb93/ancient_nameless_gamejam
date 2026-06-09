class MobSpawner
  attr_dr

  MIN_PLAYER_DISTANCE = 15
  MOB_W = 32
  MOB_H = 32

  def initialize(world:, player:)
    @world = world
    @player = player
    @mobs = []
    @spawn_limit = 10
    @last_spawn_time = nil
  end

  def update
    spawn_mob

    @mobs.each(&:tick)
  end

  def render(scene)
    scene.sprites << @mobs.map(&:animation_sprite)
  end

  private

  def spawn_points
    @spawn_points ||= @world.all_cells_for('MobSpawns')
  end

  def spawn_mob
    return if @mobs.size >= @spawn_limit
    return if @last_spawn_time && Kernel.tick_count - @last_spawn_time < 90

    spawn_point = valid_spawn_points.sample
    return unless spawn_point

    @mobs << Mob.new(x: spawn_point.x, y: spawn_point.y, w: MOB_W, h: MOB_H)
    @last_spawn_time = Kernel.tick_count
  end

  def valid_spawn_points
    spawn_points.select do |spawn_point|
      valid_spawn_point?(spawn_point)
    end
  end

  def valid_spawn_point?(spawn_point)
    rect = {
      x: spawn_point.x,
      y: spawn_point.y,
      w: MOB_W,
      h: MOB_H
    }

    # If im reasoning about this right, this will just skip the spawn this tick, which I think is
    # completely fine
    inbounds?(rect) && away_from_player?(rect) && !solid_at?(rect)
  end

  def solid_at?(rect)
    @world.collides?(rect, grid_name: 'Collisions', type: :solid)
  end

  def away_from_player?(rect)
    distance_squared(rect_center(rect), rect_center(@player)) >= MIN_PLAYER_DISTANCE * MIN_PLAYER_DISTANCE
  end

  def inbounds?(rect)
    rect.x >= 0 && rect.y >= 0 && rect.x + rect.w <= @world.width && rect.y + rect.h <= @world.height
  end

  def rect_center(rect)
    {
      x: rect.x + rect.w / 2,
      y: rect.y + rect.h / 2
    }
  end

  def distance_squared(a, b)
    dx = a.x - b.x
    dy = a.y - b.y

    dx * dx + dy * dy
  end
end
