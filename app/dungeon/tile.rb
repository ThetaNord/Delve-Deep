require 'data/constants.rb'
require 'app/dungeon/ore.rb'

class Tile

  attr_accessor :x, :y, :floor
  attr_reader :terrain, :durability, :dmg

  def initialize
    @damage = 0
    @ore = nil
  end

  def set_terrain(name)
    @terrain = name
    @durability = TERRAIN_DURABILITIES[name]
  end

  def set_terrain_value(val)
    for ter in TERRAIN_TYPES do
      if val <= TERRAIN_TYPE_THRESHOLDS[ter] then
        set_terrain(ter)
        return
      end
    end
  end

  def set_ore(ore)
    set_terrain(ore)
  end

  def has_ore?
    return ORE_TYPES.include?(@terrain)
  end

  def spawn_ore
    @floor.objects << Ore.new(@x, @y, @terrain)
  end

  def damage(value)
    sound = TERRAIN_DIG_SOUNDS[@terrain]
    if @durability > 0 then
      @dmg += value
      if @dmg >= @durability then
        if has_ore? then
          spawn_ore
        end
        @terrain = :empty
        @durability = TERRAIN_DURABILITIES[@terrain]
        @dmg = 0
      end
    end
    return sound
  end

  def sprite_index
    TERRAIN_SPRITE_INDICES[@terrain]
  end

  def get_terrain_tile(x, y, scale)
    idx = TERRAIN_SPRITE_INDICES[@terrain]
    [
      {
        x: x-8*scale,
        y: y-8*scale,
        w: 16*scale,
        h: 16*scale,
        path: TILE_SPRITES_PATH,
        tile_x: (idx % 4) * 16,
        tile_y: (idx / 4).floor * 16,
        tile_w: 16,
        tile_h: 16
      }
    ]
  end

  def serialize
    { "floor": @floor, "x": @x, "y": @y, "terrain": @terrain }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  #def to_s
  #  return @terrain
  #end

end
