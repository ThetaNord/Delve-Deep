require 'app/dungeon.rb'
require 'data/constants.rb'

class Game

  attr_accessor :state, :inputs, :outputs, :grid
  attr_reader :screen, :scale, :x_mid, :y_mid, :map_origin

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
        state.dungeon = Dungeon.new
        state.player = state.dungeon.get_player
        state.floor = state.dungeon.current_floor
        puts "New dungeon created"
      elsif @screen == "dungeon" then
        state.dungeon.next_floor
      end
    end
    if @screen == "dungeon" then
      # Check for level transition
      if state.floor.stairs_down.x == state.player.x && state.floor.stairs_down.y == state.player.y then
        state.floor.remove_character(state.player)
        state.floor = state.dungeon.next_floor
        state.player.x = state.floor.stairs_up.x
        state.player.y = state.floor.stairs_up.y
        state.floor.add_character(state.player)
      end
      # Check for directional input
      x_diff = inputs.keyboard.left_right
      y_diff = inputs.keyboard.up_down
      if x_diff != 0 || y_diff != 0 then
        if state.axes_released == true then
          if x_diff != 0 then
            state.player.x += x_diff
          elsif y_diff != 0 then
            state.player.y += y_diff
          end
          state.axes_released = false
        end
      elsif !state.axes_released
        state.axes_released = true
      end
    end
  end

  def render
    @x_mid = ((grid.left + grid.right)/2).floor
    @y_mid = ((grid.top + grid.bottom)/2).floor
    case @screen
    when "title"
      draw_title
    when "dungeon"
      @map_origin = state.dungeon.get_player_position
      draw_dungeon
    end
  end

  def draw_title
    outputs.labels << [640, 700, 'Delve Deep', 50, 1]
    outputs.sprites << get_character_sprite(0, 20, @x_mid, @y_mid)
  end

  def draw_dungeon
    floor_name = "Floor " + (state.dungeon.floor_number+1).to_s
    outputs.labels << [640, 700, floor_name, 10, 1]
    # Render tiles
    tiles = state.floor.get_tiles
    outputs.sprites << tiles.map do |tile|
      terrain_tile_in_game(tile.x, tile.y, tile.sprite_index)
    end
    # Render objects
    objects = state.floor.objects
    outputs.sprites << objects.map do |object|
      object_tile_in_game(object.x, object.y, object.sprite_index)
    end
    # Render characters
    characters = state.floor.characters
    characters.each do |character|
      outputs.sprites << character_tile_in_game(character.x, character.y, character.sprite_index)
    end
  end

  def character_tile_in_game(x, y, char_idx)
    {
      x: @x_mid + (x - @map_origin[0])*16*@scale - 8*@scale,
      y: @y_mid + (y - @map_origin[1])*16*@scale - 8*@scale,
      w: 16*@scale,
      h: 16*@scale,
      path: CHARACTER_SPRITES_PATH,
      tile_x: (char_idx % 4) * 16,
      tile_y: (char_idx / 4).floor * 16,
      tile_w: 16,
      tile_h: 16,
    }
  end

  def terrain_tile_in_game(x, y, sprite_index)
    {
      x: @x_mid + (x - @map_origin[0])*16*@scale - 8*@scale,
      y: @y_mid + (y - @map_origin[1])*16*@scale - 8*@scale,
      w: 16*@scale,
      h: 16*@scale,
      path: TILE_SPRITES_PATH,
      tile_x: (sprite_index % 4) * 16,
      tile_y: (sprite_index / 4).floor * 16,
      tile_w: 16,
      tile_h: 16,
    }
  end

  def object_tile_in_game(x, y, sprite_index)
    {
      x: @x_mid + (x - @map_origin[0])*16*@scale - 8*@scale,
      y: @y_mid + (y - @map_origin[1])*16*@scale - 8*@scale,
      w: 16*@scale,
      h: 16*@scale,
      path: OBJECT_SPRITES_PATH,
      tile_x: (sprite_index % 4) * 16,
      tile_y: (sprite_index / 4).floor * 16,
      tile_w: 16,
      tile_h: 16,
    }
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
