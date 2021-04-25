class Character

  attr_reader :sprite_index
  attr_accessor :x, :y, :floor, :is_player

  def initialize
    @sprite_index = 0
    @is_player = false
    @x = 0
    @y = 0
  end

  def set_sprite_index(idx)
    @sprite_index = idx
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
