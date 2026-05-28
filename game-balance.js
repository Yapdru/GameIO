// Game balancing and configuration

export const GAME_BALANCE = {
  fishana: {
    duration: 120,
    startingSize: 1,
    foodNeeded: 15,
    levelCount: 4,
    predatorSpawnThreshold: 2,
    difficultyScaling: 1.1, // 10% harder per level
    scoreMultiplier: {
      0: 1,
      1: 1.5,
      2: 2,
      3: 3
    }
  },

  cars: {
    duration: 90,
    trackLength: 1000,
    carSpeed: 5,
    boostMultiplier: 1.5,
    driftScoreMultiplier: 0.5,
    difficultyScaling: 1.05,
    lapCount: 3
  },

  badaam: {
    deckSize: 52,
    startingHand: 6,
    roundLimit: 100, // Max turns per round
    pointValues: {
      7: 10,
      8: 2,
      9: 3,
      10: 10,
      J: 10,
      Q: 10,
      K: 10,
      A: 1
    },
    comboMultiplier: 1.2,
    maxComboBonus: 5
  },

  space: {
    duration: 120,
    obstacleSpawnRate: 1000, // ms
    asteroidCount: 20,
    minAsteroidSize: 20,
    maxAsteroidSize: 80,
    asteroidSpeed: 2,
    difficultyScaling: 1.08,
    collectibleValue: 10
  },

  obby: {
    duration: 120,
    platformCount: 15,
    platformSpacing: 60,
    platformWidth: 80,
    jumpHeight: 200,
    gravityMultiplier: 1.0,
    obstacleCount: 20,
    checkpointValue: 100,
    difficultyIncrease: 1.05
  },

  quiz: {
    duration: 60,
    questionCount: 10,
    timePerQuestion: 8,
    pointsPerCorrect: 10,
    bonusTime: 2, // Seconds added for correct answer
    difficulty: 'medium',
    categories: ['general', 'math', 'trivia', 'wordplay']
  },

  mathdash: {
    duration: 90,
    problemCount: 10,
    timePerProblem: 10,
    pointsPerCorrect: 10,
    difficultyProgression: 1.15,
    operators: ['+', '-', '*'],
    maxNumber: 20,
    minNumber: 1
  }
};

export class GameBalanceManager {
  static getBalance(gameKey) {
    return GAME_BALANCE[gameKey] || {};
  }

  static adjustBalance(gameKey, adjustments) {
    const current = GAME_BALANCE[gameKey];
    if (!current) return;

    Object.assign(current, adjustments);
  }

  static resetBalance(gameKey) {
    // Store original balance separately if needed for resets
    console.log(`Reset balance for ${gameKey}`);
  }

  static generateRecommendedBalance(gameKey, difficulty = 'normal') {
    const base = { ...GAME_BALANCE[gameKey] };

    switch (difficulty) {
      case 'easy':
        switch (gameKey) {
          case 'fishana':
            return { ...base, duration: 180, foodNeeded: 10, predatorSpawnThreshold: 5 };
          case 'cars':
            return { ...base, duration: 120, difficultyScaling: 1.0 };
          case 'obby':
            return { ...base, duration: 180, platformSpacing: 80 };
          default:
            return base;
        }

      case 'hard':
        switch (gameKey) {
          case 'fishana':
            return { ...base, duration: 90, foodNeeded: 25, predatorSpawnThreshold: 1 };
          case 'cars':
            return { ...base, duration: 60, difficultyScaling: 1.2 };
          case 'obby':
            return { ...base, duration: 90, platformSpacing: 40, platformWidth: 50 };
          default:
            return base;
        }

      default:
        return base;
    }
  }
}

export class ScoreBalancer {
  static normalizeScore(gameKey, rawScore) {
    // Normalize scores to 0-100 scale for fair comparison
    const balance = GAME_BALANCE[gameKey];
    if (!balance) return rawScore;

    switch (gameKey) {
      case 'fishana':
        return Math.min(100, (rawScore / 5000) * 100);
      case 'cars':
        return Math.min(100, (rawScore / 1000) * 100);
      case 'badaam':
        return Math.min(100, (rawScore / 500) * 100);
      case 'space':
        return Math.min(100, (rawScore / 2000) * 100);
      case 'obby':
        return Math.min(100, (rawScore / 1500) * 100);
      case 'quiz':
        return rawScore * 10; // Already out of 10
      case 'mathdash':
        return rawScore * 10;
      default:
        return rawScore;
    }
  }

