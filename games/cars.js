// Cars Drift - Arcade top-down driving
export class Cars {
  constructor(canvas, onScore) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.onScore = onScore;

    // Game state
    this.car = {
      x: canvas.width / 2,
      y: canvas.height - 80,
      width: 30,
      height: 50,
      angle: 0,
      speed: 0,
      maxSpeed: 8
    };

    this.score = 0;
    this.lapCount = 0;
    this.gameTime = 0;
    this.maxTime = 30000;
    this.checkpoints = [
      { x: canvas.width / 2, y: 100, passed: false },
      { x: canvas.width - 100, y: canvas.height / 2, passed: false },
      { x: canvas.width / 2, y: canvas.height - 100, passed: false },
      { x: 100, y: canvas.height / 2, passed: false }
    ];

    this.keys = {};
    window.addEventListener('keydown', e => { this.keys[e.key] = true; });
    window.addEventListener('keyup', e => { this.keys[e.key] = false; });
  }

  update(dt) {
    this.gameTime += dt;

    // Handle input
    if (this.keys['ArrowUp'] || this.keys['w']) {
      this.car.speed = Math.min(this.car.speed + 0.4, this.car.maxSpeed);
    } else {
      this.car.speed *= 0.95;
    }

    if (this.keys['ArrowLeft'] || this.keys['a']) {
      this.car.angle -= 0.08;
    }
    if (this.keys['ArrowRight'] || this.keys['d']) {
      this.car.angle += 0.08;
    }

    // Move car
    this.car.x += Math.cos(this.car.angle) * this.car.speed;
    this.car.y += Math.sin(this.car.angle) * this.car.speed;

    // Keep in bounds
    this.car.x = Math.max(20, Math.min(this.canvas.width - 20, this.car.x));
    this.car.y = Math.max(20, Math.min(this.canvas.height - 20, this.car.y));

    // Check checkpoints
    this.checkpoints.forEach((cp, i) => {
      const dist = Math.hypot(cp.x - this.car.x, cp.y - this.car.y);
      if (dist < 40 && !cp.passed) {
        cp.passed = true;
        // Check if completed lap
        const allPassed = this.checkpoints.every(c => c.passed);
        if (allPassed) {
          this.lapCount++;
          this.score += 100;
          this.onScore(this.score);
          this.checkpoints.forEach(c => c.passed = false);
        }
      }
    });

    return this.gameTime < this.maxTime;
  }

  draw() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // Background
    const gradient = ctx.createLinearGradient(0, 0, w, h);
    gradient.addColorStop(0, '#2d5a2d');
    gradient.addColorStop(1, '#1a3a1a');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, w, h);

    // Road
    ctx.fillStyle = '#555';
    ctx.fillRect(50, 50, w - 100, h - 100);

    // Lane markings
    ctx.strokeStyle = '#FFD700';
    ctx.lineWidth = 2;
    ctx.setLineDash([20, 20]);
    ctx.beginPath();
    ctx.moveTo(w / 2, 50);
    ctx.lineTo(w / 2, h - 50);
    ctx.stroke();
    ctx.setLineDash([]);

    // Draw checkpoints
    this.checkpoints.forEach((cp, i) => {
      ctx.fillStyle = cp.passed ? '#00CC88' : '#FFD700';
      ctx.beginPath();
      ctx.arc(cp.x, cp.y, 25, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = '#000';
      ctx.font = 'bold 16px Arial';
      ctx.textAlign = 'center';
      ctx.fillText(i + 1, cp.x, cp.y + 5);
    });

    // Draw car
    ctx.save();
    ctx.translate(this.car.x, this.car.y);
    ctx.rotate(this.car.angle);

    ctx.fillStyle = '#0099FF';
    ctx.fillRect(-15, -25, 30, 50);

    ctx.fillStyle = '#fff';
    ctx.fillRect(-10, -15, 20, 15);

    ctx.restore();

    // UI
    ctx.fillStyle = '#FFD700';
    ctx.font = 'bold 20px Arial';
    ctx.textAlign = 'left';
    ctx.fillText(`Score: ${this.score}`, 20, 40);
    ctx.fillText(`Laps: ${this.lapCount}`, 20, 70);
    ctx.fillText(`Speed: ${(this.car.speed * 10) | 0}`, 20, 100);
    ctx.fillText(`Time: ${(this.maxTime - this.gameTime) / 1000 | 0}s`, w - 250, 40);
  }

  getResult() {
    return { score: this.score, laps: this.lapCount };
  }
}
