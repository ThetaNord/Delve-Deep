require 'data/constants.rb'
require 'app/characters/character.rb'

class Ally < Character

  attr_accessor :ai_state, :allied
  attr_accessor :stairs_seen_at, :player_last_seen_at, :ore_last_seen_at

  def initialize
    super
    @alignment = :ally
    @allied = false
    @max_health = 3 + (4*rand).round
    @health = @max_health
    @restore_speed = 6 + (6*rand).round
    @min_damage = 1 + (2*rand).round
    @max_damage = 3 + (3*rand).round
    @sprite_index = 1 + (2*rand).round
    @vision = 3 + (3*rand).round
    @mining_speed = 5 + (10*rand).round
    @ai_state = :follow
  end

  def check_all
    check_player
    check_stairs
    check_enemies
    check_ore
  end

  def check_stairs
    objects = @floor.get_objects_by_distance(@x, @y, @vision)
    objects.each do |object|
      if object.respond_to?("direction") then
        if object.direction == "down" && @floor.has_line_of_sight?(@x, @y, object.x, object.y) then
          @stairs_seen_at = @floor.get_tile(object.x, object.y)
          puts "Stairs seen at: " + @stairs_seen_at.to_s
        end
      end
    end
  end

  def check_player
    characters = @floor.get_characters_by_distance(@x, @y, @vision)
    characters.each do |character|
      if character.is_player then
        if @floor.has_line_of_sight?(@x, @y, character.x, character.y) then
          @player_last_seen_at = @floor.get_tile(character.x, character.y)
          puts "Player last seen at: " + @player_last_seen_at.to_s
          if !@allied then
            @allied = true
          end
        else
          break
        end
      end
    end
  end

  def check_enemies
    closest_enemy_at = get_closest_enemy_location
    if closest_enemy_at != nil && closest_enemy_at != @enemy_last_seen_at then
      @enemy_last_seen_at = closest_enemy_at
      puts "Enemy last seen at: " + @enemy_last_seen_at.to_s
    end
  end

  def check_ore
    tiles = @floor.get_tiles_by_distance(@x, @y, @vision)
    min_distance = 999
    closest_ore = nil
    tiles.each do |tile|
      if ORE_TYPES.include?(tile.terrain) then
        distance = (tile.x - @x).abs + (tile.y - @y).abs
        if distance < min_distance then
          min_distance = distance
          closest_ore = tile
        end
      end
    end
    if closest_ore != nil then
      @ore_last_seen_at = closest_ore
      puts "Ore last seen at: " + @ore_last_seen_at.to_s
    end
  end

  def set_ai_state(state)
    if @ai_state != state then
      @ai_state = state
      @path = nil
    end
  end

  def move
    if @allied then
      action = nil
      case @ai_state
      when :follow
        puts "Following"
        action = follow
      when :assault
        puts "Assaulting"
        action = assault
      when :mine
        puts "Mining"
        action = mine
      when :escape
        puts "Escaping"
        action = escape
      end
    end
    if action == nil then
      # Move randomly
      super
    end
    return action
  end

  def follow
    if @path == nil || @path.length == 0 || @path[-1] != @player_last_seen_at then
      if @player_last_seen_at != nil then
        @path = @floor.get_path(@x, @y, @player_last_seen_at.x, @player_last_seen_at.y)
      end
    end
    if @path != nil && @path.length > 0 then
      target = @path.shift
      other_char = @floor.get_character_at(target.x, target.y)
      if other_char == nil then
        @x = target.x
        @y = target.y
        return :move
      elsif !is_ally?(other_char) then
        attack(other_char)
        return :attack
      end
    end
  end

  def assault
    if @path == nil || @path.length == 0 || @path[-1] != @enemy_last_seen_at then
      if @enemy_last_seen_at != nil then
        @path = @floor.get_path(@x, @y, @enemy_last_seen_at.x, @enemy_last_seen_at.y)
      end
    end
    if @path != nil && @path.length > 0 then
      target = @path.shift
      other_char = @floor.get_character_at(target.x, target.y)
      if other_char == nil then
        @x = target.x
        @y = target.y
        return :move
      elsif !is_ally?(other_char) then
        attack(other_char)
        return :attack
      end
    end
  end

  def mine
    if @path == nil || @path.length == 0 || @path[-1] != @ore_last_seen_at then
      if @ore_last_seen_at != nil then
        @path = @floor.get_path(@x, @y, @ore_last_seen_at.x, @ore_last_seen_at.y, :mineable)
      end
    end
    if @path != nil && @path.length > 0 then
      target = @path.shift
      other_char = @floor.get_character_at(target.x, target.y)
      if other_char == nil then
        if target.terrain == :empty then
          @x = target.x
          @y = target.y
          return :move
        else
          target.damage(@mining_speed)
          return target.terrain
        end
      elsif !is_ally?(other_char) then
        attack(other_char)
        return :attack
      end
    end
  end

  def escape
    if @path == nil || @path.length == 0 || @path[-1] != @stairs_seen_at then
      if @stairs_seen_at != nil then
        @path = @floor.get_path(@x, @y, @stairs_seen_at.x, @stairs_seen_at.y)
      end
    end
    if @path != nil && @path.length > 0 then
      target = @path.shift
      other_char = @floor.get_character_at(target.x, target.y)
      if other_char == nil then
        @x = target.x
        @y = target.y
        return :move
      elsif !is_ally?(other_char) then
        attack(other_char)
        return :attack
      end
    end
  end

end
