// GAMEIO - Main App Controller
// Handles all screens and flow

import { GAMES, DEFAULT_GAME_ORDER, AVATAR_CONFIG } from './game-data.js';
import { Avatar, renderAvatarPicker } from './avatars.js';
import { createRoom, joinRoom, getRoom, OfflineRoom } from './firebase.js';

class GameIO {
  constructor() {
    this.app = document.getElementById('app');

    // Player state
    this.playerId = 'player_' + Math.random().toString(36).slice(2, 8);
    this.playerName = 'Player ' + Math.floor(Math.random() * 9000 + 1000);
    this.avatar = new Avatar();

    // Room state
    this.room = null;
    this.isHost = false;
    this.selectedGames = [...DEFAULT_GAME_ORDER];
    this.currentGameIdx = 0;
    this.scores = {};

    // Show start screen
    this.showStart();
  }

  showScreen(name) {
    this.app.innerHTML = '';
    this.app.innerHTML = this.renderScreen(name);
    this.attachHandlers(name);
  }

  renderScreen(name) {
    switch (name) {
      case 'start': return this.renderStart();
      case 'avatar': return this.renderAvatar();
      case 'lobby': return this.renderLobby();
      case 'games': return this.renderGameSelector();
      case 'game': return this.renderGame();
      case 'results': return this.renderResults();
      default: return this.renderStart();
    }
  }

  renderStart() {
    return `
      <div class="screen active start-screen">
        <div class="logo">GAMEIO</div>
        <div class="subtitle">Arcade Worlds</div>
        <div class="button-group">
          <button class="btn btn-primary" id="createBtn">Create Room</button>
          <button class="btn btn-primary" id="joinBtn">Join Room</button>
          <button class="btn btn-secondary" id="quickBtn">Quick Play</button>
        </div>
      </div>
    `;
  }

  renderAvatar() {
    return `
      <div class="screen active">
        <div class="card" style="max-width: 600px;">
          <h2>Create Your Avatar</h2>
          <div class="avatar-preview">
            <canvas id="avatarCanvas" width="120" height="120"></canvas>
          </div>
          <div id="avatarPicker"></div>
          <div class="form-group">
            <label>Your Name</label>
            <input type="text" id="playerName" placeholder="Enter your name" value="${this.playerName}">
          </div>
          <div class="button-group">
            <button class="btn btn-primary" id="continueBtn">Continue</button>
            <button class="btn btn-secondary" id="backBtn">Back</button>
          </div>
        </div>
      </div>
    `;
  }

  renderLobby() {
    const playersList = Object.values(this.room.players || {})
      .map(p => `
        <div class="player-card">
          <div class="player-avatar">
            <canvas width="60" height="60" data-player-id="${p.id}"></canvas>
          </div>
          <div class="player-name">${p.name}</div>
          <div class="player-status">Score: ${p.score || 0}</div>
        </div>
      `).join('');

    const gamesList = this.selectedGames
      .map(gk => `<span style="padding: 4px 8px; background: #f0f4ff; border-radius: 4px;">${GAMES[gk].name}</span>`)
      .join(' → ');

    return `
      <div class="screen active lobby-screen">
        <div class="card" style="max-width: 700px;">
          <h2>Game Lobby</h2>
          <div class="room-code" id="roomCode">${this.room.code}</div>
          <p style="color: #666; margin: 10px 0;">${this.selectedGames.length} games selected</p>

          <h3 style="margin-top: 30px;">Playlist</h3>
          <div style="padding: 12px; background: #f0f4ff; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem;">
            ${gamesList}
          </div>

          <h3>Players (${Object.keys(this.room.players || {}).length})</h3>
          <div class="players-list">${playersList}</div>

          <div class="button-group" style="margin-top: 30px;">
            ${this.isHost ? `
              <button class="btn btn-primary" id="startBtn">Start Games</button>
            ` : `
              <div style="color: #666;">Waiting for host to start...</div>
            `}
            <button class="btn btn-secondary btn-small" id="leaveBtn">Leave</button>
          </div>
        </div>
      </div>
    `;
  }

  renderGameSelector() {
    const gamesList = Object.entries(GAMES)
      .map(([key, g]) => `
        <div class="game-tile ${this.selectedGames.includes(key) ? 'selected' : ''}" data-game="${key}">
          <div style="font-size: 2rem; margin-bottom: 8px;">${g.icon}</div>
          <div style="font-weight: 600; font-size: 0.9rem;">${g.name}</div>
        </div>
      `).join('');

    return `
      <div class="screen active lobby-screen">
        <div class="card" style="max-width: 700px;">
          <h2>Select Games</h2>
          <p style="color: #666; margin-bottom: 20px;">Choose games for your playlist</p>
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px;">
            ${gamesList}
          </div>
          <div class="button-group" style="margin-top: 30px;">
            <button class="btn btn-primary" id="createRoomBtn">Create Room</button>
            <button class="btn btn-secondary btn-small" id="backBtn">Back</button>
          </div>
        </div>
      </div>
    `;
  }

  renderGame() {
    const gameKey = this.selectedGames[this.currentGameIdx];
    const game = GAMES[gameKey];
    return `
      <div class="screen active game-screen">
        <div class="game-hud">
          <div>${game.name}</div>
          <div>Score: <span id="score">0</span></div>
        </div>
        <div class="game-container">
          <canvas id="gameCanvas" class="game-canvas" width="800" height="600"></canvas>
        </div>
      </div>
    `;
  }

