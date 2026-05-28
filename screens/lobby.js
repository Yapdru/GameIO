// Lobby screen - waiting area before game

import { Screen, screenManager } from '../screens.js';
import { gameState } from '../state.js';
import { firebase } from '../firebase.js';
import { GAMES } from '../config.js';

export class LobbyScreen extends Screen {
  constructor() {
    super();
    this.element.className = 'screen';
    this.pollInterval = null;
    this.build();
  }

  build() {
    this.element.innerHTML = '';
    const container = this.createElement('div', 'container flex flex-col gap-4');

    // Header
    const header = this.createElement('div', 'flex justify-between items-center');

    const title = this.createElement('h1', '', 'Game Lobby');
    const badge = this.createElement('span', 'badge', gameState.isHost ? 'HOST' : 'PLAYER');

    header.appendChild(title);
    header.appendChild(badge);
    container.appendChild(header);

    // Room code display
    if (gameState.roomCode) {
      const roomInfo = this.createElement('div', 'room-info');
      const codeLabel = this.createElement('p', '', 'Room Code');
      const code = this.createElement('div', 'room-code', gameState.roomCode);
      const copyHint = this.createElement('p', 'room-code-copy', 'Share this code with friends');

      roomInfo.appendChild(codeLabel);
      roomInfo.appendChild(code);
      roomInfo.appendChild(copyHint);

      code.style.cursor = 'pointer';
      code.onclick = () => {
        navigator.clipboard.writeText(gameState.roomCode);
        copyHint.textContent = '✓ Copied!';
      };

      container.appendChild(roomInfo);
    }

    // Player list
    const playersLabel = this.createElement('h2', '', 'Players');
    const playerList = this.createElement('div', 'player-list');
    playerList.id = 'playerList';

    this.updatePlayerList(playerList);

    container.appendChild(playersLabel);
    container.appendChild(playerList);

    // Game selector (host only)
    if (gameState.isHost) {
      const gameLabel = this.createElement('h2', '', 'Select Game');
      const gameGrid = this.createElement('div', 'grid grid-cols-3 gap-3');

      Object.entries(GAMES).forEach(([key, game]) => {
        const gameCard = this.createElement('button', 'card', '');
        gameCard.style.border = 'none';
        gameCard.style.background = 'white';
        gameCard.style.padding = '16px';
        gameCard.innerHTML = `
          <div style="font-size: 32px; margin-bottom: 8px">${game.icon}</div>
          <div style="font-weight: 900">${game.name}</div>
          <div style="font-size: 12px; color: #888">${game.description}</div>
        `;
        gameCard.onclick = async () => {
          await firebase.updateRoom(gameState.roomCode, {
            currentGame: key,
            startedAt: Date.now()
          });
          screenManager.show('game');
        };
        gameGrid.appendChild(gameCard);
      });

      container.appendChild(gameLabel);
      container.appendChild(gameGrid);
    }

    this.element.appendChild(container);
  }

  updatePlayerList(playerList) {
    playerList.innerHTML = '';
    gameState.players.forEach(player => {
      const card = this.createElement('div', 'card');
      const { face, body, acc } = player.avatar || {};
      card.innerHTML = `
        <div style="font-size: 32px; margin-bottom: 8px">${face}${body}${acc}</div>
        <div class="player-name">${player.name}</div>
        <div class="player-score">Score: ${gameState.scores[player.id] || 0}</div>
      `;
      playerList.appendChild(card);
    });
  }

  onShow() {
    // Initial sync
    this.syncRoom();

    // Poll for updates every 500ms
    this.pollInterval = setInterval(() => this.syncRoom(), 500);
  }

  onHide() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval);
    }
  }

  async syncRoom() {
    if (!gameState.roomCode) return;

    const room = await firebase.getRoom(gameState.roomCode);
    if (!room) return;

    // Update players
    if (room.players) {
      gameState.players = Object.values(room.players);
    }

    // Update scores if they changed
    if (room.scores) {
      gameState.scores = room.scores;
    }

    const playerList = document.getElementById('playerList');
    if (playerList) {
      this.updatePlayerList(playerList);
    }

    // Check if host started game
    if (room.currentGame && !gameState.isHost) {
      gameState.currentGame = room.currentGame;
      screenManager.show('game');
    }
  }
}
