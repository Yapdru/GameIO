// Main entry point for GameIO

import { screenManager } from './screens.js';
import { gameState } from './state.js';

// Import all screens
import { StartScreen } from './screens/start.js';
import { AvatarScreen } from './screens/avatar.js';
import { SetupScreen } from './screens/setup.js';
import { JoinScreen } from './screens/join.js';
import { LobbyScreen } from './screens/lobby.js';
import { Lobby3DScreen } from './screens/lobby-3d.js';
import { GameScreen } from './screens/game.js';
import { ResultsScreen } from './screens/results.js';

// Register all screens
screenManager.register('start', StartScreen);
screenManager.register('avatar', AvatarScreen);
screenManager.register('setup', SetupScreen);
screenManager.register('join', JoinScreen);
screenManager.register('lobby', Lobby3DScreen); // Use 3D lobby
screenManager.register('lobby-2d', LobbyScreen); // Keep 2D as fallback
screenManager.register('game', GameScreen);
screenManager.register('results', ResultsScreen);

// Start the app
async function init() {
  console.log('GameIO initializing...');
  console.log('Player ID:', gameState.playerId);
  console.log('Avatar:', gameState.playerAvatar);

  // Show start screen
  await screenManager.show('start');
}

// Wait for DOM to be ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
