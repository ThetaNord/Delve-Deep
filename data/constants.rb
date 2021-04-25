CHARACTER_SPRITES_PATH = 'sprites/characters.png'
TILE_SPRITES_PATH = 'sprites/tiles.png'
OBJECT_SPRITES_PATH = 'sprites/objects.png'

STAIR_SOUND = "sounds/walk_stairs.wav"

# Terrain and ore types should be in order of ascending threshold
TERRAIN_TYPES = [:empty, :dirt, :stone, :bedrock]
ORE_TYPES = [:gold]
ORE_VALID_TERRAINS = ["stone"]
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
    'dirt': 1,
    'stone': 2,
    'bedrock': -1,
    'gold': 3
}
TERRAIN_DIG_SOUNDS = {
    'empty': nil,
    'dirt': "sounds/dig_dirt.wav",
    'stone': nil, #"sounds/dig_stone.wav",
    'bedrock': "sounds/dig_bedrock.wav",
}
ORE_THRESHOLDS = {
    "gold": 0.05
}
ORE_VEIN_THRESHOLDS = {
    "gold": 0.15
}
