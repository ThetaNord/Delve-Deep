require 'data/constants.rb'
require 'app/characters/character.rb'

class Ally < Character

  attr_accessor :ai_state, :allied
  attr_accessor :stairs_seen_at, :player_last_seen_at, :ore_last_seen_at, :ore_item_last_seen_at

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

  def clear_registers
    super
    @player_last_seen_at = nil
    @stairs_seen_at = nil
    @ore_last_seen_at = nil
    @ore_item_last_seen_at = nil
  end

  def check_all
    puts "Running ally checks"
    check_player
    puts "Player last seen at: #{@player_last_seen_at}"
    check_stairs
    puts "Stairs seen at: #{@stairs_seen_at}"
    check_enemies
    puts "Enemy last seen at: #{@enemy_last_seen_at}"
    check_ore
    puts "Ore last seen at: #{@ore_last_seen_at}"
    check_ore_item
    puts "Ore item last seen at: #{@ore_item_last_seen_at}"
  end

  def check_stairs
    objects = @floor.get_objects_by_distance(@x, @y, @vision)
    objects.each do |object|
      if object.respond_to?("direction") then
        if object.direction == "down" && @floor.has_line_of_sight?(@x, @y, object.x, object.y) then
          @stairs_seen_at = @floor.get_tile(object.x, object.y)
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
    end
  end

  def check_ore
    # Check that current tile still has ore
    if @ore_last_seen_at != nil && @floor.has_line_of_sight?(@x, @y, @ore_last_seen_at.x, @ore_last_seen_at.y) then
      unless ORE_TYPES.include?(@ore_last_seen_at.terrain)
        @ore_last_seen_at = nil
      end
    end
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
    end
  end

  def check_ore_item
    # TODO: check that the current tile still has ore item
    objects = @floor.get_objects_by_distance(@x, @y, @vision)
    min_distance = 999
    closest_ore_item = nil
    objects.each do |object|
      if object.respond_to?("get_ore") then
        if @floor.has_line_of_sight?(@x, @y, object.x, object.y) then
          distance = (object.x - @x).abs + (object.y - @y).abs
          if distance < min_distance then
            min_distance = distance
            closest_ore_item = object
          end
        end
      end
    end
    if closest_ore_item != nil then
      @ore_item_last_seen_at = @floor.get_tile(closest_ore_item.x, closest_ore_item.y)
    end
  end

  def set_ai_state(state)
    if @ai_state != state then
      @ai_state = state
      @path = nil
    end
  end

  def move
    action = nil
    if @allied then
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
    puts action
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
        if @floor.get_tile(@x, @y) == @player_last_seen_at then
          @player_last_seen_at = nil
        end
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
        if @floor.get_tile(@x, @y) == @enemy_last_seen_at then
          @enemy_last_seen_at = nil
        end
        return :move
      elsif !is_ally?(other_char) then
        attack(other_char)
        @path = nil
        return :attack
      end
    end
  end

  def mine
    if @path == nil || @path.length == 0 then
      if @ore_item_last_seen_at != nil then
        @path = @floor.get_path(@x, @y, @ore_item_last_seen_at.x, @ore_item_last_seen_at.y, :mineable)
      elsif @ore_last_seen_at != nil then
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
          if @floor.get_tile(@x, @y) == @ore_last_seen_at then
            @ore_last_seen_at = nil
          end
          if @floor.get_tile(@x, @y) == @ore_item_last_seen_at then
            @ore_item_last_seen_at = nil
          end
          return :move
        else
          terrain_hit = target.terrain
          target.damage(@mining_speed)
          @path = nil
          return terrain_hit
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
