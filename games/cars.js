// Cars Horizon - drift racing game

import { gameState } from '../state.js';

export class CarsGame {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.width = canvas.width;
    this.height = canvas.height;

    // Player car
    this.car = {
      x: this.width / 2,
      y: this.height - 100,
      vx: 0,
      vy: 0,
      angle: 0,
      width: 30,
      height: 20,
      maxSpeed: 8,
      acceleration: 0.2,
      friction: 0.92,
      driftFriction: 0.85,
      grip: 0.85
    };

    // Track checkpoints (simple oval)
    this.checkpoints = this.generateTrack();
    this.currentCheckpoint = 0;
    this.laps = 0;
    this.lapTimes = [];
    this.lapStartTime = Date.now();

    // Scoring
    this.score = 0;
    this.driftScore = 0;
    this.driftActive = false;
    this.driftTime = 0;

    // Game state
    this.gameTime = 0;
    this.startTime = Date.now();
    this.isRunning = false;

    // Controls
    this.keys = {};
    this.setupInput();

    this.animationId = null;
  }

  generateTrack() {
    // Simple oval track
    const points = [];
    const centerX = this.width / 2;
    const centerY = this.height / 2;
    const radiusX = 200;
    const radiusY = 150;

    for (let i = 0; i < 20; i++) {
      const angle = (i / 20) * Math.PI * 2;
      const x = centerX + Math.cos(angle) * radiusX;
      const y = centerY + Math.sin(angle) * radiusY;
      points.push({ x, y, angle });
    }

    return points;
  }

  setupInput() {
    document.addEventListener('keydown', (e) => {
      this.keys[e.key] = true;
    });

    document.addEventListener('keyup', (e) => {
      this.keys[e.key] = false;
    });
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

    // Input
    const throttle = this.keys['ArrowUp'] || this.keys['w'];
    const brake = this.keys['ArrowDown'] || this.keys['s'];
    const left = this.keys['ArrowLeft'] || this.keys['a'];
    const right = this.keys['ArrowRight'] || this.keys['d'];
    const boost = this.keys[' '];

    // Car physics
    if (throttle) {
      this.car.vy = Math.max(this.car.vy - this.car.acceleration, -this.car.maxSpeed);
    }
    if (brake) {
      this.car.vy = Math.min(this.car.vy + this.car.acceleration * 1.5, 0);
    }

    // Steering
    const speed = Math.abs(this.car.vy);
    const steerAmount = Math.min(speed * 0.1, 0.3);

    if (left && speed > 0.5) {
      this.car.angle += steerAmount;
    }
    if (right && speed > 0.5) {
      this.car.angle -= steerAmount;
    }

    // Drift detection
    const driftThreshold = 0.4;
    const sidewaysVelocity = Math.sin(this.car.angle) * this.car.vx - Math.cos(this.car.angle) * this.car.vy;
    const isDrifting = Math.abs(sidewaysVelocity) > driftThreshold && speed > 2;

    if (isDrifting) {
      this.driftActive = true;
      this.driftTime += 1;
      this.car.friction = this.car.driftFriction;
      // Add drift score
      this.driftScore += 1;
      this.score += 0.5;
    } else {
      if (this.driftActive && this.driftTime > 20) {
        // Reward long drifts
        this.score += this.driftTime / 10;
      }
      this.driftActive = false;
      this.driftTime = 0;
      this.car.friction = this.car.friction * 0.98 + this.car.friction * 0.02; // Return to normal
    }

    // Boost
    if (boost && !throttle) {
      this.car.vy *= 1.05;
    }

    // Apply velocity changes for steering
    const velMagnitude = Math.sqrt(this.car.vx ** 2 + this.car.vy ** 2);
    if (velMagnitude > 0.1) {
      const dirX = Math.sin(this.car.angle);
      const dirY = -Math.cos(this.car.angle);
      const targetVx = dirX * Math.min(speed, this.car.maxSpeed);
      const targetVy = dirY * Math.min(speed, this.car.maxSpeed);
      this.car.vx += (targetVx - this.car.vx) * 0.1;
      this.car.vy += (targetVy - this.car.vy) * 0.1;
    }

    // Friction
    this.car.vy *= this.car.friction;

    // Position update
    this.car.x += this.car.vx;
    this.car.y += this.car.vy;

    // Boundary wrapping
    if (this.car.x < 0) this.car.x = this.width;
    if (this.car.x > this.width) this.car.x = 0;
    if (this.car.y < 0) this.car.y = this.height;
    if (this.car.y > this.height) this.car.y = 0;

    // Checkpoint detection
    const checkpoint = this.checkpoints[this.currentCheckpoint];
    const dx = this.car.x - checkpoint.x;
    const dy = this.car.y - checkpoint.y;
    const dist = Math.sqrt(dx * dx + dy * dy);

    if (dist < 30) {
      this.currentCheckpoint = (this.currentCheckpoint + 1) % this.checkpoints.length;

      // Lap completed
      if (this.currentCheckpoint === 0) {
        this.laps += 1;
        const lapTime = Date.now() - this.lapStartTime;
        this.lapTimes.push(lapTime);
        this.lapStartTime = Date.now();
        this.score += 50; // Lap bonus
      }
    }
  }

  draw() {
    // Clear with gradient
    const gradient = this.ctx.createLinearGradient(0, 0, this.width, this.height);
    gradient.addColorStop(0, '#87ceeb');
    gradient.addColorStop(1, '#e0f6ff');
    this.ctx.fillStyle = gradient;
    this.ctx.fillRect(0, 0, this.width, this.height);

    // Draw track
    this.ctx.strokeStyle = '#444';
    this.ctx.lineWidth = 80;
    this.ctx.beginPath();
    this.checkpoints.forEach((cp, i) => {
      if (i === 0) this.ctx.moveTo(cp.x, cp.y);
      else this.ctx.lineTo(cp.x, cp.y);
    });
    this.ctx.closePath();
    this.ctx.stroke();

    // Draw track center line
    this.ctx.strokeStyle = 'rgba(255, 255, 255, 0.5)';
    this.ctx.lineWidth = 2;
    this.ctx.setLineDash([10, 10]);
    this.ctx.stroke();
    this.ctx.setLineDash([]);

    // Draw checkpoints
    this.ctx.fillStyle = 'rgba(0, 255, 0, 0.3)';
    this.checkpoints.forEach((cp, i) => {
      this.ctx.beginPath();
      this.ctx.arc(cp.x, cp.y, i === this.currentCheckpoint ? 25 : 20, 0, Math.PI * 2);
      this.ctx.fill();
    });

    // Draw car
    this.ctx.save();
    this.ctx.translate(this.car.x, this.car.y);
    this.ctx.rotate(this.car.angle);

    // Car body
    this.ctx.fillStyle = '#ff6b6b';
    this.ctx.fillRect(-this.car.width / 2, -this.car.height / 2, this.car.width, this.car.height);

    // Car windows
    this.ctx.fillStyle = '#87ceeb';
    this.ctx.fillRect(-10, -6, 8, 5);
    this.ctx.fillRect(-10, 1, 8, 5);

    // Car headlights
    this.ctx.fillStyle = '#ffff00';
    this.ctx.fillRect(12, -5, 4, 3);
    this.ctx.fillRect(12, 2, 4, 3);

    // Drift smoke
    if (this.driftActive) {
      this.ctx.fillStyle = 'rgba(200, 200, 200, 0.3)';
      this.ctx.fillRect(-this.car.width / 2, this.car.height / 2, this.car.width, 8);
    }

    this.ctx.restore();

    // Draw HUD
    this.ctx.fillStyle = 'white';
    this.ctx.font = 'bold 16px system-ui';
    this.ctx.fillText(`Score: ${Math.floor(this.score)}`, 10, 25);
    this.ctx.fillText(`Lap: ${this.laps}`, 10, 45);
    this.ctx.fillText(`Speed: ${Math.abs(this.car.vy).toFixed(1)}`, 10, 65);
    this.ctx.fillText(`Drift: ${this.driftScore}`, 10, 85);

    // Drift indicator bar
    if (this.driftActive) {
      this.ctx.fillStyle = 'rgba(255, 165, 0, 0.7)';
      const driftBarWidth = Math.min(this.driftTime / 10, 100);
      this.ctx.fillRect(10, this.height - 25, driftBarWidth, 15);
      this.ctx.strokeStyle = 'orange';
      this.ctx.strokeRect(10, this.height - 25, 100, 15);
    }
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
