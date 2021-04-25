require 'app/characters/enemy.rb'

class Skeleton < Enemy

  def initialize
    super
    @max_health = 3
    @health = 3
    @speed = 1
    @sprite_index = 6
    @vision = 4
  end

end
