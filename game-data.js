// Game metadata - no game logic here, just config
export const GAMES = {
  fishana: {
    name: 'Fishana Evolution',
    icon: '🐟',
    description: 'Collect pearls, avoid sharks',
    duration: 30,
    maxScore: 300
  },
  cars: {
    name: 'Cars Drift',
    icon: '🏎️',
    description: 'Arcade racing, drift and drift',
    duration: 30,
    maxScore: 300
  },
  badaam: {
    name: 'Badaam Saat',
    icon: '🃏',
    description: 'Strategic card game',
    duration: 45,
    maxScore: 450
  },
  space: {
    name: 'Space Dash',
    icon: '🚀',
    description: 'Avoid obstacles, collect stars',
    duration: 40,
    maxScore: 400
  },
  obby: {
    name: 'Obby Run',
    icon: '🏃',
    description: 'Jump platforms, reach the end',
    duration: 45,
    maxScore: 450
  },
  quiz: {
    name: 'Quick Quiz',
    icon: '❓',
    description: 'Answer questions fast',
    duration: 30,
    maxScore: 500
  },
  math: {
    name: 'Math Dash',
    icon: '➕',
    description: 'Solve math problems',
    duration: 45,
    maxScore: 500
  }
};

export const DEFAULT_GAME_ORDER = ['fishana', 'cars', 'badaam', 'space', 'obby', 'quiz', 'math'];

// Avatar config
export const AVATAR_CONFIG = {
  heads: [
    { name: 'Circle', char: '●' },
    { name: 'Square', char: '■' },
    { name: 'Triangle', char: '▲' }
  ],
  bodies: [
    { name: 'Rectangle', char: '▬' },
    { name: 'Diamond', char: '◆' },
    { name: 'Pentagon', char: '⬟' }
  ],
  colors: ['#0099FF', '#FFD700', '#FF6B6B', '#00CC88', '#9933FF', '#FF9900']
};
