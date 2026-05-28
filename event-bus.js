// Advanced Event Bus System
// Decoupled event management with middleware support

class EventBus {
  constructor(options = {}) {
    this.events = new Map();
    this.middleware = [];
    this.history = [];
    this.maxHistory = options.maxHistory || 100;
    this.asyncSupport = options.asyncSupport !== false;
    this.errorHandling = options.errorHandling || 'log';
    this.eventAliases = new Map();
    this.eventGroups = new Map();
    this.wildcardListeners = [];
    this.debug = options.debug || false;
  }

  // Register event listener
  on(event, handler, options = {}) {
    if (!this.events.has(event)) {
      this.events.set(event, []);
    }

    const listener = {
      id: Math.random().toString(36).slice(2),
      handler,
      priority: options.priority || 0,
      once: options.once || false,
      context: options.context || null,
      async: options.async || false
    };

    const listeners = this.events.get(event);
    listeners.push(listener);

    // Sort by priority (higher priority first)
    listeners.sort((a, b) => b.priority - a.priority);

    if (this.debug) {
      console.log(`[EventBus] Listener registered for "${event}"`);
    }

    // Return unsubscribe function
    return () => {
      const index = listeners.indexOf(listener);
      if (index !== -1) {
        listeners.splice(index, 1);
      }
    };
  }

  // Register one-time listener
  once(event, handler, options = {}) {
    return this.on(event, handler, { ...options, once: true });
  }

  // Register wildcard listener
  onAny(handler, options = {}) {
    const listener = {
      id: Math.random().toString(36).slice(2),
      handler,
      priority: options.priority || 0
    };

    this.wildcardListeners.push(listener);
    this.wildcardListeners.sort((a, b) => b.priority - a.priority);

    return () => {
      const index = this.wildcardListeners.indexOf(listener);
      if (index !== -1) {
        this.wildcardListeners.splice(index, 1);
      }
    };
  }

  // Emit event
  emit(event, data = {}) {
    return this._emitEvent(event, data, false);
  }

  // Emit async event
  async emitAsync(event, data = {}) {
    return this._emitEvent(event, data, true);
  }

  // Private: Emit event
  async _emitEvent(event, data, isAsync) {
    const eventData = {
      event,
      data,
      timestamp: Date.now(),
      propagationStopped: false
    };

    // Apply middleware
    for (const mw of this.middleware) {
      try {
        await mw(eventData);
      } catch (e) {
        this._handleError(e, `Middleware error for event "${event}"`);
      }
    }

    if (eventData.propagationStopped) {
      return null;
    }

    // Record in history
    this._recordEvent(eventData);

    const listeners = this.events.get(event) || [];
    const results = [];

    // Handle wildcard listeners first
    for (const listener of this.wildcardListeners) {
      try {
        const result = listener.handler(event, data);
        if (isAsync) {
          await result;
        }
        results.push(result);
      } catch (e) {
        this._handleError(e, `Wildcard listener error for event "${event}"`);
      }
    }

    // Handle specific listeners
    for (const listener of listeners) {
      try {
        const result = listener.handler(data);

        if (isAsync) {
          await result;
        }

        results.push(result);

        if (listener.once) {
          const index = listeners.indexOf(listener);
          if (index !== -1) {
            listeners.splice(index, 1);
          }
        }
      } catch (e) {
        this._handleError(e, `Listener error for event "${event}"`);
      }
    }

    if (this.debug) {
      console.log(`[EventBus] Event emitted: "${event}"`, data);
    }

    return results;
  }

  // Register middleware
  use(middleware) {
    this.middleware.push(middleware);
    return this;
  }

  // Create event alias
  alias(alias, eventName) {
    this.eventAliases.set(alias, eventName);
  }

  // Create event group
  createGroup(groupName, events = []) {
    this.eventGroups.set(groupName, events);
  }

  // Listen to event group
  onGroup(groupName, handler) {
    const events = this.eventGroups.get(groupName) || [];
    const unsubscribers = events.map(event => this.on(event, handler));

    return () => {
      unsubscribers.forEach(unsub => unsub());
    };
  }

  // Emit group
  emitGroup(groupName, data = {}) {
    const events = this.eventGroups.get(groupName) || [];
    return events.map(event => this.emit(event, data));
  }

