class Character

  attr_reader :sprite_index
  attr_accessor :x, :y, :floor
  attr_reader :health, :max_health, :vision, :restore_timer, :restore_speed
  attr_reader :min_damage, :max_damage, :mining_speed
  attr_accessor :enemy_last_seen_at, :path
  attr_reader :alignment, :is_player

  def initialize
    @sprite_index = 0
    @is_player = false
    @x = 0
    @y = 0
    @vision = 5
    @restore_timer = 0
    @restore_speed = 10
  end

  def set_sprite_index(idx)
    @sprite_index = idx
  end

  def is_ally?(character)
    return character.alignment == @alignment
  end

  def damage(dmg)
    @health -= dmg
    @restore_timer = 0
    if health <= 0
      @floor.remove_character(self)
    end
    puts "Damage: " + dmg.to_s + ", current health: " + @health.to_s
  end

  def move
    target = nil
    neighbours = @floor.get_neighbours(@floor.get_tile(@x, @y))
    while neighbours.length > 0 do
      target = neighbours.sample
      if target.terrain == :empty then
        break
      else
        neighbours.delete(target)
        target = nil
      end
    end
    if target != nil then
      other_char = @floor.get_character_at(target.x, target.y)
      if other_char == nil then
        @x = target.x
        @y = target.y
        return :move
      elsif !is_ally?(other_char) then
        attack(other_char)
      end
    end
  end

  def attack(character)
    dmg = @min_damage + (rand * (@max_damage - @min_damage)).round
    character.damage(dmg)
  end

  def update_restore_timer
    if @health < @max_health then
      @restore_timer += 1
      if @restore_timer >= @restore_speed then
        @health += 1
        @restore_timer = 0
      end
    end
  end

  def get_closest_enemy_location
    characters = @floor.get_characters_by_distance(@x, @y, @vision)
    enemies = Array.new
    min_distance = 999
    closest_enemy = nil
    characters.each do |character|
      if !is_ally?(character) then
        puts "Enemy at " + character.x.to_s + ", " + character.y.to_s
        if @floor.has_line_of_sight?(@x, @y, character.x, character.y) then
          puts "Have line of sight"
          distance = (character.x - @x).abs + (character.y - @y).abs
          if distance < min_distance then
            min_distance = distance
            closest_enemy = character
          end
        end
      end
    end
    if closest_enemy != nil
      return @floor.get_tile(closest_enemy.x, closest_enemy.y)
    else
      return nil
    end
  end

  def get_character_sprite(scale)
    [
      {
        x: @x-8*scale,
        y: @y-8*scale,
        w: 16*scale,
        h: 16*scale,
        path: CHARACTER_SPRITES_PATH,
        tile_x: (@sprite_index % 4) * 16,
        tile_y: (@sprite_index / 4).floor * 16,
        tile_w: 16,
        tile_h: 16
      }
    ]
  end

end
