class Player < Character

  def initialize
    super
    @is_player = true
    @alignment = :ally
    @max_health = 10
    @health = 10
    @restore_speed = 15
    @min_damage = 2
    @max_damage = 4
  end

  def move
    return
  end

end
