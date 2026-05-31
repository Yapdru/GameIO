// Enhanced Game State Management System
// Provides state management, history tracking, and debugging

class GameStateManager {
  constructor(initialState = {}) {
    this.currentState = { ...initialState };
    this.previousState = { ...initialState };
    this.stateHistory = [];
    this.maxHistorySize = 50;
    this.listeners = new Map();
    this.locks = new Map();
    this.transactions = [];
    this.debugMode = false;
  }

  // Get current state value
  get(path) {
    return this._getValueByPath(this.currentState, path);
  }

  // Set state value with history tracking
  set(path, value, metadata = {}) {
    this.previousState = { ...this.currentState };

    const change = {
      path,
      oldValue: this._getValueByPath(this.currentState, path),
      newValue: value,
      timestamp: Date.now(),
      metadata
    };

    this._setValueByPath(this.currentState, path, value);
    this._notifyListeners(path, change);
    this._recordHistory(change);

    if (this.debugMode) {
      console.log(`[GameState] ${path} changed:`, change.oldValue, '→', change.newValue);
    }

    return change;
  }

  // Batch updates in a transaction
  transaction(updates = {}) {
    const transactionId = 'tx_' + Date.now();
    const changes = [];

    Object.entries(updates).forEach(([path, value]) => {
      const change = this.set(path, value, { transactionId });
      changes.push(change);
    });

    this.transactions.push({
      id: transactionId,
      changes,
      timestamp: Date.now()
    });

    return transactionId;
  }

  // Watch for state changes
  watch(path, callback) {
    if (!this.listeners.has(path)) {
      this.listeners.set(path, []);
    }
    this.listeners.get(path).push(callback);

    // Return unwatch function
    return () => {
      const listeners = this.listeners.get(path);
      const index = listeners.indexOf(callback);
      if (index !== -1) {
        listeners.splice(index, 1);
      }
    };
  }

  // Computed property (derived state)
  computed(path, computeFn) {
    const compute = () => {
      const value = computeFn(this.currentState);
      this.set(path, value, { computed: true });
    };

    // Recompute on any state change
    this.watch('*', compute);
    compute();
  }

  // Lock/unlock state paths for safety
  lock(path) {
    this.locks.set(path, true);
  }

  unlock(path) {
    this.locks.delete(path);
  }

  isLocked(path) {
    return this.locks.has(path);
  }

  // Get state history
  getHistory(limit = 10) {
    return this.stateHistory.slice(-limit).map(h => ({
      ...h,
      timeSince: Date.now() - h.timestamp
    }));
  }

  // Undo state change
  undo() {
    if (this.stateHistory.length === 0) {
      console.warn('[GameState] No history to undo');
      return null;
    }

    const lastChange = this.stateHistory.pop();
    this._setValueByPath(this.currentState, lastChange.path, lastChange.oldValue);
    this._notifyListeners(lastChange.path, { undo: true });

    if (this.debugMode) {
      console.log(`[GameState] Undid: ${lastChange.path}`);
    }

    return lastChange;
  }

  // Clear state history
  clearHistory() {
    this.stateHistory = [];
  }

  // Reset to initial state
  reset(initialState = {}) {
    const changes = this._getStateDiff(this.currentState, initialState);
    this.currentState = { ...initialState };
    this.previousState = { ...initialState };
    this.stateHistory = [];
    this.transactions = [];
    changes.forEach(change => {
      this._notifyListeners(change.path, change);
    });
  }

  // Export state
  export() {
    return {
      state: { ...this.currentState },
      history: [...this.stateHistory],
      timestamp: Date.now()
    };
  }

  // Import state
  import(data) {
    this.currentState = { ...data.state };
    this.stateHistory = [...(data.history || [])];
  }

  // Enable/disable debug mode
  setDebugMode(enabled) {
    this.debugMode = enabled;
  }

  // Get debug info
  getDebugInfo() {
    return {
      currentState: { ...this.currentState },
      previousState: { ...this.previousState },
      historySize: this.stateHistory.length,
      transactionCount: this.transactions.length,
      listeners: Array.from(this.listeners.keys()).length,
      locks: Array.from(this.locks.keys()),
      memoryUsage: JSON.stringify(this.currentState).length + ' bytes'
    };
  }

  // Private: Get value by path (e.g., "player.score" → 100)
  _getValueByPath(obj, path) {
    const keys = path.split('.');
    let value = obj;

    for (const key of keys) {
      if (value && typeof value === 'object' && key in value) {
        value = value[key];
      } else {
        return undefined;
      }
    }

    return value;
  }