  static getLeaderboardScore(gameKey, rawScore) {
    // Get normalized score for leaderboard
    return Math.floor(this.normalizeScore(gameKey, rawScore));
  }

  static calculateAverageScore(scores) {
    if (scores.length === 0) return 0;
    return Math.round(scores.reduce((a, b) => a + b) / scores.length);
  }

  static getScoreRank(score, allScores) {
    const sorted = allScores.sort((a, b) => b - a);
    return sorted.indexOf(score) + 1;
  }

  static getScorePercentile(score, allScores) {
    const sorted = allScores.sort((a, b) => b - a);
    const rank = sorted.indexOf(score) + 1;
    return Math.round((1 - rank / sorted.length) * 100);
  }
}

export class DifficultyCalculator {
  static calculateDifficulty(playerScores) {
    if (playerScores.length === 0) return 'normal';

    const avgScore = playerScores.reduce((a, b) => a + b) / playerScores.length;

    if (avgScore > 80) return 'hard';
    if (avgScore > 60) return 'normal';
    return 'easy';
  }

  static getProgressionSuggestion(playerScores) {
    const recent = playerScores.slice(-5);
    const trend = recent[recent.length - 1] - recent[0];

    if (trend > 20) return '📈 You\'re improving! Try harder difficulty';
    if (trend < -20) return '📉 Take it easy for now';
    return '➡️ Keep playing to find your level';
  }
}

export class GameStatistics {
  constructor() {
    this.stats = {
      gamesPlayed: 0,
      totalScore: 0,
      averageScore: 0,
      bestScore: 0,
      gameStats: {}
    };

    this.load();
  }

  recordGame(gameKey, score) {
    this.stats.gamesPlayed++;
    this.stats.totalScore += score;
    this.stats.averageScore = Math.round(this.stats.totalScore / this.stats.gamesPlayed);
    this.stats.bestScore = Math.max(this.stats.bestScore, score);

    if (!this.stats.gameStats[gameKey]) {
      this.stats.gameStats[gameKey] = {
        played: 0,
        totalScore: 0,
        bestScore: 0,
        averageScore: 0
      };
    }

    const gs = this.stats.gameStats[gameKey];
    gs.played++;
    gs.totalScore += score;
    gs.bestScore = Math.max(gs.bestScore, score);
    gs.averageScore = Math.round(gs.totalScore / gs.played);

    this.save();
  }

  getStats(gameKey = null) {
    if (gameKey) {
      return this.stats.gameStats[gameKey] || { played: 0, totalScore: 0, bestScore: 0 };
    }
    return this.stats;
  }

  getFavoriteGame() {
    let favorite = null;
    let maxPlayed = 0;

    Object.entries(this.stats.gameStats).forEach(([key, stats]) => {
      if (stats.played > maxPlayed) {
        maxPlayed = stats.played;
        favorite = key;
      }
    });

    return favorite;
  }

  getBestGame() {
    let best = null;
    let maxScore = 0;

    Object.entries(this.stats.gameStats).forEach(([key, stats]) => {
      if (stats.bestScore > maxScore) {
        maxScore = stats.bestScore;
        best = key;
      }
    });

    return best;
  }

  save() {
    localStorage.setItem('gameioStats', JSON.stringify(this.stats));
  }

  load() {
    const stored = localStorage.getItem('gameioStats');
    if (stored) {
      try {
        this.stats = JSON.parse(stored);
      } catch (e) {
        console.error('Failed to load stats:', e);
      }
    }
  }

  reset() {
    this.stats = {
      gamesPlayed: 0,
      totalScore: 0,
      averageScore: 0,
      bestScore: 0,
      gameStats: {}
    };
    this.save();
  }

  getSummary() {
    return `
📊 Your GameIO Stats
━━━━━━━━━━━━━━━━━━━━━━━━━
Games Played: ${this.stats.gamesPlayed}
Total Score: ${this.stats.totalScore}
Average Score: ${this.stats.averageScore}
Best Score: ${this.stats.bestScore}
Favorite Game: ${this.getFavoriteGame() || 'None yet'}
Best Game: ${this.getBestGame() || 'None yet'}
    `;
  }
}

// Global instances
export const gameStatistics = new GameStatistics();
