require 'app/characters/enemy.rb'

class Goblin < Enemy

  def initialize
    super
    @max_health = 2
    @health = 2
    @speed = 2
    @sprite_index = 5
    @vision = 5
  end

end
