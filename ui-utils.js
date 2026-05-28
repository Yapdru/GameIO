// UI Utilities and enhancements

export class LoadingManager {
  static show(message = 'Loading...') {
    let loader = document.getElementById('gameio-loader');
    if (!loader) {
      loader = document.createElement('div');
      loader.id = 'gameio-loader';
      loader.style.cssText = `
        position: fixed;
        inset: 0;
        background: rgba(0,0,0,0.7);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        z-index: 9999;
        gap: 20px;
      `;
      document.body.appendChild(loader);
    }

    loader.innerHTML = `
      <div style="width: 40px; height: 40px; border: 4px solid #ffd84d; border-top-color: transparent; border-radius: 50%; animation: spin 1s linear infinite;"></div>
      <div style="color: white; font-size: 16px; font-weight: 900;">${message}</div>
      <style>
        @keyframes spin {
          to { transform: rotate(360deg); }
        }
      </style>
    `;
    loader.style.display = 'flex';
  }

  static hide() {
    const loader = document.getElementById('gameio-loader');
    if (loader) {
      loader.style.display = 'none';
    }
  }
}

export class ScreenTransition {
  static fadeOut(element, duration = 300) {
    return new Promise(resolve => {
      element.style.animation = `fadeOut ${duration}ms ease-out forwards`;
      setTimeout(resolve, duration);
    });
  }

  static fadeIn(element, duration = 300) {
    element.style.animation = `fadeIn ${duration}ms ease-out forwards`;
    return new Promise(resolve => setTimeout(resolve, duration));
  }
}

export class ErrorHandler {
  static show(title, message, onRetry = null) {
    const modal = document.createElement('div');
    modal.style.cssText = `
      position: fixed;
      inset: 0;
      background: rgba(0,0,0,0.8);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 10000;
    `;

    modal.innerHTML = `
      <div style="background: white; border-radius: 12px; padding: 30px; max-width: 400px; text-align: center;">
        <div style="font-size: 48px; margin-bottom: 20px;">⚠️</div>
        <h2 style="color: #ff6b6b; margin-bottom: 10px;">${title}</h2>
        <p style="color: #666; margin-bottom: 20px;">${message}</p>
        <div style="display: flex; gap: 10px;">
          ${onRetry ? `<button onclick="window.location.reload()" style="flex: 1; padding: 10px;">Retry</button>` : ''}
          <button onclick="window.location.href='/'" style="flex: 1; padding: 10px;">Back to Home</button>
        </div>
      </div>
    `;

    document.body.appendChild(modal);
  }

  static logError(error) {
    console.error('GameIO Error:', error);
    // Could send to error tracking service
  }
}

export class Settings {
  constructor() {
    this.defaults = {
      soundEnabled: true,
      musicVolume: 0.5,
      sfxVolume: 0.7,
      screenShake: true,
      animations: true,
      accessibility: false,
      showHints: true,
      theme: 'light'
    };

    this.load();
  }

  load() {
    const stored = localStorage.getItem('gameioSettings');
    if (stored) {
      try {
        this.settings = { ...this.defaults, ...JSON.parse(stored) };
      } catch (e) {
        this.settings = { ...this.defaults };
      }
    } else {
      this.settings = { ...this.defaults };
    }
  }

  save() {
    localStorage.setItem('gameioSettings', JSON.stringify(this.settings));
  }

  get(key) {
    return this.settings[key] ?? this.defaults[key];
  }

  set(key, value) {
    this.settings[key] = value;
    this.save();
    window.dispatchEvent(new CustomEvent('settingsChanged', { detail: { key, value } }));
  }

  reset() {
    this.settings = { ...this.defaults };
    this.save();
  }
}

export class TouchSupport {
  static enableTouchControls(canvas) {
    let touching = false;
    let touchX = 0;
    let touchY = 0;

    canvas.addEventListener('touchstart', (e) => {
      touching = true;
      const touch = e.touches[0];
      touchX = touch.clientX;
      touchY = touch.clientY;
    });

    canvas.addEventListener('touchmove', (e) => {
      if (!touching) return;
      e.preventDefault();
      const touch = e.touches[0];
      const deltaX = touch.clientX - touchX;
      const deltaY = touch.clientY - touchY;

      // Emit custom events for games to handle
      canvas.dispatchEvent(new CustomEvent('touchDelta', {
        detail: { deltaX, deltaY, x: touch.clientX, y: touch.clientY }
      }));
    });

    canvas.addEventListener('touchend', () => {
      touching = false;
    });
  }

