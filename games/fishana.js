// Fishana Evolution - first playable game
// Simple 2D Canvas game with swimming, pearls, and evolution

import { gameState } from '../state.js';

export class FishanaGame {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.width = canvas.width;
    this.height = canvas.height;

    // Player (fish)
    this.fish = {
      x: this.width / 2,
      y: this.height / 2,
      width: 30,
      height: 20,
      vx: 0,
      vy: 0,
      angle: 0,
      speed: 3,
      maxSpeed: 5
    };

    // Pearls to collect
    this.pearls = [];
    this.spawnPearls(5);

    // Game state
    this.score = 0;
    this.time = 0;
    this.evolutionLevel = 0;
    this.gameTime = 0;
    this.startTime = Date.now();

    // Controls
    this.keys = {};
    this.setupInput();

    // Animation loop
    this.animationId = null;
    this.isRunning = false;
  }

  setupInput() {
    document.addEventListener('keydown', (e) => {
      this.keys[e.key] = true;
    });

    document.addEventListener('keyup', (e) => {
      this.keys[e.key] = false;
    });
  }

  spawnPearls(count) {
    for (let i = 0; i < count; i++) {
      this.pearls.push({
        x: Math.random() * (this.width - 40) + 20,
        y: Math.random() * (this.height - 40) + 20,
        radius: 5,
        collected: false
      });
    }
  }

  start() {
    this.isRunning = true;
    this.startTime = Date.now();
    this.loop();
  }

  stop() {
    this.isRunning = false;
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
    }
  }

  update() {
    // Time tracking
    this.gameTime = (Date.now() - this.startTime) / 1000;

    // Input handling
    const input = { left: false, right: false, up: false, down: false };
    if (this.keys['ArrowLeft'] || this.keys['a']) input.left = true;
    if (this.keys['ArrowRight'] || this.keys['d']) input.right = true;
    if (this.keys['ArrowUp'] || this.keys['w']) input.up = true;
    if (this.keys['ArrowDown'] || this.keys['s']) input.down = true;

    // Fish movement
    if (input.up) this.fish.vy = Math.max(this.fish.vy - 0.3, -this.fish.maxSpeed);
    if (input.down) this.fish.vy = Math.min(this.fish.vy + 0.3, this.fish.maxSpeed);
    if (input.left) this.fish.vx = Math.max(this.fish.vx - 0.3, -this.fish.maxSpeed);
    if (input.right) this.fish.vx = Math.min(this.fish.vx + 0.3, this.fish.maxSpeed);

    // Friction
    this.fish.vx *= 0.95;
    this.fish.vy *= 0.95;

    // Position update
    this.fish.x += this.fish.vx;
    this.fish.y += this.fish.vy;

    // Angle toward movement
    if (this.fish.vx !== 0 || this.fish.vy !== 0) {
      this.fish.angle = Math.atan2(this.fish.vy, this.fish.vx);
    }

    // Boundary wrapping
    if (this.fish.x < 0) this.fish.x = this.width;
    if (this.fish.x > this.width) this.fish.x = 0;
    if (this.fish.y < 0) this.fish.y = this.height;
    if (this.fish.y > this.height) this.fish.y = 0;

    // Pearl collection
    this.pearls.forEach(pearl => {
      if (!pearl.collected) {
        const dx = this.fish.x - pearl.x;
        const dy = this.fish.y - pearl.y;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < this.fish.width) {
          pearl.collected = true;
          this.score += 10;
          this.evolutionLevel = Math.floor(this.score / 50);
        }
      }
    });

    // Respawn collected pearls
    if (this.pearls.filter(p => !p.collected).length === 0) {
      this.pearls.forEach(p => p.collected = false);
    }
  }

  draw() {
    // Clear canvas with ocean gradient
    const gradient = this.ctx.createLinearGradient(0, 0, 0, this.height);
    gradient.addColorStop(0, '#1e90ff');
    gradient.addColorStop(1, '#000080');
    this.ctx.fillStyle = gradient;
    this.ctx.fillRect(0, 0, this.width, this.height);

    // Draw bubbles (animation)
    const bubbleCount = Math.floor(this.gameTime * 2) % 10;
    for (let i = 0; i < bubbleCount; i++) {
      const x = (i * 50 + this.gameTime * 20) % this.width;
      const y = Math.sin(this.gameTime + i) * 30 + this.height / 2;
      this.ctx.fillStyle = 'rgba(255, 255, 255, 0.1)';
      this.ctx.beginPath();
      this.ctx.arc(x, y, 3, 0, Math.PI * 2);
      this.ctx.fill();
    }

    // Draw pearls
    this.pearls.forEach(pearl => {
      if (!pearl.collected) {
        const glow = Math.sin(this.gameTime * 3) * 2 + 5;
        this.ctx.fillStyle = 'rgba(255, 215, 0, 0.8)';
        this.ctx.beginPath();
        this.ctx.arc(pearl.x, pearl.y, pearl.radius + glow, 0, Math.PI * 2);
        this.ctx.fill();

        this.ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
        this.ctx.beginPath();
        this.ctx.arc(pearl.x, pearl.y, pearl.radius, 0, Math.PI * 2);
        this.ctx.fill();
      }
    });

    // Draw fish
    this.ctx.save();
    this.ctx.translate(this.fish.x, this.fish.y);
    this.ctx.rotate(this.fish.angle);

    // Fish body
    this.ctx.fillStyle = '#FF6B6B';
    this.ctx.beginPath();
    this.ctx.ellipse(0, 0, this.fish.width, this.fish.height, 0, 0, Math.PI * 2);
    this.ctx.fill();

    // Fish eye
    this.ctx.fillStyle = 'white';
    this.ctx.beginPath();
    this.ctx.arc(10, -5, 3, 0, Math.PI * 2);
    this.ctx.fill();

    // Fish tail
    this.ctx.fillStyle = '#FF8E8E';
    this.ctx.beginPath();
    this.ctx.moveTo(-this.fish.width, 0);
    this.ctx.lineTo(-this.fish.width - 15, -8);
    this.ctx.lineTo(-this.fish.width - 15, 8);
    this.ctx.closePath();
    this.ctx.fill();

    this.ctx.restore();

    // Draw HUD
    this.ctx.fillStyle = 'white';
    this.ctx.font = '16px system-ui';
    this.ctx.fillText(`Score: ${this.score}`, 10, 25);
    this.ctx.fillText(`Level: ${this.evolutionLevel}`, 10, 45);
    this.ctx.fillText(`Time: ${Math.floor(this.gameTime)}s`, 10, 65);
    this.ctx.fillText(`Pearls: ${this.pearls.filter(p => !p.collected).length}`, 10, 85);

    // Draw evolution indicator
    this.ctx.fillStyle = 'rgba(255, 215, 0, 0.5)';
    const evolutionWidth = (this.score % 50) / 50 * 100;
    this.ctx.fillRect(10, this.height - 25, evolutionWidth, 15);
    this.ctx.strokeStyle = 'white';
    this.ctx.strokeRect(10, this.height - 25, 100, 15);
  }

  loop = () => {
    if (!this.isRunning) return;

    this.update();
    this.draw();

    this.animationId = requestAnimationFrame(this.loop);
  };

  getScore() {
    return this.score;
  }
}
