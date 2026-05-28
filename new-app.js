// Main app controller
import { GAMES, DEFAULT_GAMES, Avatar } from './new-game-data.js';
import { renderAvatarPicker } from './new-avatars.js';
import { createRoom, joinRoom, getRoom, OfflineRoom, apiCall } from './new-firebase.js';
import { Fishana } from './games/fishana.js';
import { Cars } from './games/cars.js';
import { Badaam } from './games/badaam.js';
import { Space } from './games/space.js';
import { Obby } from './games/obby.js';
import { Quiz } from './games/quiz.js';
import { MathDash } from './games/mathdash.js';

class GameIO {
  constructor() {
    this.app = document.getElementById('app');
    this.currentScreen = null;
    this.gameInstance = null;
    this.gameLoop = null;
    this.playerName = 'Player ' + Math.floor(Math.random() * 10000);
    this.avatar = new Avatar();
    this.room = null;
    this.selectedGames = [...DEFAULT_GAMES];
    this.currentGameIndex = 0;
    this.scores = {};
    this.isHost = false;

    this.showStart();
  }

  render(html, className = '') {
    this.app.innerHTML = html;
    const screen = this.app.querySelector(`.${className}`);
    if (screen) screen.classList.add('active');
  }

  showStart() {
    this.currentScreen = 'start';
    this.render(`
      <div class="start-screen">
        <h1 class="logo">GAMEIO</h1>
        <p class="subtitle">Arcade Worlds</p>
        <div class="button-grid">
          <button class="btn btn-primary" id="createBtn">Create Room</button>
          <button class="btn btn-primary" id="joinBtn">Join Room</button>
          <button class="btn btn-secondary" id="quickBtn">Quick Play</button>
        </div>
      </div>
    `, 'start-screen');

    document.getElementById('createBtn').onclick = () => this.showAvatar('create');
    document.getElementById('joinBtn').onclick = () => this.showJoinRoom();
    document.getElementById('quickBtn').onclick = () => this.quickPlay();
  }

  showAvatar(mode) {
    this.mode = mode;
    this.currentScreen = 'avatar';
    this.render(`
      <div class="avatar-screen">
        <div class="card">
          <h2>Create Your Avatar</h2>
          <div class="avatar-preview">
            <canvas class="avatar-canvas" width="120" height="120"></canvas>
          </div>
          <div id="avatarPicker"></div>
          <div class="form-group">
            <label>Your Name</label>
            <input type="text" id="playerName" placeholder="Enter your name" value="${this.playerName}">
          </div>
          <button class="btn btn-primary" id="continueBtn">Continue</button>
          <button class="btn btn-secondary" id="backBtn">Back</button>
        </div>
      </div>
    `, 'avatar-screen');

    renderAvatarPicker('avatarPicker', (type, index) => {
      if (type === 'head') this.avatar.headType = index;
      if (type === 'body') this.avatar.bodyType = index;
      if (type === 'color') this.avatar.colorIndex = index;
      this.updateAvatarPreview();
    });

    this.updateAvatarPreview();

    document.getElementById('playerName').onchange = (e) => {
      this.playerName = e.target.value;
    };

    document.getElementById('continueBtn').onclick = () => {
      if (this.mode === 'create') {
        this.showGameSelector();
      } else {
        this.showJoinRoom();
      }
    };

    document.getElementById('backBtn').onclick = () => this.showStart();
  }

  updateAvatarPreview() {
    const canvas = document.querySelector('.avatar-canvas');
    if (canvas) this.avatar.draw(canvas);
  }

  showGameSelector() {
    this.currentScreen = 'gameSelector';
    const gamesHtml = Object.entries(GAMES).map(([key, game]) => `
      <div class="game-tile ${this.selectedGames.includes(key) ? 'selected' : ''}" data-game="${key}">
        <div class="game-icon">${game.icon}</div>
        <div class="game-name">${game.name}</div>
      </div>
    `).join('');

    this.render(`
      <div class="lobby-screen">
        <div class="card">
          <h2>Select Games</h2>
          <p>Choose games for your playlist</p>
          <div class="games-grid" id="gamesGrid">${gamesHtml}</div>
          <button class="btn btn-primary" id="createRoomBtn">Create Room</button>
          <button class="btn btn-secondary" id="backBtn">Back</button>
        </div>
      </div>
    `, 'lobby-screen');

    document.querySelectorAll('[data-game]').forEach(tile => {
      tile.onclick = () => {
        const game = tile.dataset.game;
        const idx = this.selectedGames.indexOf(game);
        if (idx >= 0) {
          this.selectedGames.splice(idx, 1);
        } else {
          this.selectedGames.push(game);
        }
        this.showGameSelector();
      };
    });

    document.getElementById('createRoomBtn').onclick = () => this.createRoom();
    document.getElementById('backBtn').onclick = () => this.showAvatar('create');
  }

