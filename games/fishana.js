// Fishana Evolution - Collect pearls, avoid sharks
export class Fishana {
  constructor(canvas, onScore) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.onScore = onScore;

    // Game state
    this.player = { x: canvas.width / 2, y: canvas.height / 2, radius: 12, vx: 0, vy: 0 };
    this.pearls = [];
    this.enemies = [];
    this.score = 0;
    this.gameTime = 0;
    this.maxTime = 30000; // 30 seconds
    this.level = 1;

    // Controls
    this.keys = {};
    window.addEventListener('keydown', e => { this.keys[e.key] = true; });
    window.addEventListener('keyup', e => { this.keys[e.key] = false; });

    // Touch controls
    canvas.addEventListener('mousemove', e => {
      const rect = canvas.getBoundingClientRect();
      const mouseX = e.clientX - rect.left;
      const mouseY = e.clientY - rect.top;
      const dx = mouseX - this.player.x;
      const dy = mouseY - this.player.y;
      const dist = Math.hypot(dx, dy);
      if (dist > 0) {
        this.player.vx = (dx / dist) * 4;
        this.player.vy = (dy / dist) * 4;
      }
    });

    this.spawnPearls(5);
    this.spawnEnemies(2);
  }

  spawnPearls(count) {
    for (let i = 0; i < count; i++) {
      this.pearls.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * this.canvas.height,
        radius: 5
      });
    }
  }

  spawnEnemies(count) {
    for (let i = 0; i < count; i++) {
      this.enemies.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * this.canvas.height,
        radius: 20,
        vx: (Math.random() - 0.5) * 2,
        vy: (Math.random() - 0.5) * 2
      });
    }
  }

  update(dt) {
    this.gameTime += dt;

    // Update player
    if (this.keys['ArrowUp'] || this.keys['w']) this.player.vy -= 0.3;
    if (this.keys['ArrowDown'] || this.keys['s']) this.player.vy += 0.3;
    if (this.keys['ArrowLeft'] || this.keys['a']) this.player.vx -= 0.3;
    if (this.keys['ArrowRight'] || this.keys['d']) this.player.vx += 0.3;

    // Friction
    this.player.vx *= 0.95;
    this.player.vy *= 0.95;

    // Limit speed
    const speed = Math.hypot(this.player.vx, this.player.vy);
    if (speed > 5) {
      this.player.vx = (this.player.vx / speed) * 5;
      this.player.vy = (this.player.vy / speed) * 5;
    }

    this.player.x += this.player.vx;
    this.player.y += this.player.vy;

    // Wrap around
    if (this.player.x < 0) this.player.x = this.canvas.width;
    if (this.player.x > this.canvas.width) this.player.x = 0;
    if (this.player.y < 0) this.player.y = this.canvas.height;
    if (this.player.y > this.canvas.height) this.player.y = 0;

    // Update enemies
    this.enemies.forEach(e => {
      e.x += e.vx;
      e.y += e.vy;
      if (e.x < 0 || e.x > this.canvas.width) e.vx *= -1;
      if (e.y < 0 || e.y > this.canvas.height) e.vy *= -1;
    });

    // Check pearl collisions
    this.pearls = this.pearls.filter(p => {
      const dist = Math.hypot(p.x - this.player.x, p.y - this.player.y);
      if (dist < this.player.radius + p.radius) {
        this.score += 10;
        this.onScore(this.score);
        return false;
      }
      return true;
    });

    // Spawn new pearls
    if (this.pearls.length < 3 + this.level) {
      this.spawnPearls(1);
    }

    // Check enemy collisions
    for (const e of this.enemies) {
      const dist = Math.hypot(e.x - this.player.x, e.y - this.player.y);
      if (dist < this.player.radius + e.radius) {
        return false; // Game over
      }
    }

    return this.gameTime < this.maxTime; // Continue if time left
  }

  draw() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // Background gradient
    const gradient = ctx.createLinearGradient(0, 0, w, h);
    gradient.addColorStop(0, '#1a3a52');
    gradient.addColorStop(1, '#0d5a7f');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, w, h);

    // Draw pearls
    ctx.fillStyle = '#FFD700';
    this.pearls.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      ctx.fill();
    });

    // Draw enemies (sharks)
    ctx.fillStyle = '#FF6B6B';
    this.enemies.forEach(e => {
      ctx.beginPath();
      ctx.arc(e.x, e.y, e.radius, 0, Math.PI * 2);
      ctx.fill();
      // Draw eyes
      ctx.fillStyle = '#fff';
      ctx.beginPath();
      ctx.arc(e.x - 7, e.y - 5, 3, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = '#FF6B6B';
    });

    // Draw player (fish)
    ctx.fillStyle = '#0099FF';
    ctx.beginPath();
    ctx.arc(this.player.x, this.player.y, this.player.radius, 0, Math.PI * 2);
    ctx.fill();
    // Fish eye
    ctx.fillStyle = '#fff';
    ctx.beginPath();
    ctx.arc(this.player.x + 5, this.player.y - 3, 3, 0, Math.PI * 2);
    ctx.fill();

    // Draw UI
    ctx.fillStyle = '#fff';
    ctx.font = 'bold 20px Arial';
    ctx.fillText(`Score: ${this.score}`, 20, 40);
    ctx.fillText(`Time: ${(this.maxTime - this.gameTime) / 1000 | 0}s`, w - 200, 40);
  }

  getResult() {
    return { score: this.score, time: this.gameTime };
  }
}
