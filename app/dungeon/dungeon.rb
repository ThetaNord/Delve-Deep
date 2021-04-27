require 'app/dungeon/floor.rb'
require 'app/characters/character.rb'
require 'app/characters/player.rb'
require 'app/characters/enemy.rb'
require 'app/characters/orc.rb'
require 'app/characters/goblin.rb'

class Dungeon

  attr_reader :floors
  attr_accessor :floor_number
  attr_reader :wave_number, :spawn_queue

  def initialize
    @floors = Array.new
    @floor_number = -1
    @wave_number = 1
    @spawn_queue = Array.new
    floor = generate_new_floor
    player = Player.new
    player.x = floor.stairs_up.x
    player.y = floor.stairs_up.y
    floor.add_character(player)
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

  def generate_new_floor
    floor = Floor.new
    floor.generate_floor_map(15, 15)
    @floors << floor
    puts "Active floors: " + @floors.length.to_s
    @floor_number += 1
    puts "Current depth: " + (@floor_number+1).to_s
    return floor
  end

  def move_to_next_floor(character)
    floor = nil
    next_floor_idx = @floors.index(character.floor)+1
    if next_floor_idx >= @floors.length then
      floor = generate_new_floor
    else
      floor = @floors[next_floor_idx]
    end
    character.floor.remove_character(character)
    floor.add_character(character)
    character.x = floor.stairs_up.x
    character.y = floor.stairs_up.y
    character.clear_registers
  end

  def active_floor
    return get_player.floor
  end

  def spawn_goblin_wave
    puts "Spawning goblin wave #{@wave_number}"
    cumulative = 0
    while cumulative < 1 do
      cumulative += rand * 1.0/(@wave_number)**0.2
      puts cumulative
      enemy = nil
      for en in GOBLIN_WAVE_UNITS do
        if cumulative <= GOBLIN_WAVE_THRESHOLDS[en] then
          case en
          when :goblin
            enemy = Goblin.new
          when :orc
            enemy = Orc.new
          end
          break
        end
      end
      if enemy != nil then
        active_floor.add_character(enemy)
        enemy.x = active_floor.stairs_up.x
        enemy.y = active_floor.stairs_up.y
      end
    end
    @wave_number += 1
  end

  def clear_spawn_queue
    spawn_queue = Array.new
  end

  def spawn_next_from_queue
    unless spawn_queue.empty?

    end
  end

end
