class Game

  attr_reader :state

  def initialize
    @state = "title"
  end

  def render(args)
    case @state
    when "title"
        draw_title(args)
    end
  end

  def draw_title(args)
    args.outputs.labels << [640, 700, 'Delve Deep', 50, 1]
    x_mid = ((args.grid.left+args.grid.right)/2).floor
    y_mid = ((args.grid.top+args.grid.bottom)/2).floor
    args.outputs.sprites << get_character_sprite(0, 20, x_mid, y_mid)
  end

  def get_character_sprite(idx, scale, x, y)
    [
      {
        x: x-8*scale,
        y: y-8*scale,
        w: 16*scale,
        h: 16*scale,
        path: 'sprites/characters.png',
        tile_x: (idx % 4) * 16,
        tile_y: (idx / 4).floor * 16,
        tile_w: 16,
        tile_h: 16
      }
    ]
  end

end
