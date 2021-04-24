require 'app/game.rb'

$game

def tick(args)
  $game ||= Game.new
  $game.state = args.state
  $game.inputs = args.inputs
  $game.outputs = args.outputs
  $game.grid = args.grid
  $game.tick
end
