// Advanced Input Management System
// Unified handling for keyboard, mouse, touch, and gamepad inputs

class InputManager {
  constructor() {
    this.keys = new Map();
    this.mouse = { x: 0, y: 0, buttons: new Map() };
    this.touch = { points: new Map(), gestures: [] };
    this.gamepad = { connected: false, axes: [], buttons: [] };
    this.listeners = new Map();
    this.inputBindings = new Map();
    this.debounceTimers = new Map();
    this.throttleTimers = new Map();
    this.inputHistory = [];
    this.maxHistory = 100;

    this._initKeyboardListener();
    this._initMouseListener();
    this._initTouchListener();
    this._initGamepadListener();
  }

  // Keyboard input
  _initKeyboardListener() {
    window.addEventListener('keydown', (e) => {
      this.keys.set(e.key.toLowerCase(), true);
      this._fireInputEvent('keydown', { key: e.key });
      this._recordInput('keydown', e.key);
    });

    window.addEventListener('keyup', (e) => {
      this.keys.set(e.key.toLowerCase(), false);
      this._fireInputEvent('keyup', { key: e.key });
      this._recordInput('keyup', e.key);
    });
  }

  // Mouse input
  _initMouseListener() {
    window.addEventListener('mousemove', (e) => {
      this.mouse.x = e.clientX;
      this.mouse.y = e.clientY;
      this._fireInputEvent('mousemove', { x: e.clientX, y: e.clientY });
    });

    window.addEventListener('mousedown', (e) => {
      this.mouse.buttons.set(e.button, true);
      this._fireInputEvent('mousedown', { button: e.button, x: e.clientX, y: e.clientY });
      this._recordInput('mousedown', `button${e.button}`);
    });

    window.addEventListener('mouseup', (e) => {
      this.mouse.buttons.set(e.button, false);
      this._fireInputEvent('mouseup', { button: e.button, x: e.clientX, y: e.clientY });
      this._recordInput('mouseup', `button${e.button}`);
    });

    window.addEventListener('wheel', (e) => {
      this._fireInputEvent('scroll', { deltaY: e.deltaY });
      this._recordInput('scroll', e.deltaY > 0 ? 'down' : 'up');
    });
  }

  // Touch input
  _initTouchListener() {
    window.addEventListener('touchstart', (e) => {
      for (let i = 0; i < e.touches.length; i++) {
        const touch = e.touches[i];
        this.touch.points.set(touch.identifier, {
          x: touch.clientX,
          y: touch.clientY,
          startTime: Date.now()
        });
      }
      this._fireInputEvent('touchstart', { touches: e.touches.length });
      this._detectGestures();
    });

    window.addEventListener('touchmove', (e) => {
      for (let i = 0; i < e.touches.length; i++) {
        const touch = e.touches[i];
        const point = this.touch.points.get(touch.identifier);
        if (point) {
          point.x = touch.clientX;
          point.y = touch.clientY;
        }
      }
      this._fireInputEvent('touchmove', { touches: e.touches.length });
      this._detectGestures();
    });

    window.addEventListener('touchend', (e) => {
      for (let i = 0; i < e.changedTouches.length; i++) {
        const touch = e.changedTouches[i];
        this.touch.points.delete(touch.identifier);
      }
      this._fireInputEvent('touchend', { touches: e.touches.length });
      this._detectGestures();
    });
  }

  // Gamepad input
  _initGamepadListener() {
    window.addEventListener('gamepadconnected', (e) => {
      this.gamepad.connected = true;
      this.gamepad.gamepad = e.gamepad;
      this._fireInputEvent('gamepadconnected', { gamepad: e.gamepad });
      this._recordInput('gamepadconnected', e.gamepad.id);
      this._updateGamepadInput();
    });

    window.addEventListener('gamepaddisconnected', (e) => {
      this.gamepad.connected = false;
      this._fireInputEvent('gamepaddisconnected', {});
    });

    this._updateGamepadInput();
  }

  // Update gamepad input continuously
  _updateGamepadInput() {
    const update = () => {
      const gamepads = navigator.getGamepads?.();
      if (gamepads && gamepads[0]) {
        const pad = gamepads[0];

        // Update axes
        pad.axes.forEach((axis, i) => {
          if (Math.abs(axis) > 0.1) {
            this._fireInputEvent('gamepadaxis', { axis: i, value: axis });
          }
        });

        // Update buttons
        pad.buttons.forEach((btn, i) => {
          if (btn.pressed) {
            this._fireInputEvent('gamepadbutton', { button: i });
            this._recordInput('gamepadbutton', `button${i}`);
          }
        });
      }

      requestAnimationFrame(update);
    };

    if (this.gamepad.connected) {
      requestAnimationFrame(update);
    }
  }

  // Check if key is pressed
  isKeyPressed(key) {
    return this.keys.get(key.toLowerCase()) || false;
  }

  // Check if any key in array is pressed
  isAnyKeyPressed(keys) {
    return keys.some(k => this.isKeyPressed(k));
  }

