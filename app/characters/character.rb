class Character

  attr_accessor :sprite_index
  attr_accessor :x, :y, :floor, :is_player
  attr_accessor :health, :max_health, :vision
  attr_accessor :enemy_last_seen_at, :path
  attr_accessor :alignment

  def initialize
    @sprite_index = 0
    @is_player = false
    @x = 0
    @y = 0
    @vision = 5
  end

  def set_sprite_index(idx)
    @sprite_index = idx
  end

  def is_ally?(character)
    return character.alignment == @alignment
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
      end
    end
    if target != nil then
      @x = target.x
      @y = target.y
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
