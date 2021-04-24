CHARACTER_SPRITES_PATH = 'sprites/characters.png'
TILE_SPRITES_PATH = 'sprites/tiles.png'
OBJECT_SPRITES_PATH = 'sprites/objects.png'

# Terrain types should be in order of ascending threshold
TERRAIN_TYPES = [:empty, :dirt, :stone, :bedrock]
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
}
TERRAIN_DURABILITIES = {
    'empty': 0,
    'dirt': 1,
    'stone': 2,
    'bedrock': -1,
}
