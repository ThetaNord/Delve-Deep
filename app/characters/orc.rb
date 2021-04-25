require 'app/characters/enemy.rb'

class Orc < Enemy

  def initialize
    super
    @max_health = 4
    @health = 4
    @speed = 1
    @sprite_index = 4
    @vision = 3
  end

end
