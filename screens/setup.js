// Game setup screen (name + create/join room)

import { Screen, screenManager } from '../screens.js';
import { gameState } from '../state.js';

export class SetupScreen extends Screen {
  constructor() {
    super();
    this.element.className = 'screen';
    this.build();
  }

  build() {
    this.element.innerHTML = '';
    const container = this.createElement('div', 'container flex flex-col items-center gap-4');

    const title = this.createElement('h1', '', 'Setup Game');

    // Avatar preview
    const avatar = this.createElement('div', '', '');
    avatar.style.fontSize = '48px';
    avatar.style.marginBottom = '20px';
    const { face, body, acc } = gameState.playerAvatar;
    avatar.innerHTML = `${face}${body}${acc}`;

    // Name input
    const nameLabel = this.createElement('h3', '', 'Your Name');
    const nameInput = this.createElement('input', '', '');
    nameInput.type = 'text';
    nameInput.placeholder = 'Enter your name';
    nameInput.value = gameState.playerName;
    nameInput.style.width = '100%';
    nameInput.style.maxWidth = '300px';

    // Action buttons
    const actionContainer = this.createElement('div', 'flex gap-3 flex-col', '');
    actionContainer.style.width = '100%';
    actionContainer.style.maxWidth = '300px';

    const createBtn = this.createElement('button', '', 'Create Game');
    createBtn.onclick = () => {
      gameState.setPlayerName(nameInput.value);
      gameState.createRoom();
      screenManager.show('lobby');
    };

    const joinBtn = this.createElement('button', 'secondary', 'Join Game');
    joinBtn.onclick = () => {
      gameState.setPlayerName(nameInput.value);
      screenManager.show('join');
    };

    actionContainer.appendChild(createBtn);
    actionContainer.appendChild(joinBtn);

    container.appendChild(title);
    container.appendChild(avatar);
    container.appendChild(nameLabel);
    container.appendChild(nameInput);
    container.appendChild(actionContainer);

    this.element.appendChild(container);
  }
}
