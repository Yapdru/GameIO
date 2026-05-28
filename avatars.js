// Avatar builder - clean SVG-style shapes
import { AVATAR_CONFIG } from './game-data.js';

export class Avatar {
  constructor(headIdx = 0, bodyIdx = 0, colorIdx = 0) {
    this.headIdx = headIdx;
    this.bodyIdx = bodyIdx;
    this.colorIdx = colorIdx;
  }

  draw(canvas) {
    const ctx = canvas.getContext('2d');
    const w = canvas.width;
    const h = canvas.height;

    // Clear
    ctx.fillStyle = '#fff';
    ctx.fillRect(0, 0, w, h);

    const color = AVATAR_CONFIG.colors[this.colorIdx];

    // Draw body
    ctx.fillStyle = color;
    if (this.bodyIdx === 0) {
      // Rectangle
      ctx.fillRect(w * 0.25, h * 0.5, w * 0.5, h * 0.35);
    } else if (this.bodyIdx === 1) {
      // Diamond
      ctx.beginPath();
      ctx.moveTo(w * 0.5, h * 0.35);
      ctx.lineTo(w * 0.75, h * 0.65);
      ctx.lineTo(w * 0.5, h * 0.85);
      ctx.lineTo(w * 0.25, h * 0.65);
      ctx.fill();
    } else {
      // Pentagon
      const centerX = w * 0.5;
      const centerY = h * 0.65;
      const radius = w * 0.2;
      ctx.beginPath();
      for (let i = 0; i < 5; i++) {
        const angle = (i * 2 * Math.PI) / 5 - Math.PI / 2;
        const x = centerX + radius * Math.cos(angle);
        const y = centerY + radius * Math.sin(angle);
        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }
      ctx.closePath();
      ctx.fill();
    }

    // Draw head
    ctx.fillStyle = color;
    if (this.headIdx === 0) {
      // Circle
      ctx.beginPath();
      ctx.arc(w * 0.5, h * 0.25, w * 0.12, 0, Math.PI * 2);
      ctx.fill();
    } else if (this.headIdx === 1) {
      // Square
      ctx.fillRect(w * 0.38, h * 0.13, w * 0.24, w * 0.24);
    } else {
      // Triangle
      ctx.beginPath();
      ctx.moveTo(w * 0.5, h * 0.08);
      ctx.lineTo(w * 0.35, h * 0.35);
      ctx.lineTo(w * 0.65, h * 0.35);
      ctx.fill();
    }

    // Draw eyes
    ctx.fillStyle = '#000';
    ctx.beginPath();
    ctx.arc(w * 0.42, h * 0.23, w * 0.04, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(w * 0.58, h * 0.23, w * 0.04, 0, Math.PI * 2);
    ctx.fill();

    // Draw smile
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(w * 0.5, h * 0.28, w * 0.08, 0, Math.PI);
    ctx.stroke();
  }

  serialize() {
    return `${this.headIdx}-${this.bodyIdx}-${this.colorIdx}`;
  }

  static deserialize(str) {
    const [h, b, c] = str.split('-').map(Number);
    return new Avatar(h, b, c);
  }
}

export function renderAvatarPicker(container, onSelect) {
  container.innerHTML = '';

  // Heads
  const headLabel = document.createElement('h4');
  headLabel.textContent = 'Head Shape';
  headLabel.style.marginTop = '20px';
  container.appendChild(headLabel);

  const headGrid = document.createElement('div');
  headGrid.className = 'parts-grid';
  AVATAR_CONFIG.heads.forEach((head, i) => {
    const btn = document.createElement('button');
    btn.className = 'part-btn';
    btn.textContent = head.char;
    btn.onclick = () => onSelect('head', i);
    headGrid.appendChild(btn);
  });
  container.appendChild(headGrid);

  // Bodies
  const bodyLabel = document.createElement('h4');
  bodyLabel.textContent = 'Body Shape';
  bodyLabel.style.marginTop = '20px';
  container.appendChild(bodyLabel);

  const bodyGrid = document.createElement('div');
  bodyGrid.className = 'parts-grid';
  AVATAR_CONFIG.bodies.forEach((body, i) => {
    const btn = document.createElement('button');
    btn.className = 'part-btn';
    btn.textContent = body.char;
    btn.onclick = () => onSelect('body', i);
    bodyGrid.appendChild(btn);
  });
  container.appendChild(bodyGrid);

  // Colors
  const colorLabel = document.createElement('h4');
  colorLabel.textContent = 'Color';
  colorLabel.style.marginTop = '20px';
  container.appendChild(colorLabel);

  const colorGrid = document.createElement('div');
  colorGrid.className = 'parts-grid';
  AVATAR_CONFIG.colors.forEach((color, i) => {
    const btn = document.createElement('button');
    btn.className = 'part-btn';
    btn.style.background = color;
    btn.textContent = '●';
    btn.onclick = () => onSelect('color', i);
    colorGrid.appendChild(btn);
  });
  container.appendChild(colorGrid);
}
