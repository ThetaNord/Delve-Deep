class Floor

  attr_accessor :floor_number
  attr_reader :map

  def initialize
    @map = Array.new
  end

  def generate(x_size, y_size)
    float_map = Array.new(x_size)
    for i in 0..x_size-1 do
      float_map[i] = Array.new(y_size) {|x| x = rand}
    end
    @map = float_map
    puts map
  end

end
