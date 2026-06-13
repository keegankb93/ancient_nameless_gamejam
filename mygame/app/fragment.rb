class Fragment
  attr_dr
  attr_sprite

  FLOAT_AMOUNT = 3
  FLOAT_DURATION = 40

  def initialize(id, x: 200, y: 100, w: 16, h: 16)
    @id = id
    @x = x
    @y = y
    @base_y = y
    @w = w
    @h = h
    @path = 'sprites/fragment.png'
  end

  def animation_sprite
    {
      x: @x,
      y: float,
      w: @w,
      h: @h,
      path: @path
    }
  end

  private

  def float
    half = FLOAT_DURATION / 2
    tick = Kernel.tick_count % FLOAT_DURATION

    if tick < half
      @y + Easing.smooth_step(
        initial: 0,
        final: FLOAT_AMOUNT,
        perc: tick.fdiv(half),
        power: 2
      )
    else
      @y + Easing.smooth_step(
        initial: FLOAT_AMOUNT,
        final: 0,
        perc: (tick - half).fdiv(half),
        power: 2
      )
    end
  end
end