  // Remove listener
  off(event, listenerId) {
    const listeners = this.events.get(event);
    if (!listeners) return false;

    const index = listeners.findIndex(l => l.id === listenerId);
    if (index !== -1) {
      listeners.splice(index, 1);
      return true;
    }

    return false;
  }

  // Remove all listeners for event
  offAll(event) {
    this.events.delete(event);
  }

  // Get listener count
  getListenerCount(event) {
    const listeners = this.events.get(event);
    return listeners ? listeners.length : 0;
  }

  // Get all events
  getAllEvents() {
    return Array.from(this.events.keys());
  }

  // Get event history
  getHistory(event, limit = 10) {
    const filtered = event
      ? this.history.filter(h => h.event === event)
      : this.history;

    return filtered.slice(-limit);
  }

  // Clear event history
  clearHistory() {
    this.history = [];
  }

  // Pause/resume events
  pause() {
    this._paused = true;
  }

  resume() {
    this._paused = false;
  }

  // Enable/disable debug mode
  setDebug(enabled) {
    this.debug = enabled;
  }

  // Get statistics
  getStatistics() {
    const stats = {
      eventCount: this.events.size,
      totalListeners: 0,
      totalEmissions: this.history.length,
      listenersByEvent: {}
    };

    this.events.forEach((listeners, event) => {
      stats.totalListeners += listeners.length;
      stats.listenersByEvent[event] = listeners.length;
    });

    stats.wildcardListeners = this.wildcardListeners.length;
    stats.middleware = this.middleware.length;

    return stats;
  }

  // Export configuration
  export() {
    return {
      eventAliases: Object.fromEntries(this.eventAliases),
      eventGroups: Object.fromEntries(this.eventGroups),
      statistics: this.getStatistics()
    };
  }

  // Private methods

  _recordEvent(eventData) {
    this.history.push(eventData);

    if (this.history.length > this.maxHistory) {
      this.history.shift();
    }
  }

  _handleError(error, context) {
    if (this.errorHandling === 'throw') {
      throw error;
    } else if (this.errorHandling === 'log') {
      console.error(`[EventBus] ${context}:`, error);
    } else if (typeof this.errorHandling === 'function') {
      this.errorHandling(error, context);
    }
  }
}

// Create global instance
window.EventBus = new EventBus();

// Middleware examples
class EventBusMiddleware {
  // Rate limiting middleware
  static rateLimit(maxEventsPerSecond = 100) {
    let eventCount = 0;
    let lastResetTime = Date.now();

    return (eventData) => {
      const now = Date.now();

      if (now - lastResetTime > 1000) {
        eventCount = 0;
        lastResetTime = now;
      }

      eventCount++;

      if (eventCount > maxEventsPerSecond) {
        console.warn(`[EventBus] Rate limit exceeded for event: ${eventData.event}`);
        eventData.propagationStopped = true;
      }
    };
  }

  // Event filtering middleware
  static filter(predicate) {
    return (eventData) => {
      if (!predicate(eventData.event, eventData.data)) {
        eventData.propagationStopped = true;
      }
    };
  }

  // Event logging middleware
  static logger(prefix = '[Event]') {
    return (eventData) => {
      console.log(`${prefix} ${eventData.event}:`, eventData.data);
    };
  }

  // Event validation middleware
  static validate(schema) {
    return (eventData) => {
      if (schema[eventData.event]) {
        const validators = schema[eventData.event];
        for (const [key, validator] of Object.entries(validators)) {
          if (!validator(eventData.data[key])) {
            console.warn(`[EventBus] Validation failed for ${eventData.event}.${key}`);
            eventData.propagationStopped = true;
          }
        }
      }
    };
  }
}

// Helper functions
window.event = {
  on: (event, handler, opts) => window.EventBus.on(event, handler, opts),
  once: (event, handler) => window.EventBus.once(event, handler),
  emit: (event, data) => window.EventBus.emit(event, data),
  off: (event) => window.EventBus.offAll(event),
  stats: () => window.EventBus.getStatistics(),
  history: () => window.EventBus.getHistory(),
  group: (name, events) => window.EventBus.createGroup(name, events)
};

export { EventBus, EventBusMiddleware };
