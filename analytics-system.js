// Advanced Analytics System
// Event tracking, player behavior analysis, and performance metrics

class AnalyticsSystem {
  constructor(options = {}) {
    this.enabled = options.enabled !== false;
    this.autoFlush = options.autoFlush !== false;
    this.flushInterval = options.flushInterval || 30000; // 30 seconds
    this.batchSize = options.batchSize || 50;
    this.events = [];
    this.sessions = new Map();
    this.currentSession = null;
    this.players = new Map();
    this.customDimensions = new Map();
    this.funnels = new Map();
    this.heatmaps = new Map();

    if (this.autoFlush) {
      this._startAutoFlush();
    }

    this._startSession();
  }

  // Track event
  trackEvent(eventName, properties = {}) {
    if (!this.enabled) return;

    const event = {
      name: eventName,
      timestamp: Date.now(),
      sessionId: this.currentSession?.id,
      properties: {
        ...properties,
        ...this._getSystemInfo()
      }
    };

    this.events.push(event);

    if (this.events.length >= this.batchSize) {
      this.flush();
    }
  }

  // Track page view
  trackPageView(pageName, properties = {}) {
    this.trackEvent('page_view', {
      page: pageName,
      ...properties
    });
  }

  // Track user action
  trackUserAction(action, target, properties = {}) {
    this.trackEvent('user_action', {
      action,
      target,
      ...properties
    });
  }

  // Track game event
  trackGameEvent(eventType, eventData = {}) {
    this.trackEvent(`game_${eventType}`, eventData);
  }

  // Track level
  trackLevel(levelName, levelData = {}) {
    this.trackEvent('level_start', {
      level: levelName,
      ...levelData
    });
  }

  // Track achievement
  trackAchievement(achievementId, properties = {}) {
    this.trackEvent('achievement_unlocked', {
      achievementId,
      ...properties
    });
  }

  // Track purchase
  trackPurchase(itemId, price, currency = 'USD', properties = {}) {
    this.trackEvent('purchase', {
      itemId,
      price,
      currency,
      ...properties
    });
  }

  // Track error
  trackError(errorMessage, errorType = 'error', properties = {}) {
    this.trackEvent('error', {
      message: errorMessage,
      type: errorType,
      ...properties
    });
  }

  // Set user property
  setUserProperty(userId, property, value) {
    if (!this.players.has(userId)) {
      this.players.set(userId, {});
    }

    const user = this.players.get(userId);
    user[property] = value;

    this.trackEvent('user_property_set', {
      userId,
      property,
      value
    });
  }

  // Set custom dimension
  setCustomDimension(dimensionName, value) {
    this.customDimensions.set(dimensionName, value);

    this.trackEvent('custom_dimension', {
      dimension: dimensionName,
      value
    });
  }

  // Track funnel step
  trackFunnelStep(funnelName, stepName, properties = {}) {
    if (!this.funnels.has(funnelName)) {
      this.funnels.set(funnelName, []);
    }

    const funnel = this.funnels.get(funnelName);
    funnel.push({
      step: stepName,
      timestamp: Date.now(),
      ...properties
    });

    this.trackEvent('funnel_step', {
      funnel: funnelName,
      step: stepName,
      ...properties
    });
  }

  // Record heatmap data
  recordHeatmapData(pageName, x, y, event = 'click') {
    if (!this.heatmaps.has(pageName)) {
      this.heatmaps.set(pageName, []);
    }

    const heatmap = this.heatmaps.get(pageName);
    heatmap.push({
      x,
      y,
      event,
      timestamp: Date.now()
    });
  }

  // Get heatmap for page
  getHeatmapData(pageName) {
    return this.heatmaps.get(pageName) || [];
  }

  // Get funnel analysis
  getFunnelAnalysis(funnelName) {
    const funnel = this.funnels.get(funnelName);

    if (!funnel) return null;

    const steps = {};
    funnel.forEach(step => {
      if (!steps[step.step]) {
        steps[step.step] = 0;
      }
      steps[step.step]++;
    });

    return {
      funnelName,
      steps,
      totalSteps: funnel.length,
      conversionRates: this._calculateConversionRates(steps)
    };
  }

  // Get user retention
  getUserRetention(userId) {
    const userEvents = this.events.filter(e => e.properties?.userId === userId);

    return {
      userId,
      totalEvents: userEvents.length,
      firstSeen: userEvents.length > 0 ? userEvents[0].timestamp : null,
      lastSeen: userEvents.length > 0 ? userEvents[userEvents.length - 1].timestamp : null,
      sessionCount: new Set(userEvents.map(e => e.sessionId)).size
    };
  }

