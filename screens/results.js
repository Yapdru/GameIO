// Results screen - shows scores and winner after game round

import { Screen, screenManager } from '../screens.js';
import { gameState } from '../state.js';
import { firebase } from '../firebase.js';

export class ResultsScreen extends Screen {
  constructor() {
    super();
    this.element.className = 'screen';
    this.element.style.display = 'flex';
    this.element.style.flexDirection = 'column';
    this.element.style.background = 'linear-gradient(135deg, #1a5f7a 0%, #0f3a4a 100%)';
  }

  build() {
    this.element.innerHTML = '';

    // Header
    const header = this.createElement('div', '', '');
    header.style.padding = '40px 20px';
    header.style.textAlign = 'center';
    header.style.color = 'white';

    const title = this.createElement('h1', '', 'ROUND RESULTS');
    title.style.margin = '0 0 10px 0';
    title.style.fontSize = '48px';

    const gameTitle = this.createElement('p', '', `${gameState.currentGame.toUpperCase()}`);
    gameTitle.style.margin = '0';
    gameTitle.style.fontSize = '24px';
    gameTitle.style.color = '#ffd84d';

    header.appendChild(title);
    header.appendChild(gameTitle);
    this.element.appendChild(header);

    // Scores container
    const scoresContainer = this.createElement('div', '', '');
    scoresContainer.style.flex = '1';
    scoresContainer.style.padding = '20px';
    scoresContainer.style.overflowY = 'auto';

    // Leaderboard
    const leaderboard = this.createElement('div', '', '');
    leaderboard.style.maxWidth = '500px';
    leaderboard.style.margin = '0 auto';

    // Sort players by score
    const sortedPlayers = Object.entries(gameState.scores)
      .map(([playerId, score]) => {
        const player = gameState.players.find(p => p.id === playerId);
        return {
          id: playerId,
          name: player?.name || 'Unknown',
          score: score,
          isCurrentPlayer: playerId === gameState.playerId
        };
      })
      .sort((a, b) => b.score - a.score);

    // Display scores
    sortedPlayers.forEach((player, idx) => {
      const scoreRow = this.createElement('div', '', '');
      scoreRow.style.padding = '15px';
      scoreRow.style.marginBottom = '10px';
      scoreRow.style.background = player.isCurrentPlayer ? 'rgba(255, 216, 77, 0.2)' : 'rgba(255, 255, 255, 0.1)';
      scoreRow.style.borderLeft = player.isCurrentPlayer ? '4px solid #ffd84d' : '4px solid transparent';
      scoreRow.style.borderRadius = '4px';
      scoreRow.style.color = 'white';

      let medal = '';
      if (idx === 0) medal = '🥇 ';
      else if (idx === 1) medal = '🥈 ';
      else if (idx === 2) medal = '🥉 ';

      const scoreText = this.createElement('div', '', '');
      scoreText.innerHTML = `${medal}<strong>${player.name}</strong>: ${Math.floor(player.score)} pts`;
      scoreText.style.fontSize = '18px';

      scoreRow.appendChild(scoreText);
      leaderboard.appendChild(scoreRow);
    });

    scoresContainer.appendChild(leaderboard);
    this.element.appendChild(scoresContainer);

    // Footer buttons
    const footer = this.createElement('div', 'flex gap-2 justify-center', '');
    footer.style.padding = '20px';
    footer.style.background = 'rgba(0, 0, 0, 0.3)';

    const nextBtn = this.createElement('button', 'primary', 'Next Game');
    nextBtn.style.flex = '1';
    nextBtn.onclick = () => this.nextGame();

    const lobbyBtn = this.createElement('button', 'secondary', 'Back to Lobby');
    lobbyBtn.style.flex = '1';
    lobbyBtn.onclick = () => screenManager.show('lobby');

    footer.appendChild(nextBtn);
    footer.appendChild(lobbyBtn);
    this.element.appendChild(footer);
  }

  async nextGame() {
    if (gameState.isHost) {
      // Host selects next game
      screenManager.show('lobby');
    } else {
      // Wait for host to select next game
      screenManager.show('lobby');
    }
  }

  onShow() {
    // Refresh scores from Firebase
    if (gameState.roomCode) {
      firebase.getRoomPlayers(gameState.roomCode, (players) => {
        // Update game state with latest scores
      });
    }
  }
}
