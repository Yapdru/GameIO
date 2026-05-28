// Join room screen

import { Screen, screenManager } from '../screens.js';
import { gameState } from '../state.js';
import { firebase } from '../firebase.js';

export class JoinScreen extends Screen {
  constructor() {
    super();
    this.element.className = 'screen';
    this.build();
  }

  build() {
    this.element.innerHTML = '';
    const container = this.createElement('div', 'container flex flex-col items-center gap-4');

    const title = this.createElement('h1', '', 'Join Game');
    const subtitle = this.createElement('p', '', 'Enter room code to join');

    // Code input
    const codeInput = this.createElement('input', '', '');
    codeInput.type = 'text';
    codeInput.placeholder = 'Room code';
    codeInput.style.width = '100%';
    codeInput.style.maxWidth = '300px';
    codeInput.style.fontSize = '24px';
    codeInput.style.letterSpacing = '4px';
    codeInput.style.textAlign = 'center';
    codeInput.setAttribute('maxlength', '6');

    // Buttons
    const buttonContainer = this.createElement('div', 'flex gap-3 flex-col', '');
    buttonContainer.style.width = '100%';
    buttonContainer.style.maxWidth = '300px';

    const joinBtn = this.createElement('button', '', 'Join Room');
    joinBtn.onclick = async () => {
      const code = codeInput.value.trim().toUpperCase();
      if (!code) {
        alert('Enter a room code');
        return;
      }

      const room = await firebase.getRoom(code);
      if (!room) {
        alert('Room not found');
        return;
      }

      gameState.joinRoom(code);
      // Add this player to room
      await firebase.setPlayer(code, gameState.playerId, {
        ...gameState.getPlayerData(),
        joinedAt: Date.now()
      });

      screenManager.show('arrival'); // Show cinematic arrival before lobby
    };

    const backBtn = this.createElement('button', 'secondary', 'Back');
    backBtn.onclick = () => screenManager.show('start');

    buttonContainer.appendChild(joinBtn);
    buttonContainer.appendChild(backBtn);

    container.appendChild(title);
    container.appendChild(subtitle);
    container.appendChild(codeInput);
    container.appendChild(buttonContainer);

    this.element.appendChild(container);
  }
}
