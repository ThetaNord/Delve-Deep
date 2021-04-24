require 'app/dungeon.rb'
require 'data/constants.rb'

class Game

  attr_accessor :state, :inputs, :outputs, :grid
  attr_reader :screen, :dungeon

  def initialize
    @screen = "title"
  end

  def tick
    process_inputs
    render
  end

  def process_inputs
    if inputs.mouse.click && @screen = "title"
      @screen = "game"
      @dungeon = Dungeon.new
    end
  end

  def render
    case @screen
    when "title"
      draw_title
    when "game"
      draw_game
    end
  end

  def draw_title
    outputs.labels << [640, 700, 'Delve Deep', 50, 1]
    x_mid = ((grid.left + grid.right)/2).floor
    y_mid = ((grid.top + grid.bottom)/2).floor
    outputs.sprites << get_character_sprite(0, 20, x_mid, y_mid)
  end

  def draw_game
    floor = @dungeon.current_floor
    floor_name = (floor.floor_number+1).to_s
    outputs.labels << [640, 700, 'Floor ' + floor_name, 10, 1]
    x_mid = ((grid.left + grid.right)/2).floor
    y_mid = ((grid.top + grid.bottom)/2).floor
    outputs.sprites << get_character_sprite(0, 5, x_mid, y_mid)
  end

  def get_character_sprite(idx, scale, x, y)
    [
      {
        x: x-8*scale,
        y: y-8*scale,
        w: 16*scale,
        h: 16*scale,
        path: CHARACTER_SPRITES_PATH,
        tile_x: (idx % 4) * 16,
        tile_y: (idx / 4).floor * 16,
        tile_w: 16,
        tile_h: 16
      }
    ]
  end

end
