require 'data/constants.rb'

class Tile

  attr_reader :terrain

  def set_terrain_value(val)
    for ter in TERRAIN_TYPES do
      if val < TERRAIN_TYPE_THRESHOLDS[:ter] then
        terrain = ter
        return
      end
    end
  end

  def get_terrain_tile(scale, x, y)
    idx = TERRAIN_SPRITE_INDICES[:terrain]
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
