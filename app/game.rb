require 'app/dungeon/dungeon.rb'
require 'data/constants.rb'

class Game

  attr_accessor :state, :inputs, :outputs, :grid
  attr_reader :screen, :scale, :x_mid, :y_mid, :map_origin

  def initialize
    @screen = "title"
    @scale = 6
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
        state.score = 0
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
        outputs.sounds << STAIR_SOUND
      end
      # Check for directional input
      x_diff = inputs.keyboard.left_right
      y_diff = inputs.keyboard.up_down
      if x_diff != 0 || y_diff != 0 then
        if state.axes_released == true then
          move_player(x_diff, y_diff)
          # Also move other characters
          if state.phase == :move_enemy then
            state.floor.characters.each do |character|
              if character.is_player == false then
                action = character.move
                case action
                when :hurt
                  outputs.sounds << HURT_SOUND
                end
              end
            end
            state.phase = :move_player
          end
        end
      elsif !state.axes_released
        state.axes_released = true
      end
    end
  end

  def move_player(x_diff, y_diff)
    target_x = @state.player.x
    target_y = @state.player.y
    if x_diff != 0 then
      target_x += x_diff
    elsif y_diff != 0 then
      target_y += y_diff
    end
    if @state.floor.is_valid_coordinate?(target_x, target_y) then
      tile = @state.floor.get_tile(target_x, target_y)
      if tile.terrain == :empty then
        other_char = @state.floor.get_character_at(target_x, target_y)
        if other_char == nil then
          state.player.x = target_x
          state.player.y = target_y
          # Check for objects
          object = state.floor.get_object(tile.x, tile.y)
          if object != nil then
            # Check for gold
            if object.respond_to?("get_ore") && object.get_ore == :gold then
              state.score += 1
              puts "Score: " + state.score.to_s
              state.floor.objects.delete(object)
              outputs.sounds << "sounds/gold_pickup.wav"
            end
          end
        else
          # If ally
          if other_char.alignment == :ally then
            # Swap places
            other_char.x = state.player.x
            other_char.y = state.player.y
            state.player.x = target_x
            state.player.y = target_y
          # Otherwise
          else
            # Attack
            state.player.attack(other_char)
            outputs.sounds << ATTACK_SOUND
          end
        end
      else
        sound = tile.damage(1)
        if sound != nil then
          outputs.sounds << sound
        end
      end
      state.axes_released = false
      state.phase = :move_enemy
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
    outputs.background_color = [0, 0, 0]
    floor_name = "Floor " + (state.dungeon.floor_number+1).to_s
    outputs.labels << [640, 700, floor_name, 10, 1, 255, 255, 255, 255]
    # Render tiles
    tiles = state.floor.get_tiles_by_distance(@map_origin[0], @map_origin[1], 3)
    outputs.sprites << tiles.map do |tile|
      terrain_tile_in_game(tile.x, tile.y, tile.sprite_index)
    end
    # Render objects
    objects = state.floor.get_objects_by_distance(@map_origin[0], @map_origin[1], 3)
    outputs.sprites << objects.map do |object|
      object_tile_in_game(object.x, object.y, object.sprite_index)
    end
    # Render characters
    characters = state.floor.get_characters_by_distance(@map_origin[0], @map_origin[1], 3)
    characters.each do |character|
      outputs.sprites << character_tile_in_game(character.x, character.y, character.sprite_index)
    end
    # Render darkness overlay
    outputs.sprites << {x: @x_mid - 56*@scale, y: @y_mid - 56*@scale, w: 112*@scale, h: 112*@scale, path: "sprites/darkness-overlay-large.png"}
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
