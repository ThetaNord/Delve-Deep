require 'app/dungeon/tile.rb'
require 'app/dungeon/stairs.rb'
require 'app/characters/enemy.rb'
require 'app/characters/skeleton.rb'
require 'app/characters/ally.rb'

class Floor

  attr_reader :map, :width, :height, :characters
  attr_reader :stairs_down, :stairs_up
  attr_accessor :objects, :depth

  def initialize
    @map = Array.new
    @characters = Array.new
    @objects = Array.new
  end

  def is_valid_coordinate?(x, y)
    return x >= 0 && y >= 0 && x < @width && y < @height
  end

  def has_line_of_sight?(x0, y0, x1, y1)
    start = {x: x0, y: y0}
    d = {x: x1-x0, y: y1-y0}
    length = (d.x**2 + d.y**2)**0.5
    step = 0.25
    r = { x: step * d.x / length, y: step * d.y / length }
    i = 0
    while i < length/step do
      vec = {x: start.x + i*r.x, y: start.y + i*r.y }
      tile = get_tile(vec.x.round, vec.y.round)
      if tile != nil && tile.terrain != :empty then
        return false
      end
      i += step
    end
    return true
  end

  def get_neighbours(tile)
    neighbours = Array.new
    if tile == nil then
      puts "Can't get neighbours for a nil tile"
      return neighbours
    end
    coords = [[0, -1], [-1, 0], [1, 0], [0, 1]]
    coords.each do |coord|
      new_tile = get_tile(tile.x+coord[0], tile.y+coord[1])
      if new_tile != nil then
        neighbours << new_tile
      end
    end
    return neighbours
  end

  def get_path(x0, y0, x1, y1, path_type = :open)
    puts "Looking for path from (" + x0.to_s + ", " + y0.to_s + ") to (" + x1.to_s + ", " + y1.to_s + ")"
    start = get_tile(x0, y0)
    finish = get_tile(x1, y1)
    path = nil
    if start != nil && finish != nil && start != finish then
      visited = {start: true}
      frontier = [start]
      came_from = Hash.new
      visiting = nil
      while !frontier.empty? && visiting != finish do
        visiting = frontier.shift
        get_neighbours(visiting).each do |neighbour|
          if !visited.has_key?(neighbour) && ((path_type == :open && neighbour.terrain == :empty) || (path_type == :mineable && neighbour.terrain != :bedrock)) then
            frontier << neighbour
            visited[neighbour] = true
            came_from[neighbour] = visiting
            if neighbour == finish then
              visiting = neighbour
              break
            end
          end
        end
      end
      if visiting == finish then
        path = Array.new
        while visiting != start do
          path << visiting
          visiting = came_from[visiting]
        end
        path = path.reverse
        #path.shift
        puts "Path compiled! Length: #{path.length}"
      end
    end
    return path
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

  def get_character_at(x, y)
    @characters.each do |character|
      if character.x == x && character.y == y then
        return character
      end
    end
    return nil
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
    add_enemies
    add_allies
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
    # Create stairs up
    @stairs_up = Stairs.new
    @stairs_up.direction = "up"
    # Create stairs down
    @stairs_down = Stairs.new
    @stairs_down.direction = "down"
    # Randomly place the stairs in the level
    loop do
      loop do
        @stairs_up.x = 1 + (rand * (@width-1)).floor
        @stairs_up.y = 1 + (rand * (@height-1)).floor
        # Check that target square is free
        if !square_has_object(@stairs_up.x, @stairs_up.y) then
          break
        end
      end
      loop do
        @stairs_down.x = 1 + (rand * (@width-1)).floor
        @stairs_down.y = 1 + (rand * (@height-1)).floor
        # Check that target square is free and that the stairs are far enough apart
        if !square_has_object(@stairs_down.x, @stairs_down.y) && ((@stairs_down.x - @stairs_up.x).abs >= @width.div(3) && (@stairs_down.y - @stairs_up.y).abs >= @height.div(3)) then
          break
        end
      end
      # Make sure that a path can be mined between the stairs
      if get_path(@stairs_down.x, @stairs_down.y, @stairs_up.x, @stairs_up.y, :mineable) != nil then
        break
      end
    end
    # Clear target tiles if necessary
    tile = get_tile(@stairs_down.x, @stairs_down.y)
    if tile.terrain != :empty then
      tile.set_terrain(:empty)
    end
    tile = get_tile(@stairs_up.x, @stairs_up.y)
    if tile.terrain != :empty then
      tile.set_terrain(:empty)
    end
    # Add the stairs to the level's object list
    @objects << @stairs_down
    @objects << @stairs_up
    puts "Stairs up generate at: (" + @stairs_up.x.to_s + ", " + @stairs_up.y.to_s + ")"
  end

  def add_ores
    puts ORE_VALID_TERRAINS.include?("stone")
    for tile in get_tiles do
      if ORE_VALID_TERRAINS.include?(tile.terrain) && !tile.has_ore? then
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

  def add_enemies
    tiles = get_tiles
    tile = tiles.sample
    while tile.terrain != :empty do
      tile = tiles.sample
    end
    enemy = Skeleton.new
    enemy.x = tile.x
    enemy.y = tile.y
    enemy.floor = self
    @characters << enemy
  end

  def add_allies
    tiles = get_tiles
    tile = tiles.sample
    while tile.terrain != :empty do
      tile = tiles.sample
    end
    ally = Ally.new
    ally.x = tile.x
    ally.y = tile.y
    ally.floor = self
    @characters << ally
  end

end
