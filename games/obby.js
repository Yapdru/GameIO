// Obby Run - Jump through obstacles
export class Obby {
  constructor(canvas, onScore) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.onScore = onScore;

    this.player = {
      x: canvas.width / 2,
      y: canvas.height - 100,
      width: 25,
      height: 35,
      vy: 0,
      jumping: false
    };

    this.platforms = [];
    this.obstacles = [];
    this.score = 0;
    this.gameTime = 0;
    this.maxTime = 45000;
    this.platformsCleared = 0;

    this.gravity = 0.4;
    this.keys = {};

    window.addEventListener('keydown', e => { this.keys[e.key] = true; });
    window.addEventListener('keyup', e => { this.keys[e.key] = false; });

    this.generateLevel();
  }

  generateLevel() {
    // Create platforms
    const platformSpacing = 80;
    const platformCount = Math.ceil(this.canvas.height / platformSpacing) + 2;

    for (let i = 0; i < platformCount; i++) {
      const y = this.canvas.height - (i * platformSpacing);
      const width = 80 + Math.random() * 40;
      const x = Math.random() * (this.canvas.width - width);

      this.platforms.push({
        x,
        y,
        width,
        height: 15,
        color: '#0099FF'
      });

      // Add obstacles
      if (i > 2 && Math.random() > 0.4) {
        const obsX = Math.random() * (this.canvas.width - 30);
        this.obstacles.push({
          x: obsX,
          y: y - 50,
          width: 30,
          height: 20,
          color: '#FF6B6B'
        });
      }
    }
  }

  update(dt) {
    this.gameTime += dt;

    // Jump
    if ((this.keys['ArrowUp'] || this.keys['w'] || this.keys[' ']) && !this.player.jumping) {
      this.player.vy = -12;
      this.player.jumping = true;
    }

    // Move left/right
    if (this.keys['ArrowLeft'] || this.keys['a']) {
      this.player.x -= 5;
    }
    if (this.keys['ArrowRight'] || this.keys['d']) {
      this.player.x += 5;
    }

    // Keep in bounds
    this.player.x = Math.max(0, Math.min(this.canvas.width - this.player.width, this.player.x));

    // Apply gravity
    this.player.vy += this.gravity;
    this.player.y += this.player.vy;

    // Platform collision
    let onPlatform = false;
    this.platforms.forEach(p => {
      if (this.player.vy > 0 &&
        this.player.y + this.player.height >= p.y &&
        this.player.y + this.player.height <= p.y + p.height + 10 &&
        this.player.x + this.player.width > p.x &&
        this.player.x < p.x + p.width) {
        this.player.y = p.y - this.player.height;
        this.player.vy = 0;
        this.player.jumping = false;
        onPlatform = true;

        // Award points for reaching new height
        const height = this.canvas.height - p.y;
        const points = Math.floor(height / 10);
        if (points > this.platformsCleared) {
          this.platformsCleared = points;
          this.score += 10;
          this.onScore(this.score);
        }
      }
    });

    // Obstacle collision
    for (const obs of this.obstacles) {
      if (this.player.x + this.player.width > obs.x &&
        this.player.x < obs.x + obs.width &&
        this.player.y + this.player.height > obs.y &&
        this.player.y < obs.y + obs.height) {
        return false; // Game over
      }
    }

    // Fall off bottom
    if (this.player.y > this.canvas.height) {
      return false;
    }

    return this.gameTime < this.maxTime;
  }

  draw() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // Background gradient
    const gradient = ctx.createLinearGradient(0, 0, 0, h);
    gradient.addColorStop(0, '#87CEEB');
    gradient.addColorStop(1, '#E0F6FF');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, w, h);

    // Draw platforms
    this.platforms.forEach(p => {
      ctx.fillStyle = p.color;
      ctx.fillRect(p.x, p.y, p.width, p.height);
      ctx.strokeStyle = '#0077CC';
      ctx.lineWidth = 2;
      ctx.strokeRect(p.x, p.y, p.width, p.height);
    });

    // Draw obstacles
    this.obstacles.forEach(o => {
      ctx.fillStyle = o.color;
      ctx.fillRect(o.x, o.y, o.width, o.height);
      // Add spikes
      ctx.strokeStyle = '#CC0000';
      ctx.lineWidth = 2;
      for (let i = 0; i < 3; i++) {
        ctx.beginPath();
        ctx.moveTo(o.x + i * 10 + 5, o.y);
        ctx.lineTo(o.x + i * 10 + 2, o.y - 8);
        ctx.lineTo(o.x + i * 10 + 8, o.y);
        ctx.stroke();
      }
    });

    // Draw player
    ctx.fillStyle = '#FFD700';
    ctx.fillRect(this.player.x, this.player.y, this.player.width, this.player.height);
    ctx.strokeStyle = '#FFA500';
    ctx.lineWidth = 2;
    ctx.strokeRect(this.player.x, this.player.y, this.player.width, this.player.height);

    // Eyes
    ctx.fillStyle = '#000';
    ctx.beginPath();
    ctx.arc(this.player.x + 7, this.player.y + 10, 3, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(this.player.x + 18, this.player.y + 10, 3, 0, Math.PI * 2);
    ctx.fill();

    // UI
    ctx.fillStyle = '#000';
    ctx.font = 'bold 20px Arial';
    ctx.fillText(`Score: ${this.score}`, 20, 40);
    ctx.fillText(`Platforms: ${this.platformsCleared}`, 20, 70);
    ctx.fillText(`Time: ${(this.maxTime - this.gameTime) / 1000 | 0}s`, w - 250, 40);
  }

  getResult() {
    return { score: this.score, platformsCleared: this.platformsCleared };
  }
}
