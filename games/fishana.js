// Fishana Evolution - Collect pearls, avoid sharks
export class Fishana {
  constructor(canvas, onScore) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.onScore = onScore;

    // Game settings
    this.maxTime = 30000; // 30 seconds
    this.gameTime = 0;
    this.score = 0;

    // Player (fish)
    this.player = {
      x: canvas.width / 2,
      y: canvas.height / 2,
      radius: 12,
      vx: 0,
      vy: 0,
      speed: 0
    };

    // Pearls
    this.pearls = [];
    this.spawnPearls(5);

    // Enemies (sharks)
    this.enemies = [];
    this.spawnEnemies(2);

    // Controls
    this.keys = {};
    this.setupControls();
  }

  setupControls() {
    // Keyboard
    window.addEventListener('keydown', (e) => {
      this.keys[e.key.toLowerCase()] = true;
    });
    window.addEventListener('keyup', (e) => {
      this.keys[e.key.toLowerCase()] = false;
    });

    // Mouse
    this.canvas.addEventListener('mousemove', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      const mx = e.clientX - rect.left;
      const my = e.clientY - rect.top;

      const dx = mx - this.player.x;
      const dy = my - this.player.y;
      const dist = Math.hypot(dx, dy);

      if (dist > 5) {
        this.player.vx = (dx / dist) * 5;
        this.player.vy = (dy / dist) * 5;
      }
    });

    // Touch
    this.canvas.addEventListener('touchmove', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      const touch = e.touches[0];
      const mx = touch.clientX - rect.left;
      const my = touch.clientY - rect.top;

      const dx = mx - this.player.x;
      const dy = my - this.player.y;
      const dist = Math.hypot(dx, dy);

      if (dist > 5) {
        this.player.vx = (dx / dist) * 5;
        this.player.vy = (dy / dist) * 5;
      }
    });
  }

  spawnPearls(count) {
    for (let i = 0; i < count; i++) {
      this.pearls.push({
        x: Math.random() * (this.canvas.width - 40) + 20,
        y: Math.random() * (this.canvas.height - 40) + 20,
        radius: 5
      });
    }
  }

  spawnEnemies(count) {
    for (let i = 0; i < count; i++) {
      this.enemies.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * this.canvas.height,
        radius: 18,
        vx: (Math.random() - 0.5) * 2,
        vy: (Math.random() - 0.5) * 2
      });
    }
  }

  update(dt) {
    this.gameTime += dt;

    // Update player position
    this.player.x += this.player.vx;
    this.player.y += this.player.vy;

    // Wrap around edges
    if (this.player.x < 0) this.player.x = this.canvas.width;
    if (this.player.x > this.canvas.width) this.player.x = 0;
    if (this.player.y < 0) this.player.y = this.canvas.height;
    if (this.player.y > this.canvas.height) this.player.y = 0;

    // Update enemies
    this.enemies.forEach((enemy) => {
      enemy.x += enemy.vx;
      enemy.y += enemy.vy;

      // Bounce off edges
      if (enemy.x < 0 || enemy.x > this.canvas.width) enemy.vx *= -1;
      if (enemy.y < 0 || enemy.y > this.canvas.height) enemy.vy *= -1;

      enemy.x = Math.max(0, Math.min(this.canvas.width, enemy.x));
      enemy.y = Math.max(0, Math.min(this.canvas.height, enemy.y));
    });

    // Check pearl collisions
    this.pearls = this.pearls.filter((pearl) => {
      const dist = Math.hypot(
        pearl.x - this.player.x,
        pearl.y - this.player.y
      );

      if (dist < this.player.radius + pearl.radius) {
        this.score += 10;
        this.onScore(this.score);
        return false;
      }
      return true;
    });

    // Spawn new pearls if needed
    if (this.pearls.length < 3) {
      this.spawnPearls(1);
    }

    // Check enemy collisions (game over)
    for (let enemy of this.enemies) {
      const dist = Math.hypot(
        enemy.x - this.player.x,
        enemy.y - this.player.y
      );

      if (dist < this.player.radius + enemy.radius) {
        return false; // Game over
      }
    }

    // Check time limit
    return this.gameTime < this.maxTime;
  }

  draw() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // Ocean background gradient
    const gradient = ctx.createLinearGradient(0, 0, w, h);
    gradient.addColorStop(0, '#1a4d7f');
    gradient.addColorStop(0.5, '#2d7faa');
    gradient.addColorStop(1, '#1a4d7f');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, w, h);

    // Draw bubbles (background)
    ctx.fillStyle = 'rgba(255, 255, 255, 0.1)';
    for (let i = 0; i < 5; i++) {
      const bx = (this.gameTime / 100 + i * 50) % w;
      const by = (i * 60) % h;
      ctx.beginPath();
      ctx.arc(bx, by, 3, 0, Math.PI * 2);
      ctx.fill();
    }

    // Draw pearls
    ctx.fillStyle = '#FFD700';
    this.pearls.forEach((pearl) => {
      ctx.beginPath();
      ctx.arc(pearl.x, pearl.y, pearl.radius, 0, Math.PI * 2);
      ctx.fill();

      // Pearl shine
      ctx.fillStyle = '#FFFF99';
      ctx.beginPath();
      ctx.arc(pearl.x - 2, pearl.y - 2, 2, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = '#FFD700';
    });

    // Draw enemies (sharks)
    ctx.fillStyle = '#FF4444';
    this.enemies.forEach((enemy) => {
      // Shark body
      ctx.beginPath();
      ctx.arc(enemy.x, enemy.y, enemy.radius, 0, Math.PI * 2);
      ctx.fill();

      // Shark eye
      ctx.fillStyle = '#FFFFFF';
      ctx.beginPath();
      ctx.arc(enemy.x - 6, enemy.y - 5, 4, 0, Math.PI * 2);
      ctx.fill();

      // Shark pupil
      ctx.fillStyle = '#000000';
      ctx.beginPath();
      ctx.arc(enemy.x - 6, enemy.y - 5, 2, 0, Math.PI * 2);
      ctx.fill();

      // Shark fin (triangle)
      ctx.fillStyle = '#FF4444';
      ctx.beginPath();
      ctx.moveTo(enemy.x, enemy.y - enemy.radius);
      ctx.lineTo(enemy.x - 6, enemy.y - enemy.radius - 10);
      ctx.lineTo(enemy.x + 6, enemy.y - enemy.radius - 8);
      ctx.fill();
    });

    // Draw player (fish)
    ctx.fillStyle = '#0099FF';
    // Fish body
    ctx.beginPath();
    ctx.arc(this.player.x, this.player.y, this.player.radius, 0, Math.PI * 2);
    ctx.fill();

    // Fish tail
    ctx.beginPath();
    ctx.moveTo(this.player.x - 12, this.player.y - 6);
    ctx.lineTo(this.player.x - 22, this.player.y - 12);
    ctx.lineTo(this.player.x - 22, this.player.y + 12);
    ctx.closePath();
    ctx.fill();

    // Fish eye
    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(this.player.x + 8, this.player.y - 4, 3, 0, Math.PI * 2);
    ctx.fill();

    ctx.fillStyle = '#000000';
    ctx.beginPath();
    ctx.arc(this.player.x + 8, this.player.y - 4, 1.5, 0, Math.PI * 2);
    ctx.fill();

    // Draw UI
    ctx.fillStyle = '#FFFF00';
    ctx.font = 'bold 24px Arial';
    ctx.textAlign = 'left';
    ctx.fillText(`Score: ${this.score}`, 20, 40);

    const timeLeft = Math.max(0, this.maxTime - this.gameTime);
    ctx.fillText(`Time: ${(timeLeft / 1000).toFixed(1)}s`, 20, 70);

    // Pearl count
    ctx.fillText(`Pearls: ${this.pearls.length}`, 20, 100);
  }

  getResult() {
    return {
      score: this.score,
      time: this.gameTime
    };
  }
}