  // Get mouse position
  getMousePosition() {
    return { x: this.mouse.x, y: this.mouse.y };
  }

  // Check if mouse button is pressed
  isMouseButtonPressed(button = 0) {
    return this.mouse.buttons.get(button) || false;
  }

  // Get touch points
  getTouchPoints() {
    return Array.from(this.touch.points.values());
  }

  // Get touch count
  getTouchCount() {
    return this.touch.points.size;
  }

  // Bind action to input
  bindInput(action, inputConfig) {
    this.inputBindings.set(action, inputConfig);
  }

  // Get input binding
  getBinding(action) {
    return this.inputBindings.get(action);
  }

  // Listen for input events
  on(eventType, callback) {
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, []);
    }
    this.listeners.get(eventType).push(callback);

    // Return unlisten function
    return () => {
      const callbacks = this.listeners.get(eventType);
      const index = callbacks.indexOf(callback);
      if (index !== -1) {
        callbacks.splice(index, 1);
      }
    };
  }

  // Debounce input
  debounce(key, callback, delay = 300) {
    if (this.debounceTimers.has(key)) {
      clearTimeout(this.debounceTimers.get(key));
    }

    const timer = setTimeout(() => {
      callback();
      this.debounceTimers.delete(key);
    }, delay);

    this.debounceTimers.set(key, timer);
  }

  // Throttle input
  throttle(key, callback, delay = 100) {
    if (!this.throttleTimers.has(key)) {
      callback();
      const timer = setTimeout(() => {
        this.throttleTimers.delete(key);
      }, delay);
      this.throttleTimers.set(key, timer);
    }
  }

  // Get input history
  getInputHistory(limit = 20) {
    return this.inputHistory.slice(-limit);
  }

  // Clear input history
  clearInputHistory() {
    this.inputHistory = [];
  }

  // Detect gestures
  _detectGestures() {
    if (this.touch.points.size === 2) {
      const points = Array.from(this.touch.points.values());
      const distance = Math.hypot(
        points[1].x - points[0].x,
        points[1].y - points[0].y
      );

      if (this.touch.lastDistance) {
        if (distance > this.touch.lastDistance * 1.1) {
          this._fireInputEvent('gesture_pinch_out', {});
        } else if (distance < this.touch.lastDistance * 0.9) {
          this._fireInputEvent('gesture_pinch_in', {});
        }
      }

      this.touch.lastDistance = distance;
    }

    // Swipe detection
    if (this.touch.points.size === 1) {
      const point = Array.from(this.touch.points.values())[0];
      if (!point.initialX) {
        point.initialX = point.x;
        point.initialY = point.y;
      }

      const deltaX = point.x - point.initialX;
      const deltaY = point.y - point.initialY;
      const distance = Math.hypot(deltaX, deltaY);

      if (distance > 50 && Date.now() - point.startTime < 300) {
        if (Math.abs(deltaX) > Math.abs(deltaY)) {
          const direction = deltaX > 0 ? 'right' : 'left';
          this._fireInputEvent('gesture_swipe', { direction });
        } else {
          const direction = deltaY > 0 ? 'down' : 'up';
          this._fireInputEvent('gesture_swipe', { direction });
        }
      }
    }
  }

  // Private: Fire input event
  _fireInputEvent(eventType, data) {
    const callbacks = this.listeners.get(eventType) || [];
    callbacks.forEach(callback => callback(data));
  }

  // Private: Record input in history
  _recordInput(type, key) {
    this.inputHistory.push({
      type,
      key,
      timestamp: Date.now()
    });

    if (this.inputHistory.length > this.maxHistory) {
      this.inputHistory.shift();
    }
  }

  // Get input statistics
  getStatistics() {
    const typeCount = {};
    const keyCount = {};

    this.inputHistory.forEach(input => {
      typeCount[input.type] = (typeCount[input.type] || 0) + 1;
      keyCount[input.key] = (keyCount[input.key] || 0) + 1;
    });

    return { typeCount, keyCount, totalInputs: this.inputHistory.length };
  }

  // Get most used keys
  getMostUsedKeys(limit = 10) {
    const keyCount = {};

    this.inputHistory.forEach(input => {
      if (input.type === 'keydown') {
        keyCount[input.key] = (keyCount[input.key] || 0) + 1;
      }
    });

    return Object.entries(keyCount)
      .sort((a, b) => b[1] - a[1])
      .slice(0, limit)
      .map(([key, count]) => ({ key, count }));
  }
}

// Global input manager instance
window.InputManager = new InputManager();

// Helper functions for common inputs
window.input = {
  isPressed: (key) => window.InputManager.isKeyPressed(key),
  mouse: () => window.InputManager.getMousePosition(),
  touches: () => window.InputManager.getTouchPoints(),
  bind: (action, config) => window.InputManager.bindInput(action, config),
  on: (event, callback) => window.InputManager.on(event, callback),
  history: () => window.InputManager.getInputHistory(),
  stats: () => window.InputManager.getStatistics()
};

export { InputManager };
