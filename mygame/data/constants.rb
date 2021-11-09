VERSION_NUMBER = "1.0"

CHARACTER_SPRITES_PATH = 'sprites/characters.png'
TILE_SPRITES_PATH = 'sprites/tiles.png'
OBJECT_SPRITES_PATH = 'sprites/objects.png'
ICON_SPRITES_PATH = 'sprites/icons.png'

FONT = "fonts/UnifrakturCook-Bold.ttf"

MOVE_SOUND = "sounds/move.wav"
STAIR_SOUND = "sounds/walk_stairs.wav"
ATTACK_SOUND = "sounds/attack.wav"
HURT_SOUND = "sounds/hurt.wav"
GOLD_PICKUP_SOUND = "sounds/gold_pickup.wav"
HEALTH_RESTORATION_SOUND = "sounds/health_restored.wav"
GOBLIN_WAVE_SOUND = "sounds/goblin_wave.wav"
GAME_OVER_SOUND = "sounds/game_over.wav"

GOBLIN_WAVE_DELAY = 40
GOBLIN_WAVE_UNITS = [:orc, :goblin]
GOBLIN_WAVE_THRESHOLDS = {
  "orc": 0.4,
  "goblin": 1.0
}

# How long to wait between NPC movement in frames
MOVE_DELAY = 3

FOLLOW_BUTTON_BOUNDARIES = {x: 1020, y: 155, w: 96, h: 96 }
ASSAULT_BUTTON_BOUNDARIES = {x: 1125, y: 155, w: 96, h: 96 }
MINE_BUTTON_BOUNDARIES = {x: 1020, y: 50, w: 96, h: 96 }
ESCAPE_BUTTON_BOUNDARIES = {x: 1125, y: 50, w: 96, h: 96 }

# Terrain and ore types should be in order of ascending threshold
TERRAIN_TYPES = [:empty, :dirt, :stone, :bedrock]
ORE_TYPES = [:gold]
ORE_VALID_TERRAINS = [:stone]
TERRAIN_TYPE_THRESHOLDS = {
    "empty": 0.12,
    "dirt": 0.55,
    "stone": 0.96,
    "bedrock": 1.0,
}
TERRAIN_SPRITE_INDICES = {
    'empty': 0,
    'dirt': 1,
    'stone': 2,
    'bedrock': 3,
    'gold': 4
}
TERRAIN_DURABILITIES = {
    'empty': 0,
    'dirt': 10,
    'stone': 20,
    'bedrock': -1,
    'gold': 30,
}
TERRAIN_DIG_SOUNDS = {
    'empty': nil,
    'dirt': "sounds/dig_dirt.wav",
    'stone': "sounds/dig_stone.wav",
    'bedrock': "sounds/dig_bedrock.wav",
    'gold': "sounds/dig_stone.wav",
}
ORE_THRESHOLDS = {
    "gold": 0.05
}
ORE_VEIN_THRESHOLDS = {
    "gold": 0.2
}
