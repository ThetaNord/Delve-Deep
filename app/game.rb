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
    if state.phase == :menu || state.phase == :move_player then
      process_inputs
    elsif state.phase == :move_allies then
      unless state.allies.empty? then
        if state.tick_count - state.last_move > MOVE_DELAY then
          character = state.allies.shift
          character.set_ai_state(state.ally_ai)
          action = check_objects(character)
          case action
          when :gold
            outputs.sounds << GOLD_PICKUP_SOUND
          when :stairs
            outputs.sounds << STAIR_SOUND
          end
          if character.respond_to?("check_all") then
            character.check_all
          end
          action = character.move
          case action
          when :attack
            outputs.sounds << ATTACK_SOUND
          when :move
            outputs.sounds << MOVE_SOUND
          when :dirt
            outputs.sounds << TERRAIN_DIG_SOUNDS["dirt"]
          when :stone
            outputs.sounds << TERRAIN_DIG_SOUNDS["stone"]
          when :gold
            outputs.sounds << TERRAIN_DIG_SOUNDS["gold"]
          end
          character.update_restore_timer
          if character.floor == state.floor then
            state.last_move = state.tick_count
          end
        end
      else
        state.enemies = state.dungeon.get_enemies
        unless state.enemies.empty? then
          state.phase = :move_enemies
        else
          state.phase = :move_player
        end
      end
    elsif state.phase == :move_enemies then
      unless state.enemies.empty? then
        if state.tick_count - state.last_move > MOVE_DELAY then
          character = state.enemies.shift
          check_objects(character)
          action = character.move
          case action
          when :hurt
            outputs.sounds << HURT_SOUND
          when :move
            outputs.sounds << MOVE_SOUND
          end
          character.update_restore_timer
          if character.floor == state.floor then
            state.last_move = state.tick_count
          end
        end
      else
        state.phase = :move_player
      end
    end
    render
  end

  def process_inputs
    if @screen == "title" || @screen == "gameover" then
      if inputs.keyboard.key_down.enter then
        @screen = "dungeon"
        state.dungeon = Dungeon.new
        state.player = state.dungeon.get_player
        state.floor = state.dungeon.current_floor
        state.score = 0
        puts "New dungeon created"
      end
    elsif @screen == "dungeon" then
      # Check for game over
      if state.player.health <= 0 then
        @screen = "gameover"
        state.phase = :menu
        return
      end
      # Check for level transition
      if state.player.floor.stairs_down.x == state.player.x && state.player.floor.stairs_down.y == state.player.y then
        state.dungeon.move_to_next_floor(state.player)
        state.floor = state.player.floor
        outputs.sounds << STAIR_SOUND
        state.until_goblin_wave = GOBLIN_WAVE_DELAY
      end
      # Check for directional input
      x_diff = inputs.keyboard.left_right
      y_diff = inputs.keyboard.up_down
      if x_diff != 0 || y_diff != 0 then
        if state.axes_released == true then
          move_player(x_diff, y_diff)
        end
      elsif !state.axes_released
        state.axes_released = true
      end
      # Check for AI mode button presses
      check_ai_clicks
    end
  end

  def check_ai_clicks
    if inputs.mouse.click then
      if inputs.mouse.click.point.inside_rect?(FOLLOW_BUTTON_BOUNDARIES.values) then
        state.ally_ai = :follow
      elsif inputs.mouse.click.point.inside_rect?(ASSAULT_BUTTON_BOUNDARIES.values) then
        state.ally_ai = :assault
      elsif inputs.mouse.click.point.inside_rect?(MINE_BUTTON_BOUNDARIES.values) then
        state.ally_ai = :mine
      elsif inputs.mouse.click.point.inside_rect?(ESCAPE_BUTTON_BOUNDARIES.values) then
        state.ally_ai = :escape
      end
    end
  end

  def check_objects(character)
    object = character.floor.get_object(character.x, character.y)
    if object != nil then
      if object.respond_to?("get_ore") && object.get_ore == :gold then
        character.floor.objects.delete(object)
        if character.alignment == :ally then
          state.score += 1
          return :gold
        end
      elsif object.respond_to?("get_direction") && object.get_direction == "down" then
        state.dungeon.move_to_next_floor(character)
        return :stairs
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
              outputs.sounds << GOLD_PICKUP_SOUND
            end
          end
        else
          # If ally
          if other_char.alignment == :ally then
            # Swap places
            other_char.x = state.player.x
            other_char.y = state.player.y
            other_char.path = nil
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
        sound = tile.damage(state.player.mining_speed)
        if sound != nil then
          outputs.sounds << sound
        end
      end
      health_restored = state.player.update_restore_timer
      if health_restored && state.player.health % 2 == 1 then
        outputs.sounds << HEALTH_RESTORATION_SOUND
      end
      state.axes_released = false
      state.until_goblin_wave -= 1
      if state.until_goblin_wave == 0 then
        state.dungeon.spawn_goblin_wave
        state.until_goblin_wave = GOBLIN_WAVE_DELAY
      end
      state.allies = state.dungeon.get_allies
      state.last_move = state.tick_count
      state.phase = :move_allies
    end
  end

  def render
    @x_mid = ((grid.left + grid.right)/2).floor
    @y_mid = ((grid.top + grid.bottom)/2).floor
    case @screen
    when "title"
      render_title
    when "dungeon"
      if state.dungeon.get_player != nil then
        @map_origin = state.dungeon.get_player_position
      end
      render_dungeon
      render_ui
    when "gameover"
      render_gameover
    end
  end

  def render_title
    outputs.background_color = [0, 0, 0]
    outputs.labels << { x: 640, y: 670, text: 'Delve Deep', size_enum: 50, alignment_enum: 1, r: 255, g: 255, b: 255, font: FONT }
    outputs.sprites << get_character_sprite(0, 20, @x_mid, @y_mid)
    outputs.labels << [640, 150, 'Press Enter to start a new game', 10, 1, 255, 255, 255, 255, FONT]
  end

  def render_dungeon
    outputs.background_color = [0, 0, 0]
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

  def render_ui
    floor_name = "Floor " + (state.dungeon.floor_number+1).to_s
    outputs.labels << {x: grid.right-30, y: grid.top-30, text: floor_name, size_enum: 10, alignment_enum: 2, r: 255, g: 255, b: 255, font: FONT }
    # Draw health as hearts
    for i in 0...(state.player.max_health/2).floor do
      sprite_index = 1
      if state.player.health > i*2 then
        sprite_index = 0
      end
      outputs.sprites << {
        x: grid.left + 30 + 48*i, y: grid.top - 70,
        w: 48, h: 48,
        tile_x: (sprite_index % 4) * 16, tile_y: (sprite_index / 4).floor * 16,
        tile_w: 16, tile_h: 16,
        path: ICON_SPRITES_PATH
      }
    end
    # Draw bag of money for score
    sprite_index = 2
    outputs.sprites << {
      x: grid.left + 25, y: grid.top - 150,
      w: 64, h: 64,
      tile_x: (sprite_index % 4) * 16, tile_y: (sprite_index / 4).floor * 16,
      tile_w: 16, tile_h: 16,
      path: ICON_SPRITES_PATH
    }
    outputs.labels << [grid.left + 100, grid.top - 100, state.score, 10, 0, 255, 255, 255, 255, FONT]
    # Draw notification if currently moving allies or enemies
    if state.phase == :move_allies || state.phase == :move_enemies then
      moving_text = "Moving " + (state.phase == :move_allies ? "allies" : "enemies") + "..."
      outputs.labels << [grid.left + 640, grid.bottom + 300, moving_text, 10, 1, 255, 255, 255, 255, FONT]
    end
    # Draw AI buttons
    sprite_index = 4 + (state.ally_ai == :follow ? 1 : 0)
    outputs.sprites << {
      x: FOLLOW_BUTTON_BOUNDARIES.x,
      y: FOLLOW_BUTTON_BOUNDARIES.y,
      w: FOLLOW_BUTTON_BOUNDARIES.w,
      h: FOLLOW_BUTTON_BOUNDARIES.h,
      path: ICON_SPRITES_PATH,
      tile_x: (sprite_index % 4) * 16,
      tile_y: (sprite_index / 4).floor * 16,
      tile_w: 16,
      tile_h: 16,
    }
    sprite_index = 6 + (state.ally_ai == :assault ? 1 : 0)
    outputs.sprites << {
      x: ASSAULT_BUTTON_BOUNDARIES.x,
      y: ASSAULT_BUTTON_BOUNDARIES.y,
      w: ASSAULT_BUTTON_BOUNDARIES.w,
      h: ASSAULT_BUTTON_BOUNDARIES.h,
      path: ICON_SPRITES_PATH,
      tile_x: (sprite_index % 4) * 16,
      tile_y: (sprite_index / 4).floor * 16,
      tile_w: 16,
      tile_h: 16,
    }
    sprite_index = 8 + (state.ally_ai == :mine ? 1 : 0)
    outputs.sprites << {
      x: MINE_BUTTON_BOUNDARIES.x,
      y: MINE_BUTTON_BOUNDARIES.y,
      w: MINE_BUTTON_BOUNDARIES.w,
      h: MINE_BUTTON_BOUNDARIES.h,
      path: ICON_SPRITES_PATH,
      tile_x: (sprite_index % 4) * 16,
      tile_y: (sprite_index / 4).floor * 16,
      tile_w: 16,
      tile_h: 16,
    }
    sprite_index = 10 + (state.ally_ai == :escape ? 1 : 0)
    outputs.sprites << {
      x: ESCAPE_BUTTON_BOUNDARIES.x,
      y: ESCAPE_BUTTON_BOUNDARIES.y,
      w: ESCAPE_BUTTON_BOUNDARIES.w,
      h: ESCAPE_BUTTON_BOUNDARIES.h,
      path: ICON_SPRITES_PATH,
      tile_x: (sprite_index % 4) * 16,
      tile_y: (sprite_index / 4).floor * 16,
      tile_w: 16,
      tile_h: 16,
    }
  end

  def render_gameover
    outputs.background_color = [0, 0, 0]
    outputs.labels << { x: 640, y: 600, text: 'Game Over', size_enum: 100, alignment_enum: 1, r: 255, g: 255, b: 255, font: FONT}
    # TODO: Stats
    outputs.labels << [640, 350, 'Score: ' + state.score.to_s, 30, 1, 255, 255, 255, 255, FONT]
    outputs.labels << [640, 200, 'Press Enter to start a new game', 10, 1, 255, 255, 255, 255, FONT]
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