  async createRoom() {
    this.isHost = true;
    const code = Math.random().toString(36).slice(2, 8).toUpperCase();
    const playerData = {
      id: this.playerName + Date.now(),
      name: this.playerName,
      avatar: this.avatar.serialize(),
      score: 0
    };

    // Try Firebase, fall back to offline
    const roomCreated = await createRoom(code, playerData);
    if (roomCreated) {
      this.room = { code: roomCreated, players: [playerData], games: this.selectedGames };
    } else {
      this.room = new OfflineRoom(code, playerData);
      this.room.games = this.selectedGames;
    }

    this.showLobby();
  }

  showJoinRoom() {
    this.currentScreen = 'joinRoom';
    this.render(`
      <div class="lobby-screen">
        <div class="card">
          <h2>Join Room</h2>
          <div class="form-group">
            <label>Room Code</label>
            <input type="text" id="roomCode" placeholder="Enter room code" maxlength="8">
          </div>
          <button class="btn btn-primary" id="joinBtn">Join</button>
          <button class="btn btn-secondary" id="backBtn">Back</button>
        </div>
      </div>
    `, 'lobby-screen');

    document.getElementById('joinBtn').onclick = () => {
      const code = document.getElementById('roomCode').value.toUpperCase();
      if (code) this.tryJoinRoom(code);
    };

    document.getElementById('backBtn').onclick = () => this.showStart();
  }

  async tryJoinRoom(code) {
    const playerData = {
      id: this.playerName + Date.now(),
      name: this.playerName,
      avatar: this.avatar.serialize(),
      score: 0
    };

    const room = await joinRoom(code, playerData);
    if (room) {
      this.room = room;
      this.room.code = code;
      this.room.games = room.games || DEFAULT_GAMES;
      this.showLobby();
    } else {
      alert('Room not found');
    }
  }

  showLobby() {
    this.currentScreen = 'lobby';
    const playersHtml = (this.room.players || []).map(p => `
      <div class="player-card">
        <div class="player-avatar">
          <canvas class="avatar-preview-canvas" width="60" height="60"></canvas>
        </div>
        <div class="player-name">${p.name}</div>
        <div class="player-status">Score: ${p.score || 0}</div>
      </div>
    `).join('');

    this.render(`
      <div class="lobby-screen">
        <h2>Game Lobby</h2>
        <div class="room-code-display" id="roomCode">${this.room.code || 'OFFLINE'}</div>
        <h3>Players</h3>
        <div class="players-grid">${playersHtml}</div>
        <h3>Games</h3>
        <div class="button-grid">
          <button class="btn btn-primary" id="startBtn">Start Game</button>
          <button class="btn btn-secondary" id="backBtn">Back</button>
        </div>
      </div>
    `, 'lobby-screen');

    // Draw avatars
    (this.room.players || []).forEach(p => {
      const canvases = document.querySelectorAll('.avatar-preview-canvas');
      canvases.forEach((canvas, i) => {
        if (i < (this.room.players || []).length) {
          const avatar = new AvatarClass();
          const parts = (this.room.players[i].avatar || '0-0-0').split('-');
          avatar.headType = parseInt(parts[0]);
          avatar.bodyType = parseInt(parts[1]);
          avatar.colorIndex = parseInt(parts[2]);
          avatar.draw(canvas);
        }
      });
    });

    document.getElementById('roomCode').onclick = () => {
      navigator.clipboard.writeText(this.room.code);
      alert('Room code copied!');
    };

    document.getElementById('startBtn').onclick = () => this.startGameSequence();
    document.getElementById('backBtn').onclick = () => this.showStart();
  }

  startGameSequence() {
    this.currentGameIndex = 0;
    this.scores = {};
    this.playNextGame();
  }

