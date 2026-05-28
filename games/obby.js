// Obby Run - parkour obstacle course, jump/dodge, checkpoints

import { gameState } from '../state.js';

export class ObbyGame {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.width = canvas.width;
    this.height = canvas.height;

    // Player
    this.player = {
      x: 50,
      y: this.height - 100,
      width: 20,
      height: 30,
      vx: 0,
      vy: 0,
      speed: 3,
      jumpPower: 12,
      maxFallSpeed: 10,
      onGround: false,
      jumpsLeft: 1
    };

    this.platforms = this.generatePlatforms();
    this.obstacles = [];
    this.spawnObstacles();

    this.checkpoints = [];
    this.currentCheckpoint = 0;
    this.generateCheckpoints();

    this.score = 0;
    this.gameTime = 0;
    this.startTime = Date.now();
    this.checkpointTime = Date.now();
    this.isRunning = false;
    this.finished = false;

    this.keys = {};
    this.setupInput();

    this.animationId = null;
  }

  setupInput() {
    document.addEventListener('keydown', (e) => {
      this.keys[e.key] = true;
      if ((e.key === ' ' || e.key === 'w' || e.key === 'ArrowUp') && this.player.jumpsLeft > 0) {
        this.player.vy = -this.player.jumpPower;
        this.player.jumpsLeft--;
        this.player.onGround = false;
      }
    });

    document.addEventListener('keyup', (e) => {
      this.keys[e.key] = false;
    });
  }

  generatePlatforms() {
    const platforms = [];

    platforms.push({
      x: 0,
      y: this.height - 100,
      width: 150,
      height: 20,
      color: '#90ee90'
    });

    let y = this.height - 150;
    let x = 100;

    for (let i = 0; i < 15; i++) {
      const width = 80 - i * 3;
      const gap = 40 + i * 3;

      platforms.push({
        x,
        y,
        width: Math.max(40, width),
        height: 15,
        color: i % 2 === 0 ? '#87ceeb' : '#4287f5'
      });

      x += width + gap;
      y -= 60 + i * 2;
    }

    platforms.push({
      x,
      y: 50,
      width: 200,
      height: 20,
      color: '#ffd84d'
    });

    return platforms;
  }

  generateCheckpoints() {
    this.checkpoints = [
      { x: 100, y: this.height - 150, id: 0 },
      { x: 300, y: this.height - 300, id: 1 },
      { x: 600, y: this.height - 450, id: 2 },
      { x: 1000, y: this.height - 600, id: 3 }
    ];
  }

  spawnObstacles() {
    this.obstacles = [
      {
        x: 200,
        y: this.height - 200,
        width: 30,
        height: 30,
        vx: 2,
        minX: 150,
        maxX: 350,
        type: 'spike'
      },
      {
        x: 500,
        y: this.height - 350,
        width: 40,
        height: 20,
        vx: -1.5,
        minX: 450,
        maxX: 650,
        type: 'block'
      }
    ];
  }

  start() {
    this.isRunning = true;
    this.startTime = Date.now();
    this.checkpointTime = Date.now();
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

    if (this.keys['ArrowLeft'] || this.keys['a']) {
      this.player.vx = -this.player.speed;
    } else if (this.keys['ArrowRight'] || this.keys['d']) {
      this.player.vx = this.player.speed;
    } else {
      this.player.vx = 0;
    }

    this.player.vy += 0.4;
    this.player.vy = Math.min(this.player.vy, this.player.maxFallSpeed);

    this.player.x += this.player.vx;
    this.player.y += this.player.vy;

    this.player.onGround = false;
    this.platforms.forEach(platform => {
      if (
        this.player.vy > 0 &&
        this.player.y + this.player.height >= platform.y &&
        this.player.y + this.player.height <= platform.y + 15 &&
        this.player.x + this.player.width > platform.x &&
        this.player.x < platform.x + platform.width
      ) {
        this.player.y = platform.y - this.player.height;
        this.player.vy = 0;
        this.player.onGround = true;
        this.player.jumpsLeft = 1;
      }
    });

    this.obstacles.forEach(obs => {
      obs.x += obs.vx;
      if (obs.x < obs.minX) obs.vx = -obs.vx;
      if (obs.x > obs.maxX) obs.vx = -obs.vx;

      if (
        this.player.x < obs.x + obs.width &&
        this.player.x + this.player.width > obs.x &&
        this.player.y < obs.y + obs.height &&
        this.player.y + this.player.height > obs.y
      ) {
        if (this.currentCheckpoint > 0) {
          const checkpoint = this.checkpoints[this.currentCheckpoint - 1];
          this.player.x = checkpoint.x;
          this.player.y = checkpoint.y - this.player.height;
          this.player.vy = 0;
          this.score -= 5;
        }
      }
    });

    const checkpointRadius = 40;
    this.checkpoints.forEach((cp, i) => {
      if (i > this.currentCheckpoint) {
        const dx = this.player.x + this.player.width / 2 - cp.x;
        const dy = this.player.y + this.player.height / 2 - cp.y;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < checkpointRadius) {
          this.currentCheckpoint = i;
          const lapTime = (Date.now() - this.checkpointTime) / 1000;
          this.score += Math.max(50 - lapTime * 10, 10);
          this.checkpointTime = Date.now();
        }
      }
    });

    if (this.currentCheckpoint === this.checkpoints.length - 1) {
      const finalCheckpoint = this.checkpoints[this.currentCheckpoint];
      const dx = this.player.x + this.player.width / 2 - finalCheckpoint.x;
      const dy = this.player.y + this.player.height / 2 - finalCheckpoint.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < 60 && !this.finished) {
        this.finished = true;
        this.score += 100;
        this.stop();
      }
    }

    if (this.player.y > this.height + 100) {
      this.stop();
    }

    this.player.x = Math.max(0, Math.min(this.player.x, this.width - this.player.width));
  }

  draw() {
    const gradient = this.ctx.createLinearGradient(0, 0, 0, this.height);
    gradient.addColorStop(0, '#87ceeb');
    gradient.addColorStop(1, '#e0f6ff');
    this.ctx.fillStyle = gradient;
    this.ctx.fillRect(0, 0, this.width, this.height);

    this.platforms.forEach((platform, i) => {
      this.ctx.fillStyle = platform.color;
      this.ctx.fillRect(platform.x, platform.y, platform.width, platform.height);

      this.ctx.strokeStyle = 'rgba(0,0,0,0.2)';
      this.ctx.lineWidth = 2;
      this.ctx.strokeRect(platform.x, platform.y, platform.width, platform.height);
    });

    this.checkpoints.forEach((cp, i) => {
      const opacity = i <= this.currentCheckpoint ? 1 : 0.3;
      this.ctx.fillStyle = `rgba(255, 215, 0, ${opacity})`;
      this.ctx.beginPath();
      this.ctx.arc(cp.x, cp.y, 20, 0, Math.PI * 2);
      this.ctx.fill();

      if (i <= this.currentCheckpoint) {
        this.ctx.strokeStyle = '#ffd84d';
        this.ctx.lineWidth = 2;
        this.ctx.stroke();
      }
    });

    this.obstacles.forEach(obs => {
      this.ctx.fillStyle = obs.type === 'spike' ? '#ff6b6b' : '#ff8e8e';
      this.ctx.fillRect(obs.x, obs.y, obs.width, obs.height);

      if (obs.type === 'spike') {
        this.ctx.fillStyle = '#ff0000';
        for (let i = 0; i < 3; i++) {
          this.ctx.beginPath();
          this.ctx.moveTo(obs.x + i * 10 + 5, obs.y);
          this.ctx.lineTo(obs.x + i * 10 + 10, obs.y + 15);
          this.ctx.lineTo(obs.x + i * 10, obs.y + 15);
          this.ctx.closePath();
          this.ctx.fill();
        }
      }
    });

    this.ctx.fillStyle = '#0f8fe8';
    this.ctx.fillRect(this.player.x, this.player.y, this.player.width, this.player.height);

    this.ctx.fillStyle = 'white';
    this.ctx.fillRect(this.player.x + 3, this.player.y + 8, 4, 4);
    this.ctx.fillRect(this.player.x + 13, this.player.y + 8, 4, 4);

    this.ctx.fillStyle = 'white';
    this.ctx.font = 'bold 18px system-ui';
    this.ctx.fillText(`Score: ${Math.floor(this.score)}`, 10, 25);
    this.ctx.fillText(`Checkpoint: ${this.currentCheckpoint}/${this.checkpoints.length - 1}`, 10, 50);
    this.ctx.fillText(`Time: ${Math.floor(this.gameTime)}s`, 10, 75);

    if (this.finished) {
      this.ctx.fillStyle = 'rgba(0,0,0,0.7)';
      this.ctx.fillRect(0, 0, this.width, this.height);
      this.ctx.fillStyle = '#ffd84d';
      this.ctx.font = 'bold 48px system-ui';
      this.ctx.textAlign = 'center';
      this.ctx.fillText('FINISHED!', this.width / 2, this.height / 2);
    }
  }

  loop = () => {
    if (!this.isRunning && !this.finished) return;

    this.update();
    this.draw();

    if (this.isRunning || this.finished) {
      this.animationId = requestAnimationFrame(this.loop);
    }
  };

  getScore() {
    return this.score;
  }
}
