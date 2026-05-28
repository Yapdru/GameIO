// Space Dash - Avoid obstacles, collect stars
export class Space {
  constructor(canvas, onScore) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.onScore = onScore;

    // Game settings
    this.maxTime = 40000; // 40 seconds
    this.gameTime = 0;
    this.score = 0;
    this.level = 1;

    // Player
    this.player = {
      x: canvas.width / 2,
      y: canvas.height - 60,
      width: 30,
      height: 30,
      vx: 0
    };

    // Stars (collectibles)
    this.stars = [];
    this.spawnStars(4);

    // Obstacles (asteroids)
    this.obstacles = [];
    this.spawnObstacles(3);

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

    // Mouse
    this.canvas.addEventListener('mousemove', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      this.player.x = Math.max(20, Math.min(this.canvas.width - 20, e.clientX - rect.left));
    });

    // Touch
    this.canvas.addEventListener('touchmove', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      this.player.x = Math.max(20, Math.min(this.canvas.width - 20, e.touches[0].clientX - rect.left));
    });
  }

  spawnStars(count) {
    for (let i = 0; i < count; i++) {
      this.stars.push({
        x: Math.random() * (this.canvas.width - 40) + 20,
        y: Math.random() * (this.canvas.height * 0.6),
        radius: 6,
        vy: 2 + this.level * 0.3
      });
    }
  }

  spawnObstacles(count) {
    for (let i = 0; i < count; i++) {
      this.obstacles.push({
        x: Math.random() * (this.canvas.width - 40) + 20,
        y: -30 - Math.random() * 50,
        radius: 15 + Math.random() * 10,
        vy: 2.5 + this.level * 0.4,
        vx: (Math.random() - 0.5) * 2
      });
    }
  }

  update(dt) {
    this.gameTime += dt;

    // Keyboard steering
    if (this.keys['arrowleft'] || this.keys['a']) {
      this.player.vx = -6;
    } else if (this.keys['arrowright'] || this.keys['d']) {
      this.player.vx = 6;
    } else {
      this.player.vx *= 0.9;
    }

    this.player.x += this.player.vx;
    this.player.x = Math.max(20, Math.min(this.canvas.width - 20, this.player.x));

    // Update stars
    this.stars = this.stars.filter((star) => {
      star.y += star.vy;

      // Check collision with player
      const dist = Math.hypot(star.x - this.player.x, star.y - this.player.y);
      if (dist < star.radius + 15) {
        this.score += 25;
        this.onScore(this.score);
        return false;
      }

      return star.y < this.canvas.height;
    });

    // Update obstacles
    this.obstacles = this.obstacles.filter((obs) => {
      obs.y += obs.vy;
      obs.x += obs.vx;

      // Wrap X
      if (obs.x < -50) obs.x = this.canvas.width + 50;
      if (obs.x > this.canvas.width + 50) obs.x = -50;

      // Check collision with player
      const dist = Math.hypot(obs.x - this.player.x, obs.y - this.player.y);
      if (dist < obs.radius + 15) {
        return false; // Game over
      }

      return obs.y < this.canvas.height + 50;
    });

    // Spawn new items
    if (this.stars.length < 2 + this.level) {
      this.spawnStars(1);
    }
    if (this.obstacles.length < 2 + this.level) {
      this.spawnObstacles(1);
    }

    // Difficulty increase
    if (this.gameTime > 13000 && this.level === 1) {
      this.level = 2;
    }
    if (this.gameTime > 26000 && this.level === 2) {
      this.level = 3;
    }

    return this.gameTime < this.maxTime;
  }

  draw() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // Space background
    ctx.fillStyle = '#000814';
    ctx.fillRect(0, 0, w, h);

    // Starfield (parallax effect)
    ctx.fillStyle = '#ffffff';
    for (let i = 0; i < 50; i++) {
      const x = (this.gameTime / 50 + i * 73) % w;
      const y = (i * 11) % h;
      ctx.beginPath();
      ctx.arc(x, y, 1, 0, Math.PI * 2);
      ctx.fill();
    }

    // Draw collectible stars
    ctx.fillStyle = '#FFD700';
    this.stars.forEach((star) => {
      // Star shape
      ctx.beginPath();
      for (let i = 0; i < 5; i++) {
        const angle = (i * 4 * Math.PI) / 5 - Math.PI / 2;
        const x = star.x + star.radius * Math.cos(angle);
        const y = star.y + star.radius * Math.sin(angle);
        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }
      ctx.closePath();
      ctx.fill();

      // Glow
      ctx.strokeStyle = 'rgba(255, 215, 0, 0.3)';
      ctx.lineWidth = 2;
      ctx.stroke();
    });

    // Draw obstacles (asteroids)
    ctx.fillStyle = '#888888';
    this.obstacles.forEach((obs) => {
      ctx.beginPath();
      ctx.arc(obs.x, obs.y, obs.radius, 0, Math.PI * 2);
      ctx.fill();

      // Crater details
      ctx.fillStyle = '#666666';
      ctx.beginPath();
      ctx.arc(obs.x - 5, obs.y - 5, 3, 0, Math.PI * 2);
      ctx.fill();
      ctx.beginPath();
      ctx.arc(obs.x + 7, obs.y + 4, 2, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = '#888888';
    });

    // Draw player (ship)
    ctx.fillStyle = '#00FF00';
    // Ship body
    ctx.beginPath();
    ctx.moveTo(this.player.x, this.player.y - 15);
    ctx.lineTo(this.player.x - 12, this.player.y + 15);
    ctx.lineTo(this.player.x + 12, this.player.y + 15);
    ctx.closePath();
    ctx.fill();

    // Ship glow
    ctx.strokeStyle = '#00FF00';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(this.player.x, this.player.y, 18, 0, Math.PI * 2);
    ctx.stroke();

    // Thruster flame
    const flameHeight = 8 + Math.sin(this.gameTime / 100) * 2;
    ctx.fillStyle = 'rgba(255, 100, 0, 0.6)';
    ctx.beginPath();
    ctx.moveTo(this.player.x - 4, this.player.y + 15);
    ctx.lineTo(this.player.x + 4, this.player.y + 15);
    ctx.lineTo(this.player.x, this.player.y + 15 + flameHeight);
    ctx.closePath();
    ctx.fill();

    // Draw UI
    ctx.fillStyle = '#00FF00';
    ctx.font = 'bold 24px monospace';
    ctx.textAlign = 'left';
    ctx.fillText(`Score: ${this.score}`, 20, 40);
    ctx.fillText(`Level: ${this.level}`, 20, 70);

    const timeLeft = Math.max(0, this.maxTime - this.gameTime);
    ctx.fillText(`Time: ${(timeLeft / 1000).toFixed(1)}s`, w - 250, 40);

    // Danger warning at high level
    if (this.level === 3) {
      ctx.fillStyle = '#FF0000';
      ctx.font = 'bold 18px monospace';
      ctx.fillText('CRITICAL SPEED!', w / 2 - 80, h - 20);
    }
  }

  getResult() {
    return {
      score: this.score,
      level: this.level
    };
  }
}
