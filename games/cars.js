// Cars Drift - Top-down arcade racing
export class Cars {
  constructor(canvas, onScore) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.onScore = onScore;

    // Game settings
    this.maxTime = 30000; // 30 seconds
    this.gameTime = 0;
    this.score = 0;

    // Player car
    this.car = {
      x: canvas.width / 2,
      y: canvas.height - 80,
      width: 24,
      height: 40,
      angle: -Math.PI / 2, // pointing up
      vx: 0,
      vy: 0,
      speed: 0,
      maxSpeed: 8,
      acceleration: 0.15,
      friction: 0.92,
      turnSpeed: 0.08
    };

    // Checkpoints (lap circuit)
    this.checkpoints = [
      { x: canvas.width / 2, y: 100, radius: 50, passed: false },
      { x: canvas.width - 100, y: canvas.height / 2, radius: 50, passed: false },
      { x: canvas.width / 2, y: canvas.height - 100, radius: 50, passed: false },
      { x: 100, y: canvas.height / 2, radius: 50, passed: false }
    ];

    this.laps = 0;
    this.lastCheckpoint = -1;

    // Controls
    this.keys = {};
    this.setupControls();
  }

  setupControls() {
    window.addEventListener('keydown', (e) => {
      this.keys[e.key.toLowerCase()] = true;
    });
    window.addEventListener('keyup', (e) => {
      this.keys[e.key.toLowerCase()] = false;
    });
  }

  update(dt) {
    this.gameTime += dt;

    // Acceleration
    if (this.keys['arrowup'] || this.keys['w']) {
      this.car.speed = Math.min(
        this.car.speed + this.car.acceleration,
        this.car.maxSpeed
      );
    } else {
      this.car.speed *= 0.95; // coast
    }

    // Braking
    if (this.keys['arrowdown'] || this.keys['s']) {
      this.car.speed *= 0.85;
    }

    // Steering (faster turn at higher speed)
    const turnAmount = this.car.turnSpeed * (0.5 + this.car.speed / this.car.maxSpeed);

    if (this.keys['arrowleft'] || this.keys['a']) {
      this.car.angle -= turnAmount;
    }
    if (this.keys['arrowright'] || this.keys['d']) {
      this.car.angle += turnAmount;
    }

    // Friction
    this.car.speed *= this.car.friction;

    // Move car
    this.car.vx = Math.cos(this.car.angle) * this.car.speed;
    this.car.vy = Math.sin(this.car.angle) * this.car.speed;

    this.car.x += this.car.vx;
    this.car.y += this.car.vy;

    // Keep in bounds
    this.car.x = Math.max(20, Math.min(this.canvas.width - 20, this.car.x));
    this.car.y = Math.max(20, Math.min(this.canvas.height - 20, this.car.y));

    // Check checkpoint collisions
    this.checkpoints.forEach((checkpoint, idx) => {
      const dist = Math.hypot(
        checkpoint.x - this.car.x,
        checkpoint.y - this.car.y
      );

      if (dist < checkpoint.radius && !checkpoint.passed) {
        checkpoint.passed = true;
        this.lastCheckpoint = idx;

        // Check if lap complete
        const allPassed = this.checkpoints.every(cp => cp.passed);
        if (allPassed) {
          this.laps++;
          this.score += 100; // Lap bonus
          this.onScore(this.score);

          // Reset for next lap
          this.checkpoints.forEach(cp => cp.passed = false);
        }
      }
    });

    // Speed bonus (small, continuous)
    this.score += this.car.speed * 0.5;
    this.onScore(Math.floor(this.score));

    // Time limit
    return this.gameTime < this.maxTime;
  }

  draw() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // Track background
    const gradient = ctx.createLinearGradient(0, 0, w, h);
    gradient.addColorStop(0, '#2d5a2d');
    gradient.addColorStop(1, '#1a3a1a');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, w, h);

    // Road (gray track)
    ctx.fillStyle = '#555555';
    ctx.fillRect(50, 50, w - 100, h - 100);

    // Track edges (white lines)
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 3;
    ctx.strokeRect(50, 50, w - 100, h - 100);

    // Center line (dashed)
    ctx.setLineDash([20, 20]);
    ctx.strokeStyle = '#FFFF99';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(w / 2, 50);
    ctx.lineTo(w / 2, h - 50);
    ctx.stroke();
    ctx.setLineDash([]);

    // Draw checkpoints
    this.checkpoints.forEach((cp, idx) => {
      // Checkpoint circle
      ctx.fillStyle = cp.passed ? '#00CC88' : '#FFD700';
      ctx.beginPath();
      ctx.arc(cp.x, cp.y, cp.radius, 0, Math.PI * 2);
      ctx.fill();

      // Checkpoint border
      ctx.strokeStyle = '#000000';
      ctx.lineWidth = 2;
      ctx.stroke();

      // Number
      ctx.fillStyle = '#000000';
      ctx.font = 'bold 20px Arial';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(idx + 1, cp.x, cp.y);
    });

    // Draw car
    ctx.save();
    ctx.translate(this.car.x, this.car.y);
    ctx.rotate(this.car.angle);

    // Car body
    ctx.fillStyle = '#0099FF';
    ctx.fillRect(-this.car.width / 2, -this.car.height / 2, this.car.width, this.car.height);

    // Car windows
    ctx.fillStyle = '#66CCFF';
    ctx.fillRect(-12, -25, 8, 12);
    ctx.fillRect(4, -25, 8, 12);

    // Car headlights
    ctx.fillStyle = '#FFFF99';
    ctx.beginPath();
    ctx.arc(-8, -20, 2, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(8, -20, 2, 0, Math.PI * 2);
    ctx.fill();

    // Speed lines (if moving fast)
    if (this.car.speed > 5) {
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(-2, -this.car.height / 2 - 5);
      ctx.lineTo(-2, -this.car.height / 2 - 15);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(2, -this.car.height / 2 - 8);
      ctx.lineTo(2, -this.car.height / 2 - 18);
      ctx.stroke();
    }

    ctx.restore();

    // Draw UI
    ctx.fillStyle = '#FFFF00';
    ctx.font = 'bold 24px Arial';
    ctx.textAlign = 'left';
    ctx.fillText(`Score: ${Math.floor(this.score)}`, 20, 40);
    ctx.fillText(`Laps: ${this.laps}`, 20, 70);
    ctx.fillText(`Speed: ${(this.car.speed * 10).toFixed(1)}`, 20, 100);

    const timeLeft = Math.max(0, this.maxTime - this.gameTime);
    ctx.fillText(`Time: ${(timeLeft / 1000).toFixed(1)}s`, w - 250, 40);

    // Next checkpoint hint
    if (this.lastCheckpoint !== -1) {
      const nextIdx = (this.lastCheckpoint + 1) % this.checkpoints.length;
      ctx.fillStyle = '#FFFF99';
      ctx.font = 'bold 16px Arial';
      ctx.fillText(`→ Checkpoint ${nextIdx + 1}`, w / 2 - 100, h - 40);
    }
  }

  getResult() {
    return {
      score: Math.floor(this.score),
      laps: this.laps
    };
  }
}
