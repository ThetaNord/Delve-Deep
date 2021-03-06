require 'app/game.rb'

$game = nil

def tick(args)
  if $game == nil then
    $game = Game.new
    args.state.axes_released = true
    args.state.phase = :menu
    args.state.ally_ai = :follow
    args.state.until_goblin_wave = GOBLIN_WAVE_DELAY
    puts "New game created"
  end
  $game.state = args.state
  $game.inputs = args.inputs
  $game.outputs = args.outputs
  $game.grid = args.grid
  $game.tick
end
