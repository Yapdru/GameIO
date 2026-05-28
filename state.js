// Centralized state management

class GameState {
  constructor() {
    // Player identity
    this.playerId = localStorage.gameioPlayerId || this.generateId();
    this.playerName = localStorage.gameioPlayerName || 'Player';
    this.playerAvatar = {
      face: localStorage.gameioFace || '😎',
      body: localStorage.gameioBody || '🧊',
      acc: localStorage.gameioAcc || '⚡'
    };

    // Room/multiplayer
    this.roomCode = '';
    this.isHost = false;
    this.players = []; // Array of {id, name, avatar, score}
    this.playersInLobby = {}; // Track 3D positions

    // Game state
    this.currentScreen = 'start';
    this.currentGame = null;
    this.gameInProgress = false;
    this.scores = {}; // {playerId: score}
    this.gameStartTime = 0;

    // 3D state
    this.playerPosition = { x: 0, y: 0, z: 0 };
    this.playerRotation = 0;

    // Persist player identity
    localStorage.gameioPlayerId = this.playerId;
    localStorage.gameioPlayerName = this.playerName;
    this.saveAvatar();
  }

  generateId() {
    return 'p' + Math.random().toString(36).slice(2, 10);
  }

  // Screen management
  setScreen(screenName) {
    this.currentScreen = screenName;
    console.log('Screen:', screenName);
  }

  // Avatar
  setAvatar(face, body, acc) {
    this.playerAvatar = { face, body, acc };
    this.saveAvatar();
  }

  saveAvatar() {
    localStorage.gameioFace = this.playerAvatar.face;
    localStorage.gameioBody = this.playerAvatar.body;
    localStorage.gameioAcc = this.playerAvatar.acc;
  }

  // Player info
  setPlayerName(name) {
    this.playerName = name;
    localStorage.gameioPlayerName = name;
  }

  getPlayerData() {
    return {
      id: this.playerId,
      name: this.playerName,
      avatar: this.playerAvatar,
      score: this.scores[this.playerId] || 0
    };
  }

  // Room management
  createRoom() {
    this.roomCode = this.generateRoomCode();
    this.isHost = true;
    this.players = [this.getPlayerData()];
    this.scores[this.playerId] = 0;
  }

  generateRoomCode() {
    return Math.random().toString(36).slice(2, 8).toUpperCase();
  }

  joinRoom(code) {
    this.roomCode = code.toUpperCase();
    this.isHost = false;
    this.scores[this.playerId] = 0;
  }

  leaveRoom() {
    this.roomCode = '';
    this.isHost = false;
    this.players = [];
    this.scores = {};
  }

  // Player management
  addPlayer(playerData) {
    const existing = this.players.find(p => p.id === playerData.id);
    if (!existing) {
      this.players.push(playerData);
      this.scores[playerData.id] = 0;
    }
  }

  updatePlayer(playerId, updates) {
    const player = this.players.find(p => p.id === playerId);
    if (player) {
      Object.assign(player, updates);
    }
  }

  removePlayer(playerId) {
    this.players = this.players.filter(p => p.id !== playerId);
    delete this.scores[playerId];
  }

  // Game
  startGame(gameKey) {
    this.currentGame = gameKey;
    this.gameInProgress = true;
    this.gameStartTime = Date.now();
    this.scores[this.playerId] = 0;
  }

  endGame() {
    this.gameInProgress = false;
    this.currentGame = null;
  }

  addScore(playerId, points) {
    if (!this.scores[playerId]) this.scores[playerId] = 0;
    this.scores[playerId] += points;
  }

  getScoreboard() {
    return this.players
      .map(p => ({
        ...p,
        score: this.scores[p.id] || 0
      }))
      .sort((a, b) => b.score - a.score);
  }

  // 3D state
  setPlayerPosition(x, y, z) {
    this.playerPosition = { x, y, z };
  }

  setPlayerRotation(angle) {
    this.playerRotation = angle;
  }

  updateLobbyPlayer(playerId, position, rotation) {
    if (!this.playersInLobby[playerId]) {
      this.playersInLobby[playerId] = {};
    }
    this.playersInLobby[playerId] = {
      position,
      rotation,
      lastUpdate: Date.now()
    };
  }

  getLobbyPlayers() {
    // Filter out players who haven't updated recently (5 seconds)
    const now = Date.now();
    return Object.entries(this.playersInLobby)
      .filter(([_, data]) => now - data.lastUpdate < 5000)
      .map(([id, data]) => ({
        id,
        ...data
      }));
  }
}

// Singleton instance
export const gameState = new GameState();
