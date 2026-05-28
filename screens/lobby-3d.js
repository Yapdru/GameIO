// 3D Lobby screen - players walk around and see each other

import { Screen, screenManager } from '../screens.js';
import { gameState } from '../state.js';
import { firebase } from '../firebase.js';
import { GAMES } from '../config.js';
import { ThreeLobby } from '../three-lobby.js';

export class Lobby3DScreen extends Screen {
  constructor() {
    super();
    this.element.className = 'screen';
    this.element.style.display = 'flex';
    this.element.style.flexDirection = 'column';
    this.element.style.background = '#000';

    this.lobby3d = null;
    this.pollInterval = null;
    this.build();
  }

  build() {
    this.element.innerHTML = '';

    // HUD overlay
    const hud = this.createElement('div', '', '');
    hud.style.position = 'fixed';
    hud.style.top = '0';
    hud.style.left = '0';
    hud.style.right = '0';
    hud.style.background = 'linear-gradient(to bottom, rgba(0,0,0,0.7), transparent)';
    hud.style.color = 'white';
    hud.style.padding = '20px';
    hud.style.zIndex = '10';
    hud.style.fontFamily = 'system-ui';

    const title = this.createElement('h2', '', 'GAMEIO LOBBY');
    title.style.margin = '0 0 10px 0';
    title.style.fontSize = '24px';

    const info = this.createElement('div', '', '');
    info.id = 'lobbyInfo';
    info.style.fontSize = '14px';

    hud.appendChild(title);
    hud.appendChild(info);

    // Canvas for 3D
    const canvas = this.createElement('canvas');
    canvas.id = 'lobbyCanvas';
    canvas.style.flex = '1';
    canvas.style.width = '100%';
    canvas.style.height = '100%';

    // Controls overlay (bottom)
    const controls = this.createElement('div', '', '');
    controls.style.position = 'fixed';
    controls.style.bottom = '0';
    controls.style.left = '0';
    controls.style.right = '0';
    controls.style.background = 'linear-gradient(to top, rgba(0,0,0,0.8), transparent)';
    controls.style.color = 'white';
    controls.style.padding = '20px';
    controls.style.zIndex = '10';
    controls.style.fontSize = '12px';
    controls.style.textAlign = 'center';

    controls.innerHTML = `
      <div style="margin-bottom: 10px">
        <strong>WASD</strong> or Arrow Keys to move<br>
        Walk to portals to enter games
      </div>
      <button id="hostSelect" class="btn" style="display: none">Select Game (HOST)</button>
    `;

    this.element.appendChild(hud);
    this.element.appendChild(canvas);
    this.element.appendChild(controls);

    // Initialize 3D lobby
    this.lobby3d = new ThreeLobby(canvas);

    // Handle portal entry - only for host
    this.lastPortalEntry = null;
    this.lobby3d.onPortalEnter = (portal) => {
      if (!gameState.isHost) return;

      // Prevent rapid re-triggering
      const now = Date.now();
      if (this.lastPortalEntry && now - this.lastPortalEntry < 1000) return;

      this.lastPortalEntry = now;
      this.launchGame(portal.key);
    };

    this.lobby3d.start();

    // Host game selector
    if (gameState.isHost) {
      const hostSelectBtn = this.element.querySelector('#hostSelect');
      hostSelectBtn.style.display = 'block';
      hostSelectBtn.onclick = () => this.showGameSelector();
    }

    // Handle window resize
    window.addEventListener('resize', () => this.handleResize());
  }

  async launchGame(gameKey) {
    gameState.currentGame = gameKey;
    await firebase.updateRoom(gameState.roomCode, {
      currentGame: gameKey,
      startedAt: Date.now()
    });
    screenManager.show('game');
  }

  showGameSelector() {
    const modal = this.createElement('div', '', '');
    modal.style.position = 'fixed';
    modal.style.inset = '0';
    modal.style.background = 'rgba(0,0,0,0.9)';
    modal.style.display = 'flex';
    modal.style.flexDirection = 'column';
    modal.style.alignItems = 'center';
    modal.style.justifyContent = 'center';
    modal.style.zIndex = '100';
    modal.style.gap = '20px';

    const title = this.createElement('h1', '', 'Select Game');
    title.style.color = 'white';

    const gameGrid = this.createElement('div', '', '');
    gameGrid.style.display = 'grid';
    gameGrid.style.gridTemplateColumns = 'repeat(3, 1fr)';
    gameGrid.style.gap = '20px';

    Object.entries(GAMES).forEach(([key, game]) => {
      const btn = this.createElement('button', '', '');
      btn.style.padding = '20px';
      btn.style.fontSize = '24px';
      btn.style.minWidth = '150px';
      btn.innerHTML = `
        <div style="font-size: 48px; margin-bottom: 10px">${game.icon}</div>
        <div style="font-weight: 900; margin-bottom: 5px">${game.name}</div>
        <div style="font-size: 12px; color: #888">${game.description}</div>
      `;
      btn.onclick = async () => {
        await this.launchGame(key);
      };
      gameGrid.appendChild(btn);
    });

    const closeBtn = this.createElement('button', 'secondary', 'Cancel');
    closeBtn.onclick = () => modal.remove();

    modal.appendChild(title);
    modal.appendChild(gameGrid);
    modal.appendChild(closeBtn);

    this.element.appendChild(modal);
  }

  onShow() {
    // Sync room state
    this.syncRoom();
    this.pollInterval = setInterval(() => this.syncRoom(), 500);
  }

  onHide() {
    if (this.lobby3d) {
      this.lobby3d.stop();
    }
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

    // Update HUD
    const info = document.getElementById('lobbyInfo');
    if (info) {
      const playerCount = gameState.players.length;
      info.innerHTML = `
        Room: <strong>${gameState.roomCode}</strong> |
        Players: <strong>${playerCount}</strong> |
        Role: <strong>${gameState.isHost ? 'HOST' : 'PLAYER'}</strong>
      `;
    }

    // Check if host started game
    if (room.currentGame && !gameState.isHost) {
      gameState.currentGame = room.currentGame;
      screenManager.show('game');
    }
  }

  handleResize() {
    if (this.lobby3d) {
      this.lobby3d.handleResize();
    }
  }
}
