require 'app/characters/character.rb'

class Enemy < Character

  def initialize
    super
    @alignment = :enemy
  end

  def move
    target = nil
    # Check closest enemy location
    closest_enemy_at = get_closest_enemy_location
    if closest_enemy_at != nil && (closest_enemy_at != @enemy_last_seen_at || path == nil || path.length == 0) then
      @enemy_last_seen_at = closest_enemy_at
      new_path = @floor.get_path(@x, @y, @enemy_last_seen_at.x, @enemy_last_seen_at.y)
      if new_path != nil then
        @path = new_path
      end
    end
    # If path is not empty
    if @path != nil then
      if @path.length > 0 then
        # Get next square on path
        target = @path[0]
      else
        @path = nil
      end
    end
    if target != nil then
      other_char = @floor.get_character_at(target.x, target.y)
      if other_char == nil then
        puts "Moving"
        @x = target.x
        @y = target.y
        @path.shift
        if @floor.get_tile(@x, @y) == @enemy_last_seen_at then
          @enemy_last_seen_at = nil
          puts "Enemy last seen at reset"
        end
        return :move
      else
        unless is_ally?(other_char)
          puts "Attacking"
          attack(other_char)
          return :hurt
        end
      end
    else
      # Move randomly
      super
    end
  end

end
