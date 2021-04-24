require 'app/game.rb'

def tick(args)
  args.state.game ||= Game.new
  args.state.game.render(args)
end
