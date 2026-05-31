// Advanced Animation Engine for GameIO
// Handles complex animations, transitions, and visual effects

class AnimationEngine {
  constructor() {
    this.animations = new Map();
    this.tweens = [];
    this.frameID = null;
    this.startTime = Date.now();
    this.paused = false;
  }

  // Easing functions for smooth animations
  static easing = {
    linear: t => t,
    easeInQuad: t => t * t,
    easeOutQuad: t => 1 - (1 - t) * (1 - t),
    easeInOutQuad: t => t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t,
    easeInCubic: t => t * t * t,
    easeOutCubic: t => 1 - (1 - t) ** 3,
    easeInOutCubic: t => t < 0.5 ? 4 * t * t * t : 1 - (-2 * t + 2) ** 3 / 2,
    easeInQuart: t => t * t * t * t,
    easeOutQuart: t => 1 - (1 - t) ** 4,
    easeInQuint: t => t * t * t * t * t,
    easeOutQuint: t => 1 - (1 - t) ** 5,
    easeInExpo: t => t === 0 ? 0 : 2 ** (10 * t - 10),
    easeOutExpo: t => t === 1 ? 1 : 1 - 2 ** (-10 * t),
    easeInCirc: t => 1 - Math.sqrt(1 - t * t),
    easeOutCirc: t => Math.sqrt(1 - (t - 1) * (t - 1)),
    easeInElastic: t => t === 0 ? 0 : t === 1 ? 1 : -2 ** (10 * t - 10) * Math.sin((t * 10 - 10.75) * (2 * Math.PI / 3)),
    easeOutElastic: t => t === 0 ? 0 : t === 1 ? 1 : 2 ** (-10 * t) * Math.sin((t * 10 - 0.75) * (2 * Math.PI / 3)) + 1,
    easeOutBounce: t => {
      if (t < 1 / 2.75) return 7.5625 * t * t;
      if (t < 2 / 2.75) return 7.5625 * (t -= 1.5 / 2.75) * t + 0.75;
      if (t < 2.5 / 2.75) return 7.5625 * (t -= 2.25 / 2.75) * t + 0.9375;
      return 7.5625 * (t -= 2.625 / 2.75) * t + 0.984375;
    }
  };

  // Create a tween animation
  tween(target, props, duration = 300, easing = 'easeOutQuad') {
    const id = Math.random().toString(36).slice(2);
    const startTime = Date.now();
    const startValues = {};

    Object.keys(props).forEach(key => {
      startValues[key] = target[key];
    });

    const animFunc = () => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const easedProgress = AnimationEngine.easing[easing](progress);

      Object.keys(props).forEach(key => {
        const start = startValues[key];
        const end = props[key];
        target[key] = start + (end - start) * easedProgress;
      });

      if (progress < 1) {
        return true;
      }
      return false;
    };

