// Difficulty system and progression

export class DifficultySystem {
  constructor() {
    this.difficulties = {
      easy: { label: 'Easy', multiplier: 0.7, timeMultiplier: 1.5 },
      normal: { label: 'Normal', multiplier: 1.0, timeMultiplier: 1.0 },
      hard: { label: 'Hard', multiplier: 1.4, timeMultiplier: 0.7 },
      extreme: { label: 'Extreme', multiplier: 2.0, timeMultiplier: 0.5 }
    };

    this.playerSkill = 0.5; // 0-1 scale
    this.gameSessions = 0;
  }

  setDifficulty(difficulty) {
    return this.difficulties[difficulty] || this.difficulties.normal;
  }

  calculateAdaptiveDifficulty(averageScore, targetScore = 50) {
    // Adjust difficulty based on player performance
    if (averageScore > targetScore * 1.5) {
      return 'hard';
    } else if (averageScore > targetScore) {
      return 'normal';
    } else if (averageScore < targetScore * 0.5) {
      return 'easy';
    }
    return 'normal';
  }

  getGameDifficulty(gameKey, selectedDifficulty) {
    const base = this.setDifficulty(selectedDifficulty);

    const config = {
      fishana: {
        easy: { duration: 180, foodNeeded: 10, predatorSpawn: 1.5 },
        normal: { duration: 120, foodNeeded: 15, predatorSpawn: 1.0 },
        hard: { duration: 90, foodNeeded: 25, predatorSpawn: 0.5 },
        extreme: { duration: 60, foodNeeded: 35, predatorSpawn: 0.3 }
      },

      cars: {
        easy: { duration: 120, laps: 2, obstacleCount: 2, boostRegen: 0.8 },
        normal: { duration: 90, laps: 3, obstacleCount: 4, boostRegen: 1.0 },
        hard: { duration: 60, laps: 5, obstacleCount: 6, boostRegen: 0.6 },
        extreme: { duration: 45, laps: 7, obstacleCount: 8, boostRegen: 0.4 }
      },

      space: {
        easy: { duration: 180, asteroidCount: 15, asteroidSpeed: 1.5, spawnRate: 1500 },
        normal: { duration: 120, asteroidCount: 25, asteroidSpeed: 2.0, spawnRate: 1000 },
        hard: { duration: 90, asteroidCount: 40, asteroidSpeed: 2.8, spawnRate: 600 },
        extreme: { duration: 60, asteroidCount: 60, asteroidSpeed: 3.5, spawnRate: 400 }
      },

      obby: {
        easy: { duration: 180, platformSpacing: 100, obstacleCount: 5, platformWidth: 120 },
        normal: { duration: 120, platformSpacing: 60, obstacleCount: 15, platformWidth: 80 },
        hard: { duration: 90, platformSpacing: 40, obstacleCount: 25, platformWidth: 50 },
        extreme: { duration: 60, platformSpacing: 30, obstacleCount: 35, platformWidth: 30 }
      },

      quiz: {
        easy: { duration: 120, timePerQuestion: 20, pointsPerCorrect: 5, categories: ['general'] },
        normal: { duration: 60, timePerQuestion: 8, pointsPerCorrect: 10, categories: ['general', 'math'] },
        hard: { duration: 45, timePerQuestion: 6, pointsPerCorrect: 15, categories: ['general', 'math', 'science'] },
        extreme: { duration: 30, timePerQuestion: 4, pointsPerCorrect: 20, categories: ['general', 'math', 'science', 'history'] }
      },

      mathdash: {
        easy: { duration: 120, timePerProblem: 15, maxNumber: 10, operators: ['+', '-'] },
        normal: { duration: 90, timePerProblem: 10, maxNumber: 20, operators: ['+', '-', '*'] },
        hard: { duration: 60, timePerProblem: 8, maxNumber: 50, operators: ['+', '-', '*', '/'] },
        extreme: { duration: 45, timePerProblem: 5, maxNumber: 100, operators: ['+', '-', '*', '/'] }
      }
    };

    return config[gameKey]?.[selectedDifficulty] || config[gameKey]?.normal;
  }
}

export class ProgressionSystem {
  constructor() {
    this.playerLevel = 1;
    this.experience = 0;
    this.experienceTable = this.generateExperienceTable(20);
    this.milestones = [10, 50, 100, 500, 1000];
    this.achievements = {};

    this.load();
  }

  generateExperienceTable(levels) {
    const table = [];
    let exp = 100;
    for (let i = 1; i <= levels; i++) {
      table.push(exp);
      exp = Math.floor(exp * 1.15);
    }
    return table;
  }

