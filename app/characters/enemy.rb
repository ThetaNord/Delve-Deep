class Enemy < Character

  def initialize
    super
    @alignment = :enemy
  end

  def move
    target = nil
    # Check closest enemy location
    closest_enemy_at = get_closest_enemy_location
    if closest_enemy_at != nil && closest_enemy_at != @enemy_last_seen_at then
      @enemy_last_seen_at = closest_enemy_at
      new_path = @floor.get_path(@x, @y, @enemy_last_seen_at.x, @enemy_last_seen_at.y)
      if new_path != nil then
        @path = new_path
      end
    end
    # If path is not empty
    if @path != nil then
      if @path.length > 0 then
        # Get next square on path
        target = @path.shift
      else
        @path == nil
      end
    end
    if target != nil then
      @x = target.x
      @y = target.y
    else
      # Move randomly
      super
    end
  end

end
