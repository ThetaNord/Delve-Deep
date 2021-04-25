class Stairs

  attr_accessor :direction, :x, :y

  def sprite_index
    if @direction == "down" then
      return 0
    else
      return 1
    end
  end

  def get_direction
    return @direction
  end

end
