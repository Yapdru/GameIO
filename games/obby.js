// Obby Run - Jump platforms, reach the finish
export class Obby {
  constructor(canvas, onScore) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.onScore = onScore;

    // Game settings
    this.maxTime = 45000; // 45 seconds
    this.gameTime = 0;
    this.score = 0;

    // Player
    this.player = {
      x: canvas.width / 2,
      y: canvas.height - 100,
      width: 25,
      height: 35,
      vy: 0,
      jumping: false,
      maxJump: -12,
      gravity: 0.5
    };

    // Platforms
    this.platforms = [];
    this.generatePlatforms();

    // Obstacles
    this.obstacles = [];
    this.platforOffset = 0;

    // Controls
    this.keys = {};
    this.setupControls();
  }

  setupControls() {
    window.addEventListener('keydown', (e) => {
      this.keys[e.key.toLowerCase()] = true;
      if ((e.key.toLowerCase() === 'arrowup' || e.key.toLowerCase() === 'w' || e.key === ' ') && !this.player.jumping) {
        this.player.vy = this.player.maxJump;
        this.player.jumping = true;
      }
    });
    window.addEventListener('keyup', (e) => {
      this.keys[e.key.toLowerCase()] = false;
    });

    // Touch jump
    this.canvas.addEventListener('click', () => {
      if (!this.player.jumping) {
        this.player.vy = this.player.maxJump;
        this.player.jumping = true;
      }
    });
  }

  generatePlatforms() {
    const platformSpacing = 80;
    const platformCount = Math.ceil(this.canvas.height / platformSpacing) + 2;

    for (let i = 0; i < platformCount; i++) {
      const y = this.canvas.height - i * platformSpacing;
      const width = 80 + Math.random() * 40;
      const x = Math.random() * (this.canvas.width - width);

      this.platforms.push({
        x,
        y,
        width,
        height: 15,
        color: '#0099FF'
      });

      // Add some obstacles
      if (i > 2 && Math.random() > 0.5) {
        this.obstacles.push({
          x: Math.random() * (this.canvas.width - 30),
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

    // Left/right movement
    if (this.keys['arrowleft'] || this.keys['a']) {
      this.player.x -= 5;
    }
    if (this.keys['arrowright'] || this.keys['d']) {
      this.player.x += 5;
    }

    // Keep in bounds
    this.player.x = Math.max(0, Math.min(this.canvas.width - this.player.width, this.player.x));

    // Gravity
    this.player.vy += this.player.gravity;
    this.player.y += this.player.vy;

    // Platform collision
    let onPlatform = false;
    this.platforms.forEach((platform) => {
      if (
        this.player.vy > 0 &&
        this.player.y + this.player.height >= platform.y &&
        this.player.y + this.player.height <= platform.y + platform.height + 10 &&
        this.player.x + this.player.width > platform.x &&
        this.player.x < platform.x + platform.width
      ) {
        this.player.y = platform.y - this.player.height;
        this.player.vy = 0;
        this.player.jumping = false;
        onPlatform = true;

        // Score for reaching higher platforms
        const height = this.canvas.height - platform.y;
        const points = Math.floor(height / 80);
        if (points > this.score) {
          this.score = points;
          this.onScore(this.score * 10);
        }
      }
    });

    // Obstacle collision (game over)
    for (let obstacle of this.obstacles) {
      if (
        this.player.x + this.player.width > obstacle.x &&
        this.player.x < obstacle.x + obstacle.width &&
        this.player.y + this.player.height > obstacle.y &&
        this.player.y < obstacle.y + obstacle.height
      ) {
        return false;
      }
    }

    // Fall off bottom (game over)
    if (this.player.y > this.canvas.height) {
      return false;
    }

    return this.gameTime < this.maxTime;
  }

  draw() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;

    // Sky gradient
    const gradient = ctx.createLinearGradient(0, 0, 0, h);
    gradient.addColorStop(0, '#87CEEB');
    gradient.addColorStop(1, '#E0F6FF');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, w, h);

    // Draw platforms
    this.platforms.forEach((platform) => {
      ctx.fillStyle = platform.color;
      ctx.fillRect(platform.x, platform.y, platform.width, platform.height);

      // Platform shine
      ctx.fillStyle = 'rgba(255, 255, 255, 0.3)';
      ctx.fillRect(platform.x, platform.y, platform.width, 3);

      // Border
      ctx.strokeStyle = '#0077CC';
      ctx.lineWidth = 2;
      ctx.strokeRect(platform.x, platform.y, platform.width, platform.height);
    });

    // Draw obstacles
    this.obstacles.forEach((obstacle) => {
      ctx.fillStyle = obstacle.color;
      ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);

      // Spikes
      ctx.strokeStyle = '#CC0000';
      ctx.lineWidth = 2;
      for (let i = 0; i < 3; i++) {
        ctx.beginPath();
        ctx.moveTo(obstacle.x + i * 10 + 5, obstacle.y);
        ctx.lineTo(obstacle.x + i * 10 + 2, obstacle.y - 8);
        ctx.lineTo(obstacle.x + i * 10 + 8, obstacle.y);
        ctx.stroke();
      }
    });

    // Draw player
    ctx.fillStyle = '#FFD700';
    ctx.fillRect(this.player.x, this.player.y, this.player.width, this.player.height);

    // Player eyes
    ctx.fillStyle = '#000';
    ctx.beginPath();
    ctx.arc(this.player.x + 7, this.player.y + 10, 3, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(this.player.x + 18, this.player.y + 10, 3, 0, Math.PI * 2);
    ctx.fill();

    // Draw UI
    ctx.fillStyle = '#000';
    ctx.font = 'bold 24px Arial';
    ctx.fillText(`Score: ${this.score * 10}`, 20, 40);

    const timeLeft = Math.max(0, this.maxTime - this.gameTime);
    ctx.fillText(`Time: ${(timeLeft / 1000).toFixed(1)}s`, w - 250, 40);

    // Height indicator
    ctx.fillText(`Height: ${this.score * 80}`, 20, 70);
  }

  getResult() {
    return {
      score: this.score * 10
    };
  }
}
