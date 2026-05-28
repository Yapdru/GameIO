// Fishana Evolution - Authentic evolution-based fishing game
// Eat food to grow, evolve into stronger forms, avoid predators
// Mechanic: Growth → Evolution → New Abilities → Survival

import { gameState } from '../state.js';

export class FishanaGame {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.width = canvas.width;
    this.height = canvas.height;

    // Player fish with evolution system
    this.fish = {
      x: this.width / 2,
      y: this.height / 2,
      width: 20,
      height: 15,
      vx: 0,
      vy: 0,
      angle: 0,
      speed: 2.5,
      maxSpeed: 4,
      size: 1,           // Evolution multiplier
      level: 0,          // Evolution level (0, 1, 2, 3)
      foodEaten: 0,      // Counter to next level
      foodNeeded: 15     // Food to reach next level
    };

    // Food particles (pearls, smaller food)
    this.food = [];
    this.spawnFood(8);

    // Predator fish (get harder as player evolves)
    this.predators = [];
    this.spawnPredators(1);

    // Powerups
    this.powerups = [];
    this.spawnPowerups(1);

    // Game state
    this.score = 0;
    this.gameTime = 0;
    this.startTime = Date.now();
    this.gameDuration = 120; // 2 minutes

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

  spawnFood(count) {
    for (let i = 0; i < count; i++) {
      this.food.push({
        x: Math.random() * (this.width - 40) + 20,
        y: Math.random() * (this.height - 40) + 20,
        radius: 3 + Math.random() * 2,
        value: 10 + Math.random() * 5,
        type: Math.random() > 0.7 ? 'pearl' : 'food'
      });
    }
  }

  spawnPredators(count) {
    for (let i = 0; i < count; i++) {
      const size = 1 + Math.floor(this.fish.level / 2);
      this.predators.push({
        x: Math.random() * this.width,
        y: Math.random() * this.height,
        width: 25 * size,
        height: 18 * size,
        vx: (Math.random() - 0.5) * 2,
        vy: (Math.random() - 0.5) * 2,
        speed: 1.5 + size * 0.3,
        size: size,
        chasing: false,
        huntTimer: 0
      });
    }
  }

  spawnPowerups(count) {
    for (let i = 0; i < count; i++) {
      this.powerups.push({
        x: Math.random() * (this.width - 40) + 20,
        y: Math.random() * (this.height - 40) + 20,
        radius: 6,
        type: Math.random() > 0.5 ? 'speed' : 'shield',
        duration: 5000 // 5 seconds
      });
    }
  }

  checkEvolution() {
    // Every 15 food eaten, evolve
    if (this.fish.foodEaten >= this.fish.foodNeeded) {
      this.fish.level++;
      this.fish.foodEaten = 0;
      this.fish.size = 1 + this.fish.level * 0.3;
      this.fish.maxSpeed = 4 + this.fish.level * 0.5;

      // Spawn harder predators as you evolve
      if (this.fish.level % 2 === 0 && this.predators.length < 3) {
        this.spawnPredators(1);
      }

      // Score bonus for evolution
      this.score += 500 * this.fish.level;
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

    // Check game end
    if (this.gameTime > this.gameDuration) {
      this.isRunning = false;
      return;
    }

    // Player movement
    let moveX = 0, moveY = 0;

    if (this.keys['ArrowUp'] || this.keys['w']) moveY = -1;
    if (this.keys['ArrowDown'] || this.keys['s']) moveY = 1;
    if (this.keys['ArrowLeft'] || this.keys['a']) moveX = -1;
    if (this.keys['ArrowRight'] || this.keys['d']) moveX = 1;

    if (moveX !== 0 || moveY !== 0) {
      const len = Math.sqrt(moveX * moveX + moveY * moveY);
      this.fish.vx = (moveX / len) * this.fish.maxSpeed;
      this.fish.vy = (moveY / len) * this.fish.maxSpeed;
      this.fish.angle = Math.atan2(this.fish.vy, this.fish.vx);
    } else {
      this.fish.vx *= 0.95;
      this.fish.vy *= 0.95;
    }

    this.fish.x += this.fish.vx;
    this.fish.y += this.fish.vy;

    // Boundary wrapping
    if (this.fish.x < 0) this.fish.x = this.width;
    if (this.fish.x > this.width) this.fish.x = 0;
    if (this.fish.y < 0) this.fish.y = this.height;
    if (this.fish.y > this.height) this.fish.y = 0;

    // Food collection
    this.food = this.food.filter(f => {
      const dx = this.fish.x - f.x;
      const dy = this.fish.y - f.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < this.fish.width / 2 + f.radius) {
        this.fish.foodEaten++;
        this.score += Math.floor(f.value * (1 + this.fish.level * 0.2));
        if (f.type === 'pearl') this.score += 50;
        return false;
      }
      return true;
    });

    // Respawn food
    if (this.food.length < 5) {
      this.spawnFood(1);
    }

    // Check evolution
    this.checkEvolution();

    // Predator AI
    this.predators.forEach(pred => {
      const dx = this.fish.x - pred.x;
      const dy = this.fish.y - pred.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      // Hunt if close and player is smaller
      if (dist < 150 && this.fish.level < pred.size) {
        pred.chasing = true;
        pred.huntTimer = 30;
      }

      if (pred.huntTimer > 0) {
        const angle = Math.atan2(dy, dx);
        pred.vx = Math.cos(angle) * pred.speed;
        pred.vy = Math.sin(angle) * pred.speed;
        pred.huntTimer--;
      } else {
        pred.chasing = false;
        // Random wandering
        if (Math.random() < 0.01) {
          pred.vx = (Math.random() - 0.5) * 2;
          pred.vy = (Math.random() - 0.5) * 2;
        }
      }

      pred.x += pred.vx;
      pred.y += pred.vy;

      // Boundary wrapping
      if (pred.x < 0) pred.x = this.width;
      if (pred.x > this.width) pred.x = 0;
      if (pred.y < 0) pred.y = this.height;
      if (pred.y > this.height) pred.y = 0;

      // Collision - game over if eaten
      if (dist < this.fish.width + pred.width) {
        this.isRunning = false;
      }
    });

    // Powerup collection
    this.powerups = this.powerups.filter(p => {
      const dx = this.fish.x - p.x;
      const dy = this.fish.y - p.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < this.fish.width + p.radius) {
        if (p.type === 'speed') {
          this.fish.maxSpeed *= 1.5;
          setTimeout(() => {
            this.fish.maxSpeed /= 1.5;
          }, p.duration);
        } else if (p.type === 'shield') {
          // Temporarily invisible to predators
          this.fish.shield = true;
          setTimeout(() => {
            this.fish.shield = false;
          }, p.duration);
        }
        this.score += 100;
        return false;
      }
      return true;
    });

