// Space Dash - Dodge asteroids, collect stars
export class Space {
  constructor(canvas, onScore) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.onScore = onScore;

    this.player = {
      x: canvas.width / 2,
      y: canvas.height - 50,
      width: 25,
      height: 35,
      vx: 0
    };

    this.stars = [];
    this.asteroids = [];
    this.score = 0;
    this.gameTime = 0;
    this.maxTime = 40000;
    this.level = 1;

    this.keys = {};
    window.addEventListener('keydown', e => { this.keys[e.key] = true; });
    window.addEventListener('keyup', e => { this.keys[e.key] = false; });

    // Mouse control
    canvas.addEventListener('mousemove', e => {
      const rect = canvas.getBoundingClientRect();
      this.player.x = Math.max(15, Math.min(canvas.width - 15, e.clientX - rect.left));
    });

    this.spawnStars(3);
    this.spawnAsteroids(3);
  }

  spawnStars(count) {
    for (let i = 0; i < count; i++) {
      this.stars.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * (this.canvas.height / 2),
        radius: 5,
        vy: 2
      });
    }
  }

  spawnAsteroids(count) {
    for (let i = 0; i < count; i++) {
      this.asteroids.push({
        x: Math.random() * this.canvas.width,
        y: -30,
        radius: 15 + Math.random() * 15,
        vy: 2 + this.level * 0.5,
        vx: (Math.random() - 0.5) * 2
      });
    }
  }

  update(dt) {
    this.gameTime += dt;

    // Player movement
    if (this.keys['ArrowLeft'] || this.keys['a']) this.player.vx = -5;
    else if (this.keys['ArrowRight'] || this.keys['d']) this.player.vx = 5;
    else this.player.vx *= 0.9;

    this.player.x += this.player.vx;
    this.player.x = Math.max(15, Math.min(this.canvas.width - 15, this.player.x));

    // Update stars
    this.stars = this.stars.filter(s => {
      s.y += s.vy;

      // Check collision with player
      const dist = Math.hypot(s.x - this.player.x, s.y - this.player.y);
      if (dist < s.radius + 15) {
        this.score += 25;
        this.onScore(this.score);
        return false;
      }

      return s.y < this.canvas.height;
    });

    // Update asteroids
    this.asteroids = this.asteroids.filter(a => {
      a.y += a.vy;
      a.x += a.vx;

      // Wrap X
      if (a.x < -50) a.x = this.canvas.width + 50;
      if (a.x > this.canvas.width + 50) a.x = -50;

      // Check collision with player
      const dist = Math.hypot(a.x - this.player.x, a.y - this.player.y);
      if (dist < a.radius + 15) {
        return false; // Game over
      }

      return a.y < this.canvas.height + 50;
    });

    // Spawn new items
    if (this.stars.length < 2 + this.level) this.spawnStars(1);
    if (this.asteroids.length < 2 + this.level) this.spawnAsteroids(1);

    // Increase difficulty
    if (this.gameTime > 10000 && this.level === 1) this.level = 2;
    if (this.gameTime > 20000 && this.level === 2) this.level = 3;

    return this.gameTime < this.maxTime;
  }

  draw() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // Space background
    ctx.fillStyle = '#000814';
    ctx.fillRect(0, 0, w, h);

    // Stars background
    ctx.fillStyle = '#fff';
    for (let i = 0; i < 50; i++) {
      const x = (this.gameTime / 20 + i * 73) % w;
      const y = (i * 11) % h;
      ctx.beginPath();
      ctx.arc(x, y, 1, 0, Math.PI * 2);
      ctx.fill();
    }

    // Draw collectibles
    ctx.fillStyle = '#FFD700';
    this.stars.forEach(s => {
      ctx.beginPath();
      ctx.arc(s.x, s.y, s.radius, 0, Math.PI * 2);
      ctx.fill();
      // Star sparkle
      ctx.strokeStyle = '#FFF';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(s.x - 8, s.y);
      ctx.lineTo(s.x + 8, s.y);
      ctx.moveTo(s.x, s.y - 8);
      ctx.lineTo(s.x, s.y + 8);
      ctx.stroke();
    });

    // Draw asteroids
    ctx.fillStyle = '#8B8B8B';
    this.asteroids.forEach(a => {
      ctx.beginPath();
      ctx.arc(a.x, a.y, a.radius, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = '#666';
      ctx.lineWidth = 2;
      ctx.stroke();
    });

    // Draw player ship
    ctx.fillStyle = '#00FF00';
    ctx.beginPath();
    ctx.moveTo(this.player.x, this.player.y - 20);
    ctx.lineTo(this.player.x - 12, this.player.y + 15);
    ctx.lineTo(this.player.x + 12, this.player.y + 15);
    ctx.fill();

    // Player glow
    ctx.strokeStyle = '#00FF00';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(this.player.x, this.player.y, 20, 0, Math.PI * 2);
    ctx.stroke();

    // UI
    ctx.fillStyle = '#FFD700';
    ctx.font = 'bold 20px Arial';
    ctx.fillText(`Score: ${this.score}`, 20, 40);
    ctx.fillText(`Level: ${this.level}`, 20, 70);
    ctx.fillText(`Time: ${(this.maxTime - this.gameTime) / 1000 | 0}s`, w - 250, 40);
  }

  getResult() {
    return { score: this.score, level: this.level };
  }
}
