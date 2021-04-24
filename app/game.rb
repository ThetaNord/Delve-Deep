require 'app/dungeon.rb'
require 'data/constants.rb'

class Game

  attr_accessor :state, :inputs, :outputs, :grid
  attr_reader :screen, :dungeon, :scale

  def initialize
    @screen = "title"
    @scale = 2
  end

  def tick
    process_inputs
    render
  end

  def process_inputs
    if inputs.mouse.click then
      if @screen == "title" then
        @screen = "dungeon"
        @dungeon = Dungeon.new
        puts "New dungeon created"
      elsif @screen == "dungeon" then
        @dungeon.next_floor
      end
    end
  end

  def render
    case @screen
    when "title"
      draw_title
    when "dungeon"
      draw_dungeon
    end
  end

  def draw_title
    outputs.labels << [640, 700, 'Delve Deep', 50, 1]
    x_mid = ((grid.left + grid.right)/2).floor
    y_mid = ((grid.top + grid.bottom)/2).floor
    outputs.sprites << get_character_sprite(0, 20, x_mid, y_mid)
  end

  def draw_dungeon
    floor = @dungeon.current_floor
    floor_name = "Floor " + (@dungeon.floor_number+1).to_s
    outputs.labels << [640, 700, floor_name, 10, 1]
    for i in 0..floor.width-1 do
      for j in 0..floor.height-1 do
        outputs.sprites << floor.map[i][j].get_terrain_tile(300+i*16*@scale, 100+j*16*@scale, @scale)
      end
    end
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
