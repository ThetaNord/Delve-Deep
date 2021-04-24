require 'app/floor.rb'

class Dungeon

  attr_reader :floors, :floor_number

  def initialize
    @floors = Array.new
    @floor_number = -1
    next_floor
  end

  def next_floor
    floor = Floor.new
    floor.generate_floor_map(18, 18)
    @floors << floor
    puts "Total floors: " + @floors.length.to_s
    @floor_number += 1
    puts "Current floor: " + @floor_number.to_s
  end

  def current_floor
    return @floors[@floor_number]
  end

end
