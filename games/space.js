// Space Dash - dodge obstacles and collect stars

import { gameState } from '../state.js';

export class SpaceGame {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.width = canvas.width;
    this.height = canvas.height;

    // Player
    this.player = {
      x: this.width / 2,
      y: this.height - 80,
      width: 30,
      height: 30,
      vx: 0,
      speed: 5,
      maxX: this.width - 20
    };

    // Game objects
    this.obstacles = [];
    this.stars = [];
    this.particles = [];

    // Game state
    this.score = 0;
    this.level = 1;
    this.gameTime = 0;
    this.startTime = Date.now();
    this.spawnRate = 1; // obstacles per second
    this.spawnCounter = 0;
    this.starChance = 0.2; // 20% chance of star instead of obstacle

    // Controls
    this.keys = {};
    this.setupInput();

    // Animation
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

  spawnObstacle() {
    const isStar = Math.random() < this.starChance;
    const x = Math.random() * (this.width - 30);

    if (isStar) {
      this.stars.push({
        x,
        y: -20,
        radius: 8,
        speed: 3 + this.level * 0.5,
        collected: false
      });
    } else {
      this.obstacles.push({
        x,
        y: -40,
        width: 30,
        height: 30,
        speed: 2 + this.level * 0.3,
        type: Math.random() > 0.7 ? 'big' : 'normal'
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
    this.gameTime = (Date.now() - this.startTime) / 1000;
    this.level = Math.floor(this.gameTime / 10) + 1;
    this.spawnRate = 1 + this.level * 0.3;

    // Player movement
    if (this.keys['ArrowLeft'] || this.keys['a']) {
      this.player.vx = -this.player.speed;
    } else if (this.keys['ArrowRight'] || this.keys['d']) {
      this.player.vx = this.player.speed;
    } else {
      this.player.vx = 0;
    }

    this.player.x += this.player.vx;
    this.player.x = Math.max(10, Math.min(this.player.x, this.player.maxX));

    // Spawn obstacles/stars
    this.spawnCounter += this.spawnRate / 60; // 60 FPS
    if (this.spawnCounter >= 1) {
      this.spawnObstacle();
      this.spawnCounter = 0;
    }

    // Update obstacles
    this.obstacles = this.obstacles.filter(obs => {
      obs.y += obs.speed;

      // Collision with player
      if (
        this.player.x < obs.x + obs.width &&
        this.player.x + this.player.width > obs.x &&
        this.player.y < obs.y + obs.height &&
        this.player.y + this.player.height > obs.y
      ) {
        // Hit! End game
        this.stop();
        return false;
      }

      return obs.y < this.height + 50;
    });

    // Update stars
    this.stars = this.stars.filter(star => {
      star.y += star.speed;

      // Collision with player
      if (!star.collected) {
        const dx = this.player.x + this.player.width / 2 - star.x;
        const dy = this.player.y + this.player.height / 2 - star.y;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < this.player.width / 2 + star.radius) {
          star.collected = true;
          this.score += 25;

          // Spawn particles
          for (let i = 0; i < 8; i++) {
            const angle = (i / 8) * Math.PI * 2;
            this.particles.push({
              x: star.x,
              y: star.y,
              vx: Math.cos(angle) * 3,
              vy: Math.sin(angle) * 3,
              life: 0.5,
              maxLife: 0.5,
              color: '#ffd84d'
            });
          }
        }
      }

      return star.y < this.height + 50 && !star.collected;
    });

    // Update particles
    this.particles = this.particles.filter(p => {
      p.life -= 1 / 60;
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.1; // gravity
      return p.life > 0;
    });
  }

  draw() {
    // Star field background
    this.ctx.fillStyle = '#000814';
    this.ctx.fillRect(0, 0, this.width, this.height);

    // Draw stars in background
    for (let i = 0; i < 100; i++) {
      const x = (i * 73) % this.width;
      const y = (i * 41 + this.gameTime * 20) % this.height;
      this.ctx.fillStyle = '#fff';
      this.ctx.fillRect(x, y, 1, 1);
    }

    // Draw particles
    this.particles.forEach(p => {
      const opacity = p.life / p.maxLife;
      this.ctx.fillStyle = `rgba(255, 216, 77, ${opacity})`;
      this.ctx.beginPath();
      this.ctx.arc(p.x, p.y, 3, 0, Math.PI * 2);
      this.ctx.fill();
    });

    // Draw stars (collectibles)
    this.stars.forEach(star => {
      const glow = Math.sin(this.gameTime * 4) * 2 + 4;
      this.ctx.fillStyle = 'rgba(255, 215, 0, 0.8)';
      this.ctx.beginPath();
      this.ctx.arc(star.x, star.y, star.radius + glow, 0, Math.PI * 2);
      this.ctx.fill();

      // Inner star
      this.ctx.fillStyle = '#ffff00';
      this.ctx.beginPath();
      this.ctx.arc(star.x, star.y, star.radius, 0, Math.PI * 2);
      this.ctx.fill();
    });

    // Draw obstacles
    this.obstacles.forEach(obs => {
      const color = obs.type === 'big' ? '#ff6b6b' : '#ff8e8e';
      this.ctx.fillStyle = color;
      this.ctx.fillRect(obs.x, obs.y, obs.width, obs.height);

      // Glow effect
      this.ctx.strokeStyle = 'rgba(255, 107, 107, 0.5)';
      this.ctx.lineWidth = 2;
      this.ctx.strokeRect(obs.x - 2, obs.y - 2, obs.width + 4, obs.height + 4);
    });

    // Draw player
    this.ctx.fillStyle = '#00d4ff';
    this.ctx.beginPath();
    this.ctx.moveTo(this.player.x + this.player.width / 2, this.player.y); // Top point
    this.ctx.lineTo(this.player.x + this.player.width, this.player.y + this.player.height); // Right
    this.ctx.lineTo(this.player.x, this.player.y + this.player.height); // Left
    this.ctx.closePath();
    this.ctx.fill();

    // Player shield glow
    this.ctx.strokeStyle = 'rgba(0, 212, 255, 0.5)';
    this.ctx.lineWidth = 2;
    this.ctx.beginPath();
    this.ctx.arc(
      this.player.x + this.player.width / 2,
      this.player.y + this.player.height / 2,
      this.player.width / 2 + 5,
      0,
      Math.PI * 2
    );
    this.ctx.stroke();

    // HUD
    this.ctx.fillStyle = 'white';
    this.ctx.font = 'bold 18px system-ui';
    this.ctx.fillText(`Score: ${Math.floor(this.score)}`, 10, 25);
    this.ctx.fillText(`Level: ${this.level}`, 10, 50);
    this.ctx.fillText(`Time: ${Math.floor(this.gameTime)}s`, 10, 75);

    // Difficulty indicator
    this.ctx.fillStyle = 'rgba(255, 215, 0, 0.5)';
    const diffWidth = (this.gameTime % 10) / 10 * 100;
    this.ctx.fillRect(10, this.height - 25, diffWidth, 15);
    this.ctx.strokeStyle = '#ffd84d';
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
