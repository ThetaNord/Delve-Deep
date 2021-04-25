require 'app/dungeon/tile.rb'
require 'app/dungeon/stairs.rb'

class Floor

  attr_reader :map, :width, :height, :characters
  attr_reader :stairs_down, :stairs_up
  attr_accessor :objects

  def initialize
    @map = Array.new
    @characters = Array.new
    @objects = Array.new
  end

  def is_valid_coordinate?(x, y)
    return x >= 0 && y >= 0 && x < @width && y < @height
  end

  def add_character(character)
    character.floor = self
    @characters << character
  end

  def remove_character(character)
    @characters.delete(character)
    if character.floor == self then
      character.floor = nil
    end
  end

  def get_tiles
    return map.flatten
  end

  def get_tiles_by_distance(x, y, max_distance)
    tiles = Array.new
    get_tiles.each do |tile|
      if (tile.x - x).abs <= max_distance && (tile.y - y).abs <= max_distance then
        tiles << tile
      end
    end
    return tiles
  end

  def get_objects_by_distance(x, y, max_distance)
    objs = Array.new
    @objects.each do |object|
      if (object.x - x).abs <= max_distance && (object.y - y).abs <= max_distance then
        objs << object
      end
    end
    return objs
  end

  def get_characters_by_distance(x, y, max_distance)
    chars = Array.new
    @characters.each do |character|
      if (character.x - x).abs <= max_distance && (character.y - y).abs <= max_distance then
        chars << character
      end
    end
    return chars
  end

  def get_tile(x, y)
    get_tiles.each do |tile|
      if tile.x == x && tile.y == y then
        return tile
      end
    end
    return nil
  end

  def generate_floor_map(w, h)
    # Set map width and height
    @width = w
    @height = h
    # Generate a float "height map" to aid in map generation
    step = 64
    max_diff = 0.125*step
    x_size = step + 1
    y_size = step + 1
    float_map = Array.new(x_size) {|x| x = Array.new(y_size) { |y| y = 0 }}
    # Initialize map corners with random values
    float_map[0][0] = rand
    float_map[0][step] = rand
    float_map[step][0] = rand
    float_map[step][step] = rand
    # Fill the rest of the map based on surrounding values
    while step > 1 do
      step /= 2
      max_diff /= 2.0
      # Square step, horizontal
      i = step
      while i < x_size do
        j = 0
        while j < y_size do
          float_map[i][j] = 0.5*(float_map[i-step][j] + float_map[i+step][j]) + max_diff * (2*rand - 1)
          if float_map[i][j] > 1.0 then
            float_map[i][j] = 1.0
          elsif float_map[i][j] < 0.0 then
            float_map[i][j] = 0.0
          end
          j += 2*step
        end
        i += 2*step
      end
      # Square step, vertical
      j = step
      while j < y_size do
        i = 0
        while i < x_size do
          float_map[i][j] = 0.5*(float_map[i][j-step] + float_map[i][j+step]) + max_diff * (2*rand - 1)
          if float_map[i][j] > 1.0 then float_map[i][j] = 1.0
          elsif float_map[i][j] < 0.0 then float_map[i][j] = 0.0 end
          i += 2*step
        end
        j += 2*step
      end
      # Diamond step
      i = step
      while i < x_size do
        j = step
        while j < y_size do
          float_map[i][j] = 0.25*(float_map[i-step][j] + float_map[i+step][j] + float_map[i][j-step] + float_map[i][j+step]) + max_diff * (2*rand - 1)
          if float_map[i][j] > 1.0 then float_map[i][j] = 1.0
          elsif float_map[i][j] < 0.0 then float_map[i][j] = 0.0 end
          j += 2*step
        end
        i += 2*step
      end
    end
    #puts float_map
    # Convert the float map to desired size tile map
    @map = Array.new
    x_ratio = (x_size-1)/(@width-1.0)
    y_ratio = (y_size-1)/(@height-1.0)
    for i in 0...@width do
      @map << Array.new
      for j in 0...@height do
        tile = Tile.new
        tile.x = i
        tile.y = j
        tile.floor = self
        x = (i*x_ratio).floor
        y = (j*y_ratio).floor
        tile.set_terrain_value(float_map[x][y])
        @map[i] << tile
      end
    end
    add_ores
    add_stairs
  end

  def get_object(x, y)
    @objects.each do |object|
      if object.x == x && object.y == y then
        return object
      end
    end
    return nil
  end

  def square_has_object(x, y)
    return get_object(x, y) != nil
  end

  def tile_is_empty(x, y)
    if square_has_object(x, y) then
      return false
    end
    tile = get_tile(x,y)
    if !tile.terrain == :empty then
      return false
    end
    return true
  end

  def add_stairs
    # Stairs down
    @stairs_down = Stairs.new
    @stairs_down.direction = "down"
    stair_x = (rand * @width).floor
    stair_y = (rand * @height).floor
    while square_has_object(stair_x, stair_y) do
      stair_x = (rand * @width).floor
      stair_y = (rand * @height).floor
    end
    tile = get_tile(stair_x, stair_y)
    if tile.terrain != :empty then
      tile.set_terrain(:empty)
    end
    @stairs_down.x = stair_x
    @stairs_down.y = stair_y
    @objects << stairs_down
    # Stairs up
    @stairs_up = Stairs.new
    @stairs_up.direction = "up"
    stair_x = (rand * @width).floor
    stair_y = (rand * @height).floor
    # Check that the square is free and far enough from the stairs leading down
    while square_has_object(stair_x, stair_y) || ((@stairs_down.x - stair_x).abs <= 5 && (@stairs_down.y - stair_y).abs <= 5) do
      stair_x = (rand * @width).floor
      stair_y = (rand * @height).floor
    end
    tile = get_tile(stair_x, stair_y)
    if tile.terrain != "empty" then
      tile.set_terrain(:empty)
    end
    @stairs_up.x = stair_x
    @stairs_up.y = stair_y
    @objects << @stairs_up
  end

  def add_ores
    puts ORE_VALID_TERRAINS.include?("stone")
    for tile in get_tiles do
      if ORE_VALID_TERRAINS.include?(tile.terrain) && !tile.has_ore? then
        puts "Potential ore position found"
        for ore in ORE_TYPES do
          if rand <= ORE_THRESHOLDS[ore] then
            add_ore(tile, ore)
          end
        end
      end
    end
  end

  def add_ore(tile, ore)
    if tile != nil then
      tile.set_ore(ore)
      puts "Ore spawned at " + tile.x.to_s + ", " + tile.y.to_s
      coords = [[0, -1], [-1, 0], [1, 0], [0, 1]]
      coords.each do |coord|
        new_tile = get_tile(tile.x+coord[0], tile.y+coord[1])
        if new_tile != nil && !new_tile.has_ore? && ORE_VALID_TERRAINS.include?(new_tile.terrain) then
          if rand < ORE_VEIN_THRESHOLDS[ore] then
            add_ore(new_tile, ore)
          end
        end
      end
    end
  end

end