  // Get cohort analysis
  getCohortAnalysis(property, value) {
    return this.events.filter(e => e.properties?.[property] === value);
  }

  // Get event summary
  getEventSummary() {
    const summary = {};

    this.events.forEach(event => {
      if (!summary[event.name]) {
        summary[event.name] = 0;
      }
      summary[event.name]++;
    });

    return summary;
  }

  // Get top events
  getTopEvents(limit = 10) {
    return Object.entries(this.getEventSummary())
      .sort((a, b) => b[1] - a[1])
      .slice(0, limit)
      .map(([name, count]) => ({ name, count }));
  }

  // Get session info
  getSessionInfo() {
    return {
      id: this.currentSession?.id,
      startTime: this.currentSession?.startTime,
      duration: Date.now() - this.currentSession?.startTime,
      eventCount: this.events.length
    };
  }

  // Flush events to server
  async flush() {
    if (this.events.length === 0) return true;

    const eventsToSend = this.events.splice(0, this.batchSize);

    try {
      const response = await fetch('/api/analytics', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          events: eventsToSend,
          sessionId: this.currentSession?.id,
          timestamp: Date.now()
        })
      });

      return response.ok;
    } catch (e) {
      console.warn('[Analytics] Flush failed:', e);
      // Re-queue events
      this.events.unshift(...eventsToSend);
      return false;
    }
  }

  // Generate report
  generateReport() {
    return {
      session: this.getSessionInfo(),
      events: this.getEventSummary(),
      topEvents: this.getTopEvents(),
      totalEvents: this.events.length,
      userCount: this.players.size,
      funnels: Array.from(this.funnels.keys()).map(name =>
        this.getFunnelAnalysis(name)
      )
    };
  }

  // Export analytics data
  exportData(format = 'json') {
    const data = {
      events: this.events,
      sessions: Array.from(this.sessions.values()),
      players: Array.from(this.players.values()),
      funnels: Array.from(this.funnels.values()),
      timestamp: Date.now()
    };

    if (format === 'csv') {
      return this._convertToCSV(data.events);
    }

    return JSON.stringify(data, null, 2);
  }

  // Clear events (local only)
  clearEvents() {
    this.events = [];
  }

  // End session
  endSession() {
    if (this.currentSession) {
      this.currentSession.endTime = Date.now();
      this.currentSession.duration = this.currentSession.endTime - this.currentSession.startTime;
      this.sessions.set(this.currentSession.id, this.currentSession);
    }

    this.flush();
    this._startSession();
  }

  // Private methods

  _startSession() {
    this.currentSession = {
      id: 'session_' + Date.now(),
      startTime: Date.now(),
      properties: this._getSystemInfo()
    };
  }

  _startAutoFlush() {
    setInterval(() => {
      this.flush();
    }, this.flushInterval);
  }

  _getSystemInfo() {
    return {
      userAgent: navigator.userAgent,
      language: navigator.language,
      platform: navigator.platform,
      screenResolution: `${window.innerWidth}x${window.innerHeight}`,
      timezone: new Date().getTimezoneOffset()
    };
  }

  _calculateConversionRates(steps) {
    const entries = Object.entries(steps);
    const rates = {};

    for (let i = 0; i < entries.length - 1; i++) {
      const [step1, count1] = entries[i];
      const [step2, count2] = entries[i + 1];
      rates[`${step1} → ${step2}`] = (count2 / count1 * 100).toFixed(2) + '%';
    }

    return rates;
  }

  _convertToCSV(events) {
    if (events.length === 0) return '';

    const headers = ['Timestamp', 'Event Name', 'Session ID', 'Properties'];
    const rows = events.map(e => [
      new Date(e.timestamp).toISOString(),
      e.name,
      e.sessionId,
      JSON.stringify(e.properties)
    ]);

    const csv = [headers, ...rows]
      .map(row => row.map(cell => `"${cell}"`).join(','))
      .join('\n');

    return csv;
  }
}

// Global instance
window.Analytics = new AnalyticsSystem();

// Helper functions
window.analytics = {
  track: (event, props) => window.Analytics.trackEvent(event, props),
  trackEvent: (type, data) => window.Analytics.trackGameEvent(type, data),
  trackAction: (action, target, props) => window.Analytics.trackUserAction(action, target, props),
  trackError: (msg, type, props) => window.Analytics.trackError(msg, type, props),
  property: (userId, prop, val) => window.Analytics.setUserProperty(userId, prop, val),
  dimension: (name, val) => window.Analytics.setCustomDimension(name, val),
  report: () => window.Analytics.generateReport(),
  export: (format) => window.Analytics.exportData(format),
  funnel: (name) => window.Analytics.getFunnelAnalysis(name)
};

export { AnalyticsSystem };
