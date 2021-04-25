require 'app/dungeon/floor.rb'
require 'app/characters/character.rb'
require 'app/characters/player.rb'

class Dungeon

  attr_reader :floors
  attr_accessor :floor_number

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
    @floors.each do |floor|
      floor.characters.each do |char|
        if char.is_player then
          return char
        end
      end
    end
    return nil
  end

  def get_allies
    allies = Array.new
    @floors.each do |floor|
      floor.characters.each do |character|
        if character.is_player == false && character.alignment == :ally then
          allies << character
        end
      end
    end
    return allies
  end

  def get_enemies
    enemies = Array.new
    @floors.each do |floor|
      floor.characters.each do |character|
        if character.alignment == :enemy then
          enemies << character
        end
      end
    end
    return enemies
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

  def move_to_next_floor(character)
    floor = nil
    next_floor_idx = @floors.index(character.floor)+1
    if next_floor_idx >= @floors.length then
      floor = next_floor
    else
      floor = @floors[next_floor_idx]
    end
    character.floor.remove_character(character)
    floor.add_character(character)
    character.x = floor.stairs_up.x
    character.y = floor.stairs_up.y
    character.clear_registers
  end

  def current_floor
    return @floors[@floor_number]
  end

end