    // Respawn powerups
    if (this.powerups.length < 1 && Math.random() < 0.005) {
      this.spawnPowerups(1);
    }
  }

  draw() {
    // Ocean background
    const gradient = this.ctx.createLinearGradient(0, 0, 0, this.height);
    gradient.addColorStop(0, '#1a7a8a');
    gradient.addColorStop(1, '#0a4a5a');
    this.ctx.fillStyle = gradient;
    this.ctx.fillRect(0, 0, this.width, this.height);

    // Bubbles
    for (let i = 0; i < 20; i++) {
      const x = (i * 47 + this.gameTime * 10) % this.width;
      const y = (i * 63 + this.gameTime * 20) % this.height;
      this.ctx.fillStyle = 'rgba(100, 200, 255, 0.3)';
      this.ctx.beginPath();
      this.ctx.arc(x, y, 3, 0, Math.PI * 2);
      this.ctx.fill();
    }

    // Draw food
    this.food.forEach(f => {
      if (f.type === 'pearl') {
        this.ctx.fillStyle = '#ffffff';
        const glow = Math.sin(this.gameTime * 3) * 2;
        this.ctx.beginPath();
        this.ctx.arc(f.x, f.y, f.radius + glow, 0, Math.PI * 2);
        this.ctx.fill();
      } else {
        this.ctx.fillStyle = '#ffdd00';
        this.ctx.beginPath();
        this.ctx.arc(f.x, f.y, f.radius, 0, Math.PI * 2);
        this.ctx.fill();
      }
    });

    // Draw powerups
    this.powerups.forEach(p => {
      if (p.type === 'speed') {
        this.ctx.fillStyle = '#ff6b9d';
      } else {
        this.ctx.fillStyle = '#4287f5';
      }
      this.ctx.beginPath();
      this.ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      this.ctx.fill();
    });

    // Draw predators
    this.predators.forEach(pred => {
      this.ctx.fillStyle = pred.chasing ? '#ff3333' : '#cc3333';
      this.ctx.save();
      this.ctx.translate(pred.x, pred.y);
      this.ctx.rotate(Math.atan2(pred.vy, pred.vx));
      this.ctx.fillRect(-pred.width / 2, -pred.height / 2, pred.width, pred.height);
      this.ctx.restore();
    });

    // Draw player fish
    const alpha = this.fish.shield ? 0.5 : 1;
    this.ctx.globalAlpha = alpha;
    this.ctx.fillStyle = `hsl(${150 + this.fish.level * 20}, 80%, 50%)`;
    this.ctx.save();
    this.ctx.translate(this.fish.x, this.fish.y);
    this.ctx.rotate(this.fish.angle);

    // Fish body (grows with evolution)
    const w = this.fish.width * this.fish.size;
    const h = this.fish.height * this.fish.size;
    this.ctx.beginPath();
    this.ctx.ellipse(0, 0, w, h, 0, 0, Math.PI * 2);
    this.ctx.fill();

    // Fish tail
    this.ctx.fillStyle = `hsl(${150 + this.fish.level * 20}, 90%, 40%)`;
    this.ctx.beginPath();
    this.ctx.moveTo(w / 2, h / 2);
    this.ctx.lineTo(w, 0);
    this.ctx.lineTo(w / 2, -h / 2);
    this.ctx.closePath();
    this.ctx.fill();

    this.ctx.restore();
    this.ctx.globalAlpha = 1;

    // HUD
    this.ctx.fillStyle = 'white';
    this.ctx.font = 'bold 18px system-ui';
    this.ctx.fillText(`Score: ${Math.floor(this.score)}`, 10, 25);
    this.ctx.fillText(`Level: ${this.fish.level}`, 10, 50);
    this.ctx.fillText(`Food: ${this.fish.foodEaten}/${this.fish.foodNeeded}`, 10, 75);
    this.ctx.fillText(`Time: ${Math.floor(this.gameTime)}s`, 10, 100);

    // Evolution bar
    const barWidth = 200;
    const barHeight = 10;
    this.ctx.strokeStyle = 'white';
    this.ctx.strokeRect(10, 110, barWidth, barHeight);
    this.ctx.fillStyle = '#00ff00';
    const fillWidth = (this.fish.foodEaten / this.fish.foodNeeded) * barWidth;
    this.ctx.fillRect(10, 110, fillWidth, barHeight);

    // Game timer
    const timeLeft = this.gameDuration - this.gameTime;
    this.ctx.fillStyle = timeLeft < 10 ? '#ff6b6b' : 'white';
    this.ctx.textAlign = 'right';
    this.ctx.fillText(`${Math.ceil(timeLeft)}s left`, this.width - 10, 25);
    this.ctx.textAlign = 'left';
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
