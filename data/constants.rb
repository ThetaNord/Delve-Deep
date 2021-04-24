CHARACTER_SPRITES_PATH = 'sprites/characters.png'
TILE_SPRITES_PATH = 'sprites/tiles.png'

# Terrain types should be in order of ascending threshold
TERRAIN_TYPES = ['empty', 'dirt', 'stone', 'bedrock']
TERRAIN_TYPE_THRESHOLDS = {
    'empty': 0.2,
    'dirt': 0.6,
    'stone': 0.9,
    'bedrock': 1.0
}
TERRAIN_SPRITE_INDICES = {
    'empty': 0,
    'dirt': 1,
    'stone': 2,
    'bedrock': 3,
}
