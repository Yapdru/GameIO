// Social features and leaderboards

export class Leaderboard {
  constructor(name = 'global') {
    this.name = name;
    this.entries = [];
    this.maxEntries = 100;
    this.load();
  }

  addScore(playerId, playerName, score, gameKey, gameMode = 'normal') {
    const entry = {
      id: playerId,
      name: playerName,
      score: Math.floor(score),
      game: gameKey,
      mode: gameMode,
      timestamp: Date.now(),
      deviceId: this.getDeviceId()
    };

    this.entries.push(entry);
    this.entries.sort((a, b) => b.score - a.score);
    this.entries = this.entries.slice(0, this.maxEntries);

    this.save();
    return this.getRank(playerId);
  }

  getTopScores(gameKey = null, limit = 10) {
    let scores = this.entries;

    if (gameKey) {
      scores = scores.filter(e => e.game === gameKey);
    }

    return scores.slice(0, limit).map((entry, index) => ({
      rank: index + 1,
      ...entry
    }));
  }

  getRank(playerId) {
    const index = this.entries.findIndex(e => e.id === playerId);
    return index >= 0 ? index + 1 : null;
  }

  getPlayerStats(playerId) {
    const playerScores = this.entries.filter(e => e.id === playerId);

    if (playerScores.length === 0) {
      return null;
    }

    const scores = playerScores.map(e => e.score);
    const gameStats = {};

    playerScores.forEach(entry => {
      if (!gameStats[entry.game]) {
        gameStats[entry.game] = [];
      }
      gameStats[entry.game].push(entry.score);
    });

    return {
      totalScores: playerScores.length,
      totalScore: scores.reduce((a, b) => a + b),
      averageScore: Math.round(scores.reduce((a, b) => a + b) / scores.length),
      bestScore: Math.max(...scores),
      worstScore: Math.min(...scores),
      gameStats: gameStats,
      overallRank: this.getRank(playerId)
    };
  }

  getStreaks(playerId) {
    const playerScores = this.entries.filter(e => e.id === playerId);
    if (playerScores.length === 0) return { current: 0, best: 0 };

    playerScores.sort((a, b) => a.timestamp - b.timestamp);

    const avgScore = playerScores.reduce((a, b) => a + b.score, 0) / playerScores.length;
    let current = 0;
    let best = 0;

    playerScores.forEach(score => {
      if (score.score >= avgScore) {
        current++;
        best = Math.max(best, current);
      } else {
        current = 0;
      }
    });

    return { current, best };
  }

  getDeviceId() {
    let id = localStorage.getItem('gameioDeviceId');
    if (!id) {
      id = 'device-' + Math.random().toString(36).slice(2, 11);
      localStorage.setItem('gameioDeviceId', id);
    }
    return id;
  }

  save() {
    localStorage.setItem(`leaderboard-${this.name}`, JSON.stringify(this.entries));
  }

  load() {
    const stored = localStorage.getItem(`leaderboard-${this.name}`);
    if (stored) {
      try {
        this.entries = JSON.parse(stored);
      } catch (e) {
        console.error('Failed to load leaderboard:', e);
      }
    }
  }

  clear() {
    this.entries = [];
    this.save();
  }

  export() {
    return JSON.stringify(this.entries, null, 2);
  }
}

export class FriendsList {
  constructor() {
    this.friends = {};
    this.load();
  }

  addFriend(friendId, friendName) {
    this.friends[friendId] = {
      id: friendId,
      name: friendName,
      addedAt: Date.now(),
      lastSeen: null,
      stats: null
    };
    this.save();
    return true;
  }

  removeFriend(friendId) {
    delete this.friends[friendId];
    this.save();
    return true;
  }

  isFriend(friendId) {
    return friendId in this.friends;
  }

  getFriends() {
    return Object.values(this.friends);
  }

  updateFriendSeen(friendId) {
    if (this.friends[friendId]) {
      this.friends[friendId].lastSeen = Date.now();
      this.save();
    }
  }

  updateFriendStats(friendId, stats) {
    if (this.friends[friendId]) {
      this.friends[friendId].stats = stats;
      this.save();
    }
  }

  getFriendStats(friendId) {
    return this.friends[friendId]?.stats || null;
  }

  save() {
    localStorage.setItem('gameioFriends', JSON.stringify(this.friends));
  }

  load() {
    const stored = localStorage.getItem('gameioFriends');
    if (stored) {
      try {
        this.friends = JSON.parse(stored);
      } catch (e) {
        console.error('Failed to load friends:', e);
      }
    }
  }
}

