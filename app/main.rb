require 'app/game.rb'

$game = nil

def tick(args)
  if $game == nil then
    $game = Game.new
    puts "New game created"
  end
  $game.state = args.state
  $game.inputs = args.inputs
  $game.outputs = args.outputs
  $game.grid = args.grid
  $game.tick
end