  playNextGame() {
    if (this.currentGameIndex >= this.selectedGames.length) {
      this.showResults();
      return;
    }

    const gameKey = this.selectedGames[this.currentGameIndex];
    const game = GAMES[gameKey];

    this.currentScreen = 'game';
    this.render(`
      <div class="game-screen">
        <div class="game-hud">
          <div class="hud-item">${game.name}</div>
          <div class="hud-item">Score: <span id="score">0</span></div>
        </div>
        <div class="game-container">
          <canvas class="game-canvas" id="gameCanvas"></canvas>
        </div>
      </div>
    `, 'game-screen');

    this.loadGame(gameKey);
  }

  loadGame(gameKey) {
    const canvas = document.getElementById('gameCanvas');
    const game = GAMES[gameKey];
    let gameInstance = null;

    const updateScore = (score) => {
      document.getElementById('score').textContent = score;
    };

    // Canvas games
    if (game.type === 'action') {
      if (gameKey === 'fishana') gameInstance = new Fishana(canvas, updateScore);
      else if (gameKey === 'cars') gameInstance = new Cars(canvas, updateScore);
      else if (gameKey === 'space') gameInstance = new Space(canvas, updateScore);
      else if (gameKey === 'obby') gameInstance = new Obby(canvas, updateScore);

      if (gameInstance) {
        const startTime = Date.now();
        this.gameLoop = setInterval(() => {
          const dt = Date.now() - startTime;
          const cont = gameInstance.update(dt);
          gameInstance.draw();
          if (!cont) this.endGame(gameKey, gameInstance);
        }, 1000 / 60);
      }
    }
    // DOM games
    else if (game.type === 'cards') {
      gameInstance = new Badaam(canvas.parentElement, updateScore);
      const startTime = Date.now();
      this.gameLoop = setInterval(() => {
        const dt = Date.now() - startTime;
        const cont = gameInstance.update(dt);
        if (!cont) this.endGame(gameKey, gameInstance);
      }, 100);
    } else if (game.type === 'quiz') {
      if (gameKey === 'quiz') gameInstance = new Quiz(canvas.parentElement, updateScore);
      else if (gameKey === 'math') gameInstance = new MathDash(canvas.parentElement, updateScore);

      const startTime = Date.now();
      this.gameLoop = setInterval(() => {
        const dt = Date.now() - startTime;
        const cont = gameInstance.update(dt);
        if (!cont) this.endGame(gameKey, gameInstance);
      }, 100);
    }

    this.gameInstance = gameInstance;
  }

  endGame(gameKey, gameInstance) {
    clearInterval(this.gameLoop);
    const result = gameInstance.getResult();
    this.scores[gameKey] = result.score || 0;
    setTimeout(() => this.playNextGame(), 1500);
  }

  showResults() {
    this.currentScreen = 'results';
    const sorted = Object.entries(this.scores)
      .map(([key, score]) => ({ name: GAMES[key].name, score }))
      .sort((a, b) => b.score - a.score);

    const totalScore = Object.values(this.scores).reduce((a, b) => a + b, 0);

    const leaderboardHtml = sorted.map((item, i) => `
      <div class="leaderboard-row">
        <div class="medal">${['🥇', '🥈', '🥉'][i] || '⭐'}</div>
        <div class="leaderboard-info">
          <div class="leaderboard-name">${item.name}</div>
          <div class="leaderboard-score">${item.score} points</div>
        </div>
      </div>
    `).join('');

    this.render(`
      <div class="lobby-screen">
        <h1 class="results-title">Series Complete!</h1>
        <h2>Total Score: ${totalScore}</h2>
        <div class="leaderboard">${leaderboardHtml}</div>
        <div class="button-grid">
          <button class="btn btn-primary" id="replayBtn">Play Again</button>
          <button class="btn btn-secondary" id="homeBtn">Home</button>
        </div>
      </div>
    `, 'lobby-screen');

    document.getElementById('replayBtn').onclick = () => this.startGameSequence();
    document.getElementById('homeBtn').onclick = () => this.showStart();
  }

  async quickPlay() {
    this.playerName = 'Player ' + Math.floor(Math.random() * 10000);
    this.avatar = new Avatar();
    this.selectedGames = [...DEFAULT_GAMES];
    this.room = new OfflineRoom('QUICK', { id: 'quick', name: this.playerName });
    this.startGameSequence();
  }
}

// Start the app
new GameIO();
