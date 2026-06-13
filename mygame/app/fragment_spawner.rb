class FragmentSpawner
  attr_dr

  ITEM_W = 16
  ITEM_H = 16
  MIN_PLAYER_DISTANCE = 30

  attr_reader :fragments

  def initialize
    @fragments = []
    @spawn_limit = 1
    # pretty jank, but i just want to move on
    @fragment_id = 1
  end

  def update
    spawn_item

    # @fragments.each(&:tick)
  end

  def render(scene)
    scene.sprites << @fragments.map(&:animation_sprite)
  end

  private

  def spawn_points
    @spawn_points ||= world.all_cells_for('MobSpawns')
  end

  def spawn_item
    return if @fragments.size >= @spawn_limit

    spawn_point = valid_spawn_points.sample

    return unless spawn_point

    fragment = Fragment.new(@fragment_id, x: spawn_point.x, y: spawn_point.y, w: ITEM_W, h: ITEM_H)
    fragment.args = args

    @fragment_id += 1
    @fragments << fragment
  end

  def remove_fragment(fragment)
    @fragments.reject! { |f| f.id == fragment.id }
  end

  def player
    state.game.player
  end

  def world
    state.game.level
  end

  def valid_spawn_points
    spawn_points.select { |sp| valid_spawn_point?(sp) }
  end

  def valid_spawn_point?(spawn_point)
    rect = {
      x: spawn_point.x,
      y: spawn_point.y,
      w: ITEM_W,
      h: ITEM_H
    }

    # If im reasoning about this right, this will just skip the spawn this tick, which I think is
    # completely fine
    inbounds?(rect) && away_from_player?(rect) && !solid_at?(rect)
  end

  def solid_at?(rect)
    world.collides?(rect, grid_name: 'Collisions', type: :solid)
  end

  def away_from_player?(rect)
    distance_squared(rect_center(rect), rect_center(player)) >= MIN_PLAYER_DISTANCE * MIN_PLAYER_DISTANCE
  end

  def inbounds?(rect)
    rect.x >= 0 && rect.y >= 0 && rect.x + rect.w <= world.width && rect.y + rect.h <= world.height
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
