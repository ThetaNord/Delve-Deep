require 'app/floor.rb'
require 'app/character.rb'

class Dungeon

  attr_reader :floors, :floor_number

  def initialize
    @floors = Array.new
    @floor_number = -1
    next_floor
    character = Character.new
    character.is_player = true
    current_floor.add_character(character)
  end

  def get_player
    current_floor.characters.each do |char|
      if char.is_player then
        return char
      end
    end
  end

  def get_player_position
    char = get_player
    return [char.x, char.y]
  end

  def next_floor
    floor = Floor.new
    floor.generate_floor_map(18, 18)
    @floors << floor
    puts "Total floors: " + @floors.length.to_s
    @floor_number += 1
    puts "Current floor: " + (@floor_number+1).to_s
    return current_floor
  end

  def current_floor
    return @floors[@floor_number]
  end

end