export class Achievements {
  constructor() {
    this.achievements = {
      'first-game': {
        id: 'first-game',
        name: '🎮 Getting Started',
        description: 'Play your first game',
        reward: 50,
        unlocked: false
      },
      'level-10': {
        id: 'level-10',
        name: '📈 Rising Star',
        description: 'Reach level 10',
        reward: 100,
        unlocked: false
      },
      'fishana-master': {
        id: 'fishana-master',
        name: '🐟 Fishana Master',
        description: 'Score 5000+ in Fishana',
        reward: 200,
        unlocked: false
      },
      'perfect-quiz': {
        id: 'perfect-quiz',
        name: '🧠 Quiz Perfect',
        description: 'Get 10/10 on Quiz Master',
        reward: 150,
        unlocked: false
      },
      'speedrunner': {
        id: 'speedrunner',
        name: '⚡ Speedrunner',
        description: 'Complete any game in under 30 seconds',
        reward: 200,
        unlocked: false
      },
      'combo-king': {
        id: 'combo-king',
        name: '🔥 Combo King',
        description: 'Get a 10x combo in any game',
        reward: 150,
        unlocked: false
      },
      'leaderboard-1': {
        id: 'leaderboard-1',
        name: '👑 Top of the Board',
        description: 'Reach #1 on global leaderboard',
        reward: 500,
        unlocked: false
      },
      'all-games': {
        id: 'all-games',
        name: '🎪 Game Master',
        description: 'Score 1000+ in all 7 games',
        reward: 300,
        unlocked: false
      }
    };

    this.load();
  }

  unlock(achievementId) {
    if (this.achievements[achievementId] && !this.achievements[achievementId].unlocked) {
      this.achievements[achievementId].unlocked = true;
      this.achievements[achievementId].unlockedAt = Date.now();
      this.save();
      return this.achievements[achievementId];
    }
    return null;
  }

  isUnlocked(achievementId) {
    return this.achievements[achievementId]?.unlocked || false;
  }

  getUnlocked() {
    return Object.values(this.achievements).filter(a => a.unlocked);
  }

  getProgress() {
    const unlocked = this.getUnlocked().length;
    const total = Object.keys(this.achievements).length;
    return {
      unlocked,
      total,
      percent: Math.round((unlocked / total) * 100)
    };
  }

  getTotalRewards() {
    return this.getUnlocked().reduce((sum, a) => sum + a.reward, 0);
  }

  save() {
    localStorage.setItem('gameioAchievements', JSON.stringify(this.achievements));
  }

  load() {
    const stored = localStorage.getItem('gameioAchievements');
    if (stored) {
      try {
        const saved = JSON.parse(stored);
        Object.keys(saved).forEach(key => {
          if (this.achievements[key]) {
            this.achievements[key].unlocked = saved[key].unlocked;
            this.achievements[key].unlockedAt = saved[key].unlockedAt;
          }
        });
      } catch (e) {
        console.error('Failed to load achievements:', e);
      }
    }
  }
}

export class PlayerProfile {
  constructor(playerId, playerName) {
    this.id = playerId;
    this.name = playerName;
    this.title = '';
    this.bio = '';
    this.createdAt = Date.now();
    this.lastActivity = Date.now();
    this.preferences = {
      soundEnabled: true,
      notifications: true,
      profilePublic: true
    };

    this.load();
  }

  setTitle(title) {
    this.title = title;
    this.save();
  }

  setBio(bio) {
    this.bio = bio.substring(0, 200);
    this.save();
  }

  setPreference(key, value) {
    this.preferences[key] = value;
    this.save();
  }

  updateActivity() {
    this.lastActivity = Date.now();
    this.save();
  }

  getProfile() {
    return {
      id: this.id,
      name: this.name,
      title: this.title,
      bio: this.bio,
      createdAt: this.createdAt,
      lastActivity: this.lastActivity,
      preferences: this.preferences
    };
  }

  save() {
    localStorage.setItem(`profile-${this.id}`, JSON.stringify(this.getProfile()));
  }

  load() {
    const stored = localStorage.getItem(`profile-${this.id}`);
    if (stored) {
      try {
        const data = JSON.parse(stored);
        this.name = data.name;
        this.title = data.title;
        this.bio = data.bio;
        this.createdAt = data.createdAt;
        this.lastActivity = data.lastActivity;
        this.preferences = { ...this.preferences, ...data.preferences };
      } catch (e) {
        console.error('Failed to load profile:', e);
      }
    }
  }
}

// Global instances
export const globalLeaderboard = new Leaderboard('global');
export const gameLeaderboards = {
  fishana: new Leaderboard('fishana'),
  cars: new Leaderboard('cars'),
  badaam: new Leaderboard('badaam'),
  space: new Leaderboard('space'),
  obby: new Leaderboard('obby'),
  quiz: new Leaderboard('quiz'),
  mathdash: new Leaderboard('mathdash')
};
export const friendsList = new FriendsList();
export const achievements = new Achievements();
