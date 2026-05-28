// Game configuration and metadata

export const GAMES = {
  fishana: {
    name: 'Fishana Evolution',
    icon: '🎣',
    description: 'Swim, collect pearls, evolve',
    type: '3d',
    players: 'multiplayer'
  },
  cars: {
    name: 'Cars Horizon',
    icon: '🏎️',
    description: 'Drift, race, score laps',
    type: '3d',
    players: 'multiplayer'
  },
  badaam: {
    name: 'Badaam Saat',
    icon: '🃏',
    description: 'Card game, pass or play',
    type: '2d',
    players: 'multiplayer'
  },
  space: {
    name: 'Space Dash',
    icon: '🚀',
    description: 'Navigate asteroid field',
    type: '3d',
    players: 'multiplayer'
  },
  obby: {
    name: 'Sky Obby',
    icon: '🧗',
    description: 'Parkour obstacle course',
    type: '3d',
    players: 'multiplayer'
  }
};

export const AVATAR_FACES = [
  '😎', '🐟', '🏎️', '🚙', '🤖', '🧑‍🚀', '🦖', '🦸', '🐱', '🐼'
];

export const AVATAR_BODIES = [
  '🧊', '🧥', '🦺', '🛡️', '🎽', '🚀', '🏁', '🧍'
];

export const AVATAR_ACCESSORIES = [
  '⚡', '👑', '🎧', '💎', '🔥', '⭐', '🏆', '🪽'
];

export const FIREBASE_CONFIG = {
  // Using REST API, no SDK needed
  baseUrl: 'https://gameio-7e343-default-rtdb.firebaseio.com',
  // Example: GET https://gameio-7e343-default-rtdb.firebaseio.com/rooms.json
};

export const GAME_DEFAULTS = {
  maxPlayers: 8,
  roundTime: 120, // seconds
  scoreMode: 'cumulative'
};