  static createVirtualJoystick(container) {
    const joystick = document.createElement('div');
    joystick.style.cssText = `
      position: absolute;
      bottom: 20px;
      left: 20px;
      width: 100px;
      height: 100px;
      background: rgba(255,255,255,0.2);
      border: 2px solid rgba(255,255,255,0.5);
      border-radius: 50%;
      z-index: 100;
    `;

    const stick = document.createElement('div');
    stick.style.cssText = `
      position: absolute;
      width: 40px;
      height: 40px;
      background: rgba(255,216,77,0.8);
      border-radius: 50%;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
    `;

    joystick.appendChild(stick);

    let touching = false;
    const joystickRect = joystick.getBoundingClientRect();
    const radius = 50;

    joystick.addEventListener('touchstart', () => {
      touching = true;
    });

    joystick.addEventListener('touchmove', (e) => {
      if (!touching) return;
      e.preventDefault();

      const touch = e.touches[0];
      const centerX = joystickRect.left + radius;
      const centerY = joystickRect.top + radius;

      let deltaX = touch.clientX - centerX;
      let deltaY = touch.clientY - centerY;

      const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
      if (distance > radius) {
        deltaX = (deltaX / distance) * radius;
        deltaY = (deltaY / distance) * radius;
      }

      stick.style.transform = `translate(calc(-50% + ${deltaX}px), calc(-50% + ${deltaY}px))`;

      container.dispatchEvent(new CustomEvent('joystickMove', {
        detail: {
          x: deltaX / radius,
          y: deltaY / radius
        }
      }));
    });

    joystick.addEventListener('touchend', () => {
      touching = false;
      stick.style.transform = 'translate(-50%, -50%)';
      container.dispatchEvent(new CustomEvent('joystickMove', {
        detail: { x: 0, y: 0 }
      }));
    });

    return joystick;
  }
}

export class Analytics {
  static trackEvent(eventName, data = {}) {
    const event = {
      timestamp: Date.now(),
      name: eventName,
      data: data
    };

    // Store in sessionStorage for now
    const events = JSON.parse(sessionStorage.getItem('gameioEvents') || '[]');
    events.push(event);
    sessionStorage.setItem('gameioEvents', JSON.stringify(events));

    console.log('Event:', eventName, data);
  }

  static trackGameCompletion(gameKey, score, duration) {
    this.trackEvent('gameCompleted', {
      game: gameKey,
      score: Math.floor(score),
      duration: Math.floor(duration / 1000)
    });
  }

  static trackRoomCreated(roomCode) {
    this.trackEvent('roomCreated', { roomCode });
  }

  static trackRoomJoined(roomCode) {
    this.trackEvent('roomJoined', { roomCode });
  }

  static getSessionStats() {
    const events = JSON.parse(sessionStorage.getItem('gameioEvents') || '[]');
    return {
      totalEvents: events.length,
      gamesPlayed: events.filter(e => e.name === 'gameCompleted').length,
      averageScore: events
        .filter(e => e.name === 'gameCompleted')
        .reduce((sum, e) => sum + e.data.score, 0) /
        events.filter(e => e.name === 'gameCompleted').length || 0
    };
  }
}

export class Accessibility {
  static enableKeyboardNavigation() {
    const buttons = document.querySelectorAll('button');
    const inputs = document.querySelectorAll('input');

    const focusableElements = [...buttons, ...inputs];

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Tab') {
        const current = document.activeElement;
        const index = focusableElements.indexOf(current);

        if (e.shiftKey) {
          const prev = focusableElements[index - 1] || focusableElements[focusableElements.length - 1];
          prev?.focus();
        } else {
          const next = focusableElements[index + 1] || focusableElements[0];
          next?.focus();
        }
      }
    });
  }

  static addAriaLabels(element, label) {
    element.setAttribute('aria-label', label);
  }

  static announceToScreenReaders(message) {
    const announcement = document.createElement('div');
    announcement.setAttribute('role', 'status');
    announcement.setAttribute('aria-live', 'polite');
    announcement.style.cssText = 'position: absolute; left: -10000px;';
    announcement.textContent = message;
    document.body.appendChild(announcement);

    setTimeout(() => announcement.remove(), 1000);
  }
}

// Global singleton instances
export const settings = new Settings();
export const analytics = new Analytics();
