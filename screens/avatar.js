// Avatar selection screen

import { Screen, screenManager } from '../screens.js';
import { gameState } from '../state.js';
import { AVATAR_FACES, AVATAR_BODIES, AVATAR_ACCESSORIES } from '../config.js';

export class AvatarScreen extends Screen {
  constructor() {
    super();
    this.element.className = 'screen';
    this.selectedFace = gameState.playerAvatar.face;
    this.selectedBody = gameState.playerAvatar.body;
    this.selectedAcc = gameState.playerAvatar.acc;
    this.build();
  }

  build() {
    this.element.innerHTML = '';
    const container = this.createElement('div', 'container flex flex-col items-center gap-4');

    const title = this.createElement('h1', '', 'Choose Your Avatar');
    const preview = this.createElement('div', 'flex items-center justify-center gap-2', '');
    preview.style.fontSize = '60px';
    preview.style.minHeight = '80px';

    const updatePreview = () => {
      preview.innerHTML = `${this.selectedFace}${this.selectedBody}${this.selectedAcc}`;
    };

    updatePreview();

    // Face selection
    const faceLabel = this.createElement('h3', '', 'Face');
    const faceGrid = this.createElement('div', 'grid grid-cols-5 gap-2');
    AVATAR_FACES.forEach(face => {
      const btn = this.createElement('button', '', face);
      btn.style.fontSize = '28px';
      if (face === this.selectedFace) btn.style.outline = '3px solid #0f8fe8';
      btn.onclick = () => {
        this.selectedFace = face;
        updatePreview();
        this.build();
      };
      faceGrid.appendChild(btn);
    });

    // Body selection
    const bodyLabel = this.createElement('h3', '', 'Body');
    const bodyGrid = this.createElement('div', 'grid grid-cols-4 gap-2');
    AVATAR_BODIES.forEach(body => {
      const btn = this.createElement('button', '', body);
      btn.style.fontSize = '28px';
      if (body === this.selectedBody) btn.style.outline = '3px solid #0f8fe8';
      btn.onclick = () => {
        this.selectedBody = body;
        updatePreview();
        this.build();
      };
      bodyGrid.appendChild(btn);
    });

    // Accessory selection
    const accLabel = this.createElement('h3', '', 'Accessory');
    const accGrid = this.createElement('div', 'grid grid-cols-4 gap-2');
    AVATAR_ACCESSORIES.forEach(acc => {
      const btn = this.createElement('button', '', acc);
      btn.style.fontSize = '28px';
      if (acc === this.selectedAcc) btn.style.outline = '3px solid #0f8fe8';
      btn.onclick = () => {
        this.selectedAcc = acc;
        updatePreview();
        this.build();
      };
      accGrid.appendChild(btn);
    });

    // Continue button
    const continueBtn = this.createElement('button', '', 'Continue');
    continueBtn.style.width = '100%';
    continueBtn.style.marginTop = '20px';
    continueBtn.onclick = () => {
      gameState.setAvatar(this.selectedFace, this.selectedBody, this.selectedAcc);
      screenManager.show('setup');
    };

    container.appendChild(title);
    container.appendChild(preview);
    container.appendChild(faceLabel);
    container.appendChild(faceGrid);
    container.appendChild(bodyLabel);
    container.appendChild(bodyGrid);
    container.appendChild(accLabel);
    container.appendChild(accGrid);
    container.appendChild(continueBtn);

    this.element.appendChild(container);
  }
}
