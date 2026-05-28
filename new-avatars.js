// Avatar builder - creates clean SVG-based avatars
import { AVATAR_PARTS, Avatar } from './new-game-data.js';

// Avatar drawing methods
Avatar.prototype.draw = function(canvas) {
    const ctx = canvas.getContext('2d');
    const w = canvas.width;
    const h = canvas.height;

    ctx.fillStyle = '#fff';
    ctx.fillRect(0, 0, w, h);

    const headColor = AVATAR_PARTS.color[this.colorIndex];
    const bodyColor = AVATAR_PARTS.color[(this.colorIndex + 1) % AVATAR_PARTS.color.length];

    // Draw body
    ctx.fillStyle = bodyColor;
    if (this.bodyType === 0) {
      // Rectangle body
      ctx.fillRect(w * 0.25, h * 0.5, w * 0.5, h * 0.35);
    } else if (this.bodyType === 1) {
      // Circle body
      ctx.beginPath();
      ctx.arc(w * 0.5, h * 0.65, w * 0.2, 0, Math.PI * 2);
      ctx.fill();
    } else {
      // Triangle body
      ctx.beginPath();
      ctx.moveTo(w * 0.5, h * 0.5);
      ctx.lineTo(w * 0.2, h * 0.85);
      ctx.lineTo(w * 0.8, h * 0.85);
      ctx.fill();
    }

    // Draw head
    ctx.fillStyle = headColor;
    if (this.headType === 0) {
      // Circle head
      ctx.beginPath();
      ctx.arc(w * 0.5, h * 0.3, w * 0.15, 0, Math.PI * 2);
      ctx.fill();
    } else if (this.headType === 1) {
      // Square head
      ctx.fillRect(w * 0.35, h * 0.15, w * 0.3, h * 0.3);
    } else {
      // Triangle head
      ctx.beginPath();
      ctx.moveTo(w * 0.5, h * 0.1);
      ctx.lineTo(w * 0.3, h * 0.45);
      ctx.lineTo(w * 0.7, h * 0.45);
      ctx.fill();
    }

    // Draw eyes
    ctx.fillStyle = '#fff';
    ctx.beginPath();
    ctx.arc(w * 0.42, h * 0.28, w * 0.04, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(w * 0.58, h * 0.28, w * 0.04, 0, Math.PI * 2);
    ctx.fill();

    // Draw pupils
    ctx.fillStyle = '#000';
    ctx.beginPath();
    ctx.arc(w * 0.42, h * 0.28, w * 0.02, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(w * 0.58, h * 0.28, w * 0.02, 0, Math.PI * 2);
    ctx.fill();

    // Draw mouth
    ctx.strokeStyle = '#000';
    ctx.lineWidth = w * 0.02;
    ctx.beginPath();
    ctx.arc(w * 0.5, h * 0.35, w * 0.05, 0, Math.PI);
    ctx.stroke();
};

export function renderAvatarPicker(containerId, onSelect) {
  const container = document.getElementById(containerId);
  if (!container) return;

  container.innerHTML = '';

  // Head selection
  const headLabel = document.createElement('div');
  headLabel.textContent = 'Head Shape';
  headLabel.style.marginTop = '20px';
  headLabel.style.marginBottom = '8px';
  headLabel.style.fontWeight = '600';
  container.appendChild(headLabel);

  const headGrid = document.createElement('div');
  headGrid.style.display = 'grid';
  headGrid.style.gridTemplateColumns = 'repeat(3, 1fr)';
  headGrid.style.gap = '8px';
  headGrid.style.marginBottom = '20px';

  AVATAR_PARTS.head.forEach((_, i) => {
    const btn = document.createElement('button');
    btn.className = 'part-btn';
    btn.textContent = AVATAR_PARTS.head[i].name[0];
    btn.dataset.type = 'head';
    btn.dataset.index = i;
    btn.onclick = () => onSelect('head', i);
    headGrid.appendChild(btn);
  });
  container.appendChild(headGrid);

  // Body selection
  const bodyLabel = document.createElement('div');
  bodyLabel.textContent = 'Body Shape';
  bodyLabel.style.marginBottom = '8px';
  bodyLabel.style.fontWeight = '600';
  container.appendChild(bodyLabel);

  const bodyGrid = document.createElement('div');
  bodyGrid.style.display = 'grid';
  bodyGrid.style.gridTemplateColumns = 'repeat(3, 1fr)';
  bodyGrid.style.gap = '8px';
  bodyGrid.style.marginBottom = '20px';

  AVATAR_PARTS.body.forEach((_, i) => {
    const btn = document.createElement('button');
    btn.className = 'part-btn';
    btn.textContent = AVATAR_PARTS.body[i].name[0];
    btn.dataset.type = 'body';
    btn.dataset.index = i;
    btn.onclick = () => onSelect('body', i);
    bodyGrid.appendChild(btn);
  });
  container.appendChild(bodyGrid);

  // Color selection
  const colorLabel = document.createElement('div');
  colorLabel.textContent = 'Color';
  colorLabel.style.marginBottom = '8px';
  colorLabel.style.fontWeight = '600';
  container.appendChild(colorLabel);

  const colorGrid = document.createElement('div');
  colorGrid.style.display = 'grid';
  colorGrid.style.gridTemplateColumns = 'repeat(6, 1fr)';
  colorGrid.style.gap = '8px';

  AVATAR_PARTS.color.forEach((color, i) => {
    const btn = document.createElement('button');
    btn.className = 'part-btn';
    btn.style.background = color;
    btn.style.fontSize = '0.8rem';
    btn.textContent = '●';
    btn.dataset.type = 'color';
    btn.dataset.index = i;
    btn.onclick = () => onSelect('color', i);
    colorGrid.appendChild(btn);
  });
  container.appendChild(colorGrid);
}
