// Game metadata and configuration
export class Avatar {
  constructor(headType = 0, bodyType = 0, colorIndex = 0) {
    this.headType = headType;
    this.bodyType = bodyType;
    this.colorIndex = colorIndex;
  }

  serialize() {
    return `${this.headType}-${this.bodyType}-${this.colorIndex}`;
  }

  static deserialize(str) {
    const [h, b, c] = str.split('-').map(Number);
    return new Avatar(h, b, c);
  }
}

export const GAMES = {
  fishana: {
    name: 'Fishana Evolution',
    icon: '🐟',
    description: 'Collect pearls, avoid sharks',
    module: 'games/fishana.js',
    type: 'action'
  },
  cars: {
    name: 'Cars Drift',
    icon: '🏎️',
    description: 'Arcade driving, finish the lap',
    module: 'games/cars.js',
    type: 'action'
  },
  badaam: {
    name: 'Badaam Saat',
    icon: '🃏',
    description: 'Strategic card game',
    module: 'games/badaam.js',
    type: 'cards'
  },
  space: {
    name: 'Space Dash',
    icon: '🚀',
    description: 'Dodge asteroids, collect stars',
    module: 'games/space.js',
    type: 'action'
  },
  obby: {
    name: 'Obby Run',
    icon: '🏃',
    description: 'Jump through obstacles',
    module: 'games/obby.js',
    type: 'action'
  },
  quiz: {
    name: 'Quick Quiz',
    icon: '❓',
    description: 'Answer questions, earn points',
    module: 'games/quiz.js',
    type: 'quiz'
  },
  math: {
    name: 'Math Dash',
    icon: '➕',
    description: 'Speed math challenges',
    module: 'games/mathdash.js',
    type: 'quiz'
  }
};

// Default game order
export const DEFAULT_GAMES = ['fishana', 'cars', 'badaam', 'space', 'obby', 'quiz', 'math'];

// Avatar customization parts
export const AVATAR_PARTS = {
  head: [
    { name: 'Round', color: '#FFD700' },
    { name: 'Square', color: '#FF6B6B' },
    { name: 'Triangle', color: '#4ECDC4' }
  ],
  body: [
    { name: 'Rectangle', color: '#0099FF' },
    { name: 'Circle', color: '#FFD700' },
    { name: 'Triangle', color: '#00CC88' }
  ],
  color: [
    '#0099FF',
    '#FFD700',
    '#FF6B6B',
    '#00CC88',
    '#FF00FF',
    '#00FFFF'
  ]
};

// Quiz questions
export const QUIZ_QUESTIONS = [
  { q: 'What is 5 + 3?', options: ['8', '7', '9', '6'], correct: 0 },
  { q: 'What is 12 - 4?', options: ['8', '7', '9', '6'], correct: 0 },
  { q: 'What is 3 × 4?', options: ['10', '12', '14', '16'], correct: 1 },
  { q: 'What is 20 ÷ 5?', options: ['3', '4', '5', '6'], correct: 1 },
  { q: 'What is 7 + 8?', options: ['14', '15', '16', '17'], correct: 1 },
  { q: 'What is the capital of France?', options: ['London', 'Paris', 'Berlin', 'Rome'], correct: 1 },
  { q: 'What is the largest planet?', options: ['Saturn', 'Jupiter', 'Neptune', 'Mars'], correct: 1 },
  { q: 'How many sides does a hexagon have?', options: ['5', '6', '7', '8'], correct: 1 }
];

// Badaam game cards
export const BADAAM_CARDS = [
  { suit: '♥', value: '6' },
  { suit: '♥', value: '7' },
  { suit: '♥', value: '8' },
  { suit: '♥', value: '9' },
  { suit: '♣', value: '6' },
  { suit: '♣', value: '7' },
  { suit: '♣', value: '8' },
  { suit: '♦', value: '6' },
  { suit: '♦', value: '7' }
];

export function getRandomQuiz() {
  return QUIZ_QUESTIONS[Math.floor(Math.random() * QUIZ_QUESTIONS.length)];
}
