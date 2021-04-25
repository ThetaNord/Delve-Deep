class Ore

  attr_reader :ore, :sprite_index
  attr_accessor :x, :y

  def initialize(x, y, ore)
    @x = x
    @y = y
    @ore = ore
    case @ore
    when :gold
      @sprite_index = 2
    end
  end


end