  addExperience(amount) {
    this.experience += amount;

    while (this.playerLevel < this.experienceTable.length) {
      const nextLevelExp = this.experienceTable[this.playerLevel - 1];
      if (this.experience >= nextLevelExp) {
        this.playerLevel++;
        this.experience -= nextLevelExp;
      } else {
        break;
      }
    }

    this.save();
    return this.playerLevel;
  }

  getProgress() {
    const currentLevelExp = this.experienceTable[this.playerLevel - 1] || 0;
    return {
      level: this.playerLevel,
      experience: this.experience,
      requiredExp: currentLevelExp,
      progressPercent: Math.round((this.experience / currentLevelExp) * 100)
    };
  }

  unlockAchievement(id, name, description) {
    if (!this.achievements[id]) {
      this.achievements[id] = {
        id,
        name,
        description,
        unlockedAt: Date.now()
      };
      this.save();
      return true;
    }
    return false;
  }

  getAchievements() {
    return Object.values(this.achievements);
  }

  save() {
    localStorage.setItem('gameioProgression', JSON.stringify({
      playerLevel: this.playerLevel,
      experience: this.experience,
      achievements: this.achievements
    }));
  }

  load() {
    const stored = localStorage.getItem('gameioProgression');
    if (stored) {
      try {
        const data = JSON.parse(stored);
        this.playerLevel = data.playerLevel || 1;
        this.experience = data.experience || 0;
        this.achievements = data.achievements || {};
      } catch (e) {
        console.error('Failed to load progression:', e);
      }
    }
  }

  reset() {
    this.playerLevel = 1;
    this.experience = 0;
    this.achievements = {};
    this.save();
  }
}

export class ComboSystem {
  constructor() {
    this.combo = 0;
    this.comboMultiplier = 1;
    this.comboTimeout = 0;
    this.comboThreshold = 3; // Combos start at 3+
  }

  incrementCombo() {
    this.combo++;
    this.comboTimeout = 0;

    if (this.combo >= this.comboThreshold) {
      this.comboMultiplier = 1 + (this.combo - this.comboThreshold) * 0.1;
    }

    return this.combo;
  }

  tick(deltaTime) {
    this.comboTimeout += deltaTime;

    // Break combo after 5 seconds of inactivity
    if (this.comboTimeout > 5000) {
      this.resetCombo();
    }
  }

  resetCombo() {
    const lastCombo = this.combo;
    this.combo = 0;
    this.comboMultiplier = 1;
    this.comboTimeout = 0;
    return lastCombo;
  }

  getBonus(baseScore) {
    if (this.combo < this.comboThreshold) return 0;
    return Math.floor(baseScore * (this.comboMultiplier - 1));
  }

  getComboText() {
    if (this.combo < this.comboThreshold) return '';
    return `${this.combo}x COMBO!`;
  }
}

export class SpeedrunTracker {
  constructor() {
    this.records = {};
  }

  startRun(gameKey) {
    return {
      game: gameKey,
      startTime: Date.now(),
      events: []
    };
  }

  recordEvent(run, eventType, eventData) {
    run.events.push({
      type: eventType,
      data: eventData,
      time: Date.now() - run.startTime
    });
  }

  finishRun(run, finalScore) {
    const duration = Date.now() - run.startTime;

    run.score = finalScore;
    run.duration = duration;
    run.finished = true;

    const key = run.game;
    if (!this.records[key]) {
      this.records[key] = [];
    }

    this.records[key].push(run);
    this.records[key].sort((a, b) => a.duration - b.duration);

    return {
      newRecord: this.records[key][0] === run,
      rank: this.records[key].indexOf(run) + 1,
      totalRuns: this.records[key].length
    };
  }

  getPersonalBest(gameKey) {
    if (!this.records[gameKey] || this.records[gameKey].length === 0) {
      return null;
    }
    return this.records[gameKey][0];
  }

  getStats(gameKey) {
    const runs = this.records[gameKey] || [];
    if (runs.length === 0) {
      return { totalRuns: 0, bestTime: null, averageTime: null };
    }

    const times = runs.map(r => r.duration);
    const avgTime = times.reduce((a, b) => a + b) / times.length;

    return {
      totalRuns: runs.length,
      bestTime: runs[0].duration,
      averageTime: Math.round(avgTime),
      times: times
    };
  }
}

export const difficultySystem = new DifficultySystem();
export const progressionSystem = new ProgressionSystem();
export const comboSystem = new ComboSystem();
export const speedrunTracker = new SpeedrunTracker();
