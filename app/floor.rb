require 'app/tile.rb'

class Floor

  attr_accessor :floor_number
  attr_reader :map,:width, :height

  def initialize
    @map = Array.new
  end

  def generate(w, h)
    @width = w
    @height = h
    float_map = Array.new(@width)
    # Create a map of random floats
    for i in 0..@width-1 do
      float_map[i] = Array.new(@height) {|x| x = rand}
    end
    #puts float_map
    # Generate tiles based on the float map
    for i in 0..@width-1 do
      @map << Array.new
      for j in 0..@height-1 do
        tile = Tile.new
        tile.set_terrain_value(float_map[i][j])
        @map[i] << tile
      end
    end
    #puts map
  end

end