  renderResults() {
    const sorted = Object.entries(this.scores)
      .map(([key, score]) => ({ name: GAMES[key].name, score }))
      .sort((a, b) => b.score - a.score);

    const total = Object.values(this.scores).reduce((a, b) => a + b, 0);
    const medals = ['🥇', '🥈', '🥉', '⭐', '✨', '🌟', '💫'];

    return `
      <div class="screen active results-screen">
        <div class="card">
          <h1>Game Series Complete!</h1>
          <div class="results-score">${total}</div>

          <div class="leaderboard">
            ${sorted.map((item, i) => `
              <div class="leaderboard-row">
                <div class="medal">${medals[i] || '⭐'}</div>
                <div class="leaderboard-info">
                  <div class="leaderboard-name">${item.name}</div>
                  <div class="leaderboard-points">${item.score} points</div>
                </div>
              </div>
            `).join('')}
          </div>

          <div class="button-group">
            <button class="btn btn-primary" id="replayBtn">Play Again</button>
            <button class="btn btn-secondary" id="homeBtn">Home</button>
          </div>
        </div>
      </div>
    `;
  }

  attachHandlers(screenName) {
    if (screenName === 'start') {
      document.getElementById('createBtn').onclick = () => this.startCreate();
      document.getElementById('joinBtn').onclick = () => this.startJoin();
      document.getElementById('quickBtn').onclick = () => this.quickPlay();
    }

    if (screenName === 'avatar') {
      const canvas = document.getElementById('avatarCanvas');
      this.avatar.draw(canvas);

      renderAvatarPicker(document.getElementById('avatarPicker'), (type, idx) => {
        if (type === 'head') this.avatar.headIdx = idx;
        if (type === 'body') this.avatar.bodyIdx = idx;
        if (type === 'color') this.avatar.colorIdx = idx;
        this.avatar.draw(canvas);
      });

      document.getElementById('playerName').onchange = (e) => {
        this.playerName = e.target.value;
      };

      document.getElementById('continueBtn').onclick = () => this.continueFromAvatar();
      document.getElementById('backBtn').onclick = () => this.showStart();
    }

    if (screenName === 'games') {
      document.querySelectorAll('.game-tile').forEach(tile => {
        tile.onclick = () => {
          const key = tile.dataset.game;
          if (this.selectedGames.includes(key)) {
            this.selectedGames = this.selectedGames.filter(k => k !== key);
          } else {
            this.selectedGames.push(key);
          }
          this.showScreen('games');
        };
      });

      document.getElementById('createRoomBtn').onclick = () => this.doCreateRoom();
      document.getElementById('backBtn').onclick = () => this.showStart();
    }

    if (screenName === 'lobby') {
      // Draw player avatars
      document.querySelectorAll('[data-player-id]').forEach(canvas => {
        const playerId = canvas.dataset.playerId;
        const player = this.room.players[playerId];
        if (player) {
          const avatar = Avatar.deserialize(player.avatar);
          avatar.draw(canvas);
        }
      });

      document.getElementById('roomCode').onclick = () => {
        navigator.clipboard.writeText(this.room.code);
        alert('Room code copied!');
      };

      if (this.isHost) {
        document.getElementById('startBtn').onclick = () => this.startGameSequence();
      }

      document.getElementById('leaveBtn').onclick = () => this.showStart();
    }

    if (screenName === 'results') {
      document.getElementById('replayBtn').onclick = () => this.startGameSequence();
      document.getElementById('homeBtn').onclick = () => this.showStart();
    }
  }

  startCreate() {
    this.isHost = true;
    this.showScreen('avatar');
  }

  continueFromAvatar() {
    this.showScreen('games');
  }

  async doCreateRoom() {
    const playerData = {
      id: this.playerId,
      name: this.playerName,
      avatar: this.avatar.serialize(),
      score: 0
    };

    const code = await createRoom(playerData);
    this.room = new OfflineRoom(playerData);
    this.room.code = code;
    this.showScreen('lobby');
  }

  startJoin() {
    this.isHost = false;
    this.showScreen('avatar');
  }

  async quickPlay() {
    const playerData = {
      id: this.playerId,
      name: this.playerName,
      avatar: this.avatar.serialize(),
      score: 0
    };

    this.room = new OfflineRoom(playerData);
    this.selectedGames = [...DEFAULT_GAME_ORDER];
    this.startGameSequence();
  }

  startGameSequence() {
    this.currentGameIdx = 0;
    this.scores = {};
    this.playNextGame();
  }

  playNextGame() {
    if (this.currentGameIdx >= this.selectedGames.length) {
      this.showScreen('results');
      return;
    }

    this.showScreen('game');
    setTimeout(() => {
      // Placeholder: Each game will replace this
      const gameKey = this.selectedGames[this.currentGameIdx];
      const score = Math.floor(Math.random() * GAMES[gameKey].maxScore);
      this.scores[gameKey] = score;
      this.currentGameIdx++;
      this.playNextGame();
    }, 2000);
  }
}

// Start the app
new GameIO();
