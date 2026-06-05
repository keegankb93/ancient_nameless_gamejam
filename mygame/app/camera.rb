class Camera
  attr_accessor :x, :y, :w, :h, :scale, :show_empty_space

  def initialize(x: 0, y: 0, w: 1280, h: 720, scale: 3.0, show_empty_space: :yes)
    @x = x
    @y = y
    @w = w
    @h = h
    @scale = scale
    @show_empty_space = show_empty_space
  end

  #
  # Returns the width of the camera viewport in world pixels
  # This shrinks as the camera scale increases, creating the zoom-in effect
  def source_w
    w / scale
  end

  #
  # Returns the height of the camera viewport in world pixels
  # This shrinks as the camera scale increases, creating the zoom-in effect
  def source_h
    h / scale
  end

  #
  # Returns the sprite used to render the scene render target to the screen
  # The source values control which part of the world the camera is looking at
  def viewport_for(target_path)
    {
      x: 0,
      y: 0,
      w: w,
      h: h,
      path: target_path,
      source_x: x,
      source_y: y,
      source_w: source_w,
      source_h: source_h
    }
  end

  #
  # Handles camera-specific keyboard input
  # Allows zooming in/out and toggling whether empty space outside the map is shown
  def handle_camera_inputs(args)
    if args.inputs.keyboard.plus && Kernel.tick_count.zmod?(3)
      self.scale += 0.1
    elsif args.inputs.keyboard.hyphen && Kernel.tick_count.zmod?(3)
      self.scale -= 0.1
    elsif args.inputs.keyboard.key_down.tab
      self.show_empty_space = if show_empty_space == :yes
                                :no
                              else
                                :yes
                              end
    end

    self.scale = scale.clamp(min_scale_for($game.level), 8.0)
  end

  #
  # Centers the camera on the given target
  # Clamps afterward so the camera does not show outside the world bounds
  def follow(target, world)
    @x = target.x - source_w.half
    @y = target.y - source_h.half

    clamp_to_world(world)
  end

  #
  # Returns the minimum scale needed to keep the world filling the screen
  # Prevents zooming out so far that empty space appears around the whole map
  def min_scale_for(world)
    [
      w.fdiv(world.width),
      h.fdiv(world.height)
    ].max
  end

  #
  # Keeps the camera viewport inside the world bounds
  # The max calls handle maps smaller than the current camera viewport
  def clamp_to_world(world)
    @x = @x.clamp(0, [world.width - source_w, 0].max).lerp(0, 0.25)
    @y = @y.clamp(0, [world.height - source_h, 0].max).lerp(0, 0.25)
  end
end
