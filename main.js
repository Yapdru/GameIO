// Main entry point for GameIO

import { screenManager } from './screens.js';
import { gameState } from './state.js';

// Import all screens
import { StartScreen } from './screens/start.js';
import { AvatarScreen } from './screens/avatar.js';
import { SetupScreen } from './screens/setup.js';
import { JoinScreen } from './screens/join.js';
import { LobbyScreen } from './screens/lobby.js';
import { GameScreen } from './screens/game.js';

// Register all screens
screenManager.register('start', StartScreen);
screenManager.register('avatar', AvatarScreen);
screenManager.register('setup', SetupScreen);
screenManager.register('join', JoinScreen);
screenManager.register('lobby', LobbyScreen);
screenManager.register('game', GameScreen);

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
