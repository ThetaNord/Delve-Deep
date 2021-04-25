require 'app/dungeon/floor.rb'
require 'app/characters/character.rb'
require 'app/characters/player.rb'

class Dungeon

  attr_reader :floors, :floor_number

  def initialize
    @floors = Array.new
    @floor_number = -1
    next_floor
    player = Player.new
    player.x = current_floor.stairs_up.x
    player.y = current_floor.stairs_up.y
    current_floor.add_character(player)
  end

  def get_player
    current_floor.characters.each do |char|
      if char.is_player then
        return char
      end
    end
    return nil
  end

  def get_player_position
    char = get_player
    return [char.x, char.y]
  end

  def next_floor
    floor = Floor.new
    floor.generate_floor_map(15, 15)
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