  // Private: Set value by path
  _setValueByPath(obj, path, value) {
    const keys = path.split('.');
    const lastKey = keys.pop();
    let current = obj;

    for (const key of keys) {
      if (!(key in current)) {
        current[key] = {};
      }
      current = current[key];
    }

    current[lastKey] = value;
  }

  // Private: Get differences between two states
  _getStateDiff(oldState, newState) {
    const changes = [];
    const getAllKeys = (obj) => Object.keys(obj || {});

    const compareObjects = (obj1, obj2, path = '') => {
      const allKeys = new Set([...getAllKeys(obj1), ...getAllKeys(obj2)]);

      allKeys.forEach(key => {
        const currentPath = path ? `${path}.${key}` : key;
        const val1 = obj1[key];
        const val2 = obj2[key];

        if (typeof val1 === 'object' && typeof val2 === 'object' && val1 !== null && val2 !== null) {
          compareObjects(val1, val2, currentPath);
        } else if (val1 !== val2) {
          changes.push({
            path: currentPath,
            oldValue: val1,
            newValue: val2
          });
        }
      });
    };

    compareObjects(oldState, newState);
    return changes;
  }

  // Private: Notify listeners
  _notifyListeners(path, change) {
    if (this.listeners.has(path)) {
      this.listeners.get(path).forEach(callback => callback(change));
    }

    if (this.listeners.has('*')) {
      this.listeners.get('*').forEach(callback => callback(change));
    }
  }

  // Private: Record change in history
  _recordHistory(change) {
    this.stateHistory.push(change);

    if (this.stateHistory.length > this.maxHistorySize) {
      this.stateHistory.shift();
    }
  }
}

// Game screen state machine
class ScreenStateMachine {
  constructor() {
    this.screens = new Map();
    this.currentScreen = null;
    this.previousScreen = null;
    this.transitions = new Map();
  }

  // Register a screen
  registerScreen(name, config = {}) {
    this.screens.set(name, {
      name,
      onEnter: config.onEnter || (() => {}),
      onExit: config.onExit || (() => {}),
      update: config.update || (() => {}),
      ...config
    });
  }

  // Register a transition
  registerTransition(from, to, condition) {
    const key = `${from}→${to}`;
    this.transitions.set(key, condition);
  }

  // Change screen with transition
  changeScreen(screenName, data = {}) {
    const screen = this.screens.get(screenName);

    if (!screen) {
      console.warn(`[ScreenState] Screen "${screenName}" not found`);
      return false;
    }

    // Exit current screen
    if (this.currentScreen) {
      this.screens.get(this.currentScreen).onExit?.();
    }

    this.previousScreen = this.currentScreen;
    this.currentScreen = screenName;

    // Enter new screen
    screen.onEnter?.(data);

    return true;
  }

  // Update current screen
  update(deltaTime) {
    const screen = this.screens.get(this.currentScreen);
    screen?.update?.(deltaTime);
  }

  // Get current screen info
  getCurrentScreen() {
    return {
      current: this.currentScreen,
      previous: this.previousScreen,
      screen: this.screens.get(this.currentScreen)
    };
  }
}

// Game event system
class GameEventSystem {
  constructor() {
    this.events = new Map();
    this.eventHistory = [];
    this.maxEvents = 100;
  }

  // Emit event
  emit(eventName, data = {}) {
    const event = {
      name: eventName,
      data,
      timestamp: Date.now()
    };

    if (this.events.has(eventName)) {
      this.events.get(eventName).forEach(callback => callback(data));
    }

    this.eventHistory.push(event);
    if (this.eventHistory.length > this.maxEvents) {
      this.eventHistory.shift();
    }
  }

  // Listen for event
  on(eventName, callback) {
    if (!this.events.has(eventName)) {
      this.events.set(eventName, []);
    }
    this.events.get(eventName).push(callback);

    // Return unlisten function
    return () => {
      const callbacks = this.events.get(eventName);
      const index = callbacks.indexOf(callback);
      if (index !== -1) {
        callbacks.splice(index, 1);
      }
    };
  }

  // One-time listener
  once(eventName, callback) {
    const wrapper = (data) => {
      callback(data);
      unlisten();
    };

    const unlisten = this.on(eventName, wrapper);
  }

  // Get event history
  getHistory(eventName, limit = 10) {
    return this.eventHistory
      .filter(e => !eventName || e.name === eventName)
      .slice(-limit);
  }

  // Clear history
  clearHistory() {
    this.eventHistory = [];
  }
}

// Singleton instances
window.GameState = new GameStateManager();
window.ScreenState = new ScreenStateMachine();
window.GameEvents = new GameEventSystem();

export { GameStateManager, ScreenStateMachine, GameEventSystem };
