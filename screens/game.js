// Game screen - placeholder for now

import { Screen, screenManager } from '../screens.js';
import { gameState } from '../state.js';

export class GameScreen extends Screen {
  constructor() {
    super();
    this.element.className = 'screen';
    this.build();
  }

  build() {
    this.element.innerHTML = '';
    const container = this.createElement('div', 'container center flex flex-col gap-4');

    const title = this.createElement('h1', '', `Playing: ${gameState.currentGame}`);
    const placeholder = this.createElement('p', '', '(Game implementation coming soon)');

    const backBtn = this.createElement('button', '', 'Back to Lobby');
    backBtn.onclick = () => {
      gameState.endGame();
      screenManager.show('lobby');
    };

    container.appendChild(title);
    container.appendChild(placeholder);
    container.appendChild(backBtn);

    this.element.appendChild(container);
  }
}