    this.tweens.push({ id, animFunc, startTime, duration });
    return id;
  }

  // Animate element opacity
  fadeIn(element, duration = 300) {
    element.style.opacity = '0';
    element.style.transition = `opacity ${duration}ms`;
    setTimeout(() => {
      element.style.opacity = '1';
    }, 10);
  }

  fadeOut(element, duration = 300) {
    element.style.transition = `opacity ${duration}ms`;
    element.style.opacity = '0';
  }

  // Slide animation
  slideIn(element, direction = 'left', duration = 400) {
    element.style.opacity = '0';
    const transform = {
      left: 'translateX(-100px)',
      right: 'translateX(100px)',
      up: 'translateY(-100px)',
      down: 'translateY(100px)'
    }[direction] || 'translateX(-100px)';

    element.style.transform = transform;
    element.style.transition = `all ${duration}ms ease-out`;

    setTimeout(() => {
      element.style.opacity = '1';
      element.style.transform = 'translate(0, 0)';
    }, 10);
  }

  slideOut(element, direction = 'right', duration = 400) {
    const transform = {
      left: 'translateX(-100px)',
      right: 'translateX(100px)',
      up: 'translateY(-100px)',
      down: 'translateY(100px)'
    }[direction] || 'translateX(100px)';

    element.style.transition = `all ${duration}ms ease-in`;
    element.style.opacity = '0';
    element.style.transform = transform;
  }

  // Scale animation
  scaleIn(element, duration = 300, scale = 0.5) {
    element.style.opacity = '0';
    element.style.transform = `scale(${scale})`;
    element.style.transition = `all ${duration}ms cubic-bezier(0.34, 1.56, 0.64, 1)`;

    setTimeout(() => {
      element.style.opacity = '1';
      element.style.transform = 'scale(1)';
    }, 10);
  }

  scaleOut(element, duration = 300, scale = 0.5) {
    element.style.transition = `all ${duration}ms ease-in`;
    element.style.opacity = '0';
    element.style.transform = `scale(${scale})`;
  }

  // Bounce animation
  bounce(element, duration = 600) {
    element.style.animation = `bounce ${duration}ms cubic-bezier(0.68, -0.55, 0.265, 1.55)`;
  }

  // Shake animation
  shake(element, intensity = 5, duration = 500) {
    const keyframes = [];
    for (let i = 0; i <= 100; i += 10) {
      const x = (Math.random() - 0.5) * intensity * 2;
      const y = (Math.random() - 0.5) * intensity * 2;
      keyframes.push(`${i}% { transform: translate(${x}px, ${y}px); }`);
    }

    const style = document.createElement('style');
    style.textContent = `@keyframes shake-custom { ${keyframes.join('\n')} }`;
    document.head.appendChild(style);
    element.style.animation = `shake-custom ${duration}ms`;
  }

  // Pulse animation
  pulse(element, duration = 1000, scale = 1.1) {
    element.style.animation = `pulse ${duration}ms infinite`;
    const style = document.createElement('style');
    style.textContent = `@keyframes pulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(${scale}); } }`;
    document.head.appendChild(style);
  }

  // Flip animation
  flip(element, duration = 600) {
    element.style.perspective = '1000px';
    element.style.animation = `flip ${duration}ms ease-in-out`;
    const style = document.createElement('style');
    style.textContent = `@keyframes flip { 0% { transform: rotateY(0deg); } 50% { transform: rotateY(90deg); } 100% { transform: rotateY(0deg); } }`;
    document.head.appendChild(style);
  }

  // Rotate animation
  rotate(element, angle = 360, duration = 1000) {
    element.style.animation = `rotate-custom ${duration}ms linear`;
    const style = document.createElement('style');
    style.textContent = `@keyframes rotate-custom { from { transform: rotate(0deg); } to { transform: rotate(${angle}deg); } }`;
    document.head.appendChild(style);
  }

  // Glow effect
  glow(element, color = '#0f8fe8', duration = 1500) {
    element.style.animation = `glow-custom ${duration}ms ease-in-out infinite`;
    const style = document.createElement('style');
    style.textContent = `@keyframes glow-custom { 0%, 100% { box-shadow: 0 0 5px ${color}; } 50% { box-shadow: 0 0 20px ${color}; } }`;
    document.head.appendChild(style);
  }

  // Shimmer effect
  shimmer(element, duration = 2000) {
    const shimmerGradient = 'linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent)';
    element.style.backgroundImage = shimmerGradient;
    element.style.backgroundSize = '200% 100%';
    element.style.animation = `shimmer-custom ${duration}ms infinite`;
    const style = document.createElement('style');
    style.textContent = `@keyframes shimmer-custom { 0% { background-position: -200% 0; } 100% { background-position: 200% 0; } }`;
    document.head.appendChild(style);
  }

  // Counter animation
  animateCounter(element, start, end, duration = 1000) {
    const startTime = Date.now();
    const increment = (end - start) / (duration / 16);
    let current = start;

    const update = () => {
      current += increment;
      if (current >= end) {
        element.textContent = Math.floor(end);
      } else {
        element.textContent = Math.floor(current);
        requestAnimationFrame(update);
      }
    };

    requestAnimationFrame(update);
  }

  // Update all tweens
  update() {
    this.tweens = this.tweens.filter(tween => {
      if (tween.animFunc()) {
        return true;
      }
      return false;
    });

    if (this.tweens.length > 0 && !this.paused) {
      this.frameID = requestAnimationFrame(() => this.update());
    }
  }

  start() {
    if (!this.frameID && this.tweens.length > 0) {
      this.update();
    }
  }

  pause() {
    this.paused = true;
    if (this.frameID) {
      cancelAnimationFrame(this.frameID);
      this.frameID = null;
    }
  }

  resume() {
    this.paused = false;
    this.start();
  }

  clear() {
    this.tweens = [];
    if (this.frameID) {
      cancelAnimationFrame(this.frameID);
      this.frameID = null;
    }
  }
}

// Create global instance
window.AnimEngine = new AnimationEngine();

// Add CSS animations to document
const style = document.createElement('style');
style.textContent = `
  @keyframes bounce {
    0%, 100% { transform: translateY(0); }
    25% { transform: translateY(-10px); }
    50% { transform: translateY(-20px); }
    75% { transform: translateY(-10px); }
  }

  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }

  @keyframes slideInLeft {
    from { transform: translateX(-100px); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
  }

  @keyframes slideInRight {
    from { transform: translateX(100px); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
  }
`;
document.head.appendChild(style);

export { AnimationEngine };
