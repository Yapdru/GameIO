// Start/title screen

import { Screen, screenManager } from '../screens.js';
import { gameState } from '../state.js';

export class StartScreen extends Screen {
  constructor() {
    super();
    this.element.className = 'screen center';
    this.build();
  }

  build() {
    const container = this.createElement('div', 'container center');

    const title = this.createElement('h1', '', 'GAMEIO ⚡');
    const subtitle = this.createElement('p', '', 'Multiplayer Arcade Universe');

    const buttonContainer = this.createElement('div', 'flex flex-col gap-3', '');

    const createBtn = this.createElement('button', '', 'Create Game');
    createBtn.onclick = () => screenManager.show('avatar');

    const joinBtn = this.createElement('button', 'secondary', 'Join Game');
    joinBtn.onclick = () => screenManager.show('join');

    buttonContainer.appendChild(createBtn);
    buttonContainer.appendChild(joinBtn);

    container.appendChild(title);
    container.appendChild(subtitle);
    container.appendChild(buttonContainer);

    this.element.appendChild(container);
  }
}
