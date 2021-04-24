require 'app/floor.rb'

class Dungeon

  attr_reader :floors, :current_floor

  def initialize
    @floors = Array.new(1)
    @current_floor = Floor.new
    @current_floor.floor_number = 0
    @current_floor.generate_floor_map(10, 10)
    @floors[0] = @current_floor
  end

end
