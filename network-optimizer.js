// Advanced Network Optimization System
// Lag compensation, bandwidth optimization, and network diagnostics

class NetworkOptimizer {
  constructor(options = {}) {
    this.enabled = options.enabled !== false;
    this.lagCompensation = options.lagCompensation !== false;
    this.bandwidthOptimization = options.bandwidthOptimization !== false;
    this.maxLatency = options.maxLatency || 500;
    this.targetFPS = options.targetFPS || 60;
    this.tickRate = 1000 / this.targetFPS;

    // Network metrics
    this.latency = 0;
    this.jitter = [];
    this.bandwidth = 0;
    this.packetLoss = 0;
    this.connectionQuality = 'good';

    // Diagnostics
    this.diagnostics = {
      sentPackets: 0,
      receivedPackets: 0,
      lostPackets: 0,
      duplicatePackets: 0,
      outOfOrderPackets: 0
    };

    // Queue system
    this.sendQueue = [];
    this.receiveQueue = [];
    this.maxQueueSize = options.maxQueueSize || 1000;

    // Compression
    this.compressionEnabled = options.compression !== false;
    this.compressionLevel = options.compressionLevel || 6;

    // Delta compression
    this.lastState = null;
    this.stateHistory = [];
    this.maxHistorySize = 100;

    // Interpolation
    this.interpolation = options.interpolation !== false;
    this.interpolationDelay = options.interpolationDelay || 50; // ms

    this._startDiagnostics();
  }

  // Measure latency (ping)
  async measureLatency() {
    const startTime = Date.now();

    try {
      const response = await fetch('/ping', { method: 'HEAD' });

      if (response.ok) {
        const latency = Date.now() - startTime;
        this.latency = latency;
        this.jitter.push(latency);

        if (this.jitter.length > 10) {
          this.jitter.shift();
        }

        this._updateConnectionQuality();
        return latency;
      }
    } catch (e) {
      console.warn('[NetworkOptimizer] Ping failed:', e);
    }

    return null;
  }

  // Measure bandwidth
  async measureBandwidth() {
    const testSize = 1024 * 1024; // 1MB
    const startTime = Date.now();

    try {
      const response = await fetch('/bandwidth-test');
      const data = await response.blob();
      const duration = Date.now() - startTime;

      // Calculate bandwidth in Mbps
      this.bandwidth = (data.size * 8 / 1000000) / (duration / 1000);
      this._updateConnectionQuality();

      return this.bandwidth;
    } catch (e) {
      console.warn('[NetworkOptimizer] Bandwidth test failed:', e);
    }

    return null;
  }

  // Queue packet for sending
  queuePacket(data, options = {}) {
    if (this.sendQueue.length >= this.maxQueueSize) {
      console.warn('[NetworkOptimizer] Send queue full');
      return false;
    }

    const packet = {
      id: this._generatePacketId(),
      timestamp: Date.now(),
      data,
      priority: options.priority || 'normal',
      compressed: false,
      ...options
    };

    // Apply compression if enabled
    if (this.compressionEnabled && data.length > 100) {
      packet.data = this._compressData(data);
      packet.compressed = true;
    }

    // Apply delta compression if applicable
    if (options.deltaCompress && this.lastState) {
      packet.delta = this._calculateDelta(this.lastState, data);
    }

    this.sendQueue.push(packet);
    this.diagnostics.sentPackets++;

    return packet.id;
  }

  // Flush send queue
  flushQueue(maxPackets = 10) {
    const toSend = this.sendQueue.splice(0, maxPackets);

    if (toSend.length === 0) return [];

    // Sort by priority
    toSend.sort((a, b) => {
      const priorityMap = { critical: 3, high: 2, normal: 1, low: 0 };
      return (priorityMap[b.priority] || 1) - (priorityMap[a.priority] || 1);
    });

    return toSend;
  }

  // Process received packet
  processReceivedPacket(packet) {
    this.diagnostics.receivedPackets++;

    // Check for duplicates
    if (this.stateHistory.find(s => s.id === packet.id)) {
      this.diagnostics.duplicatePackets++;
      return null;
    }

    // Decompress if needed
    if (packet.compressed) {
      packet.data = this._decompressData(packet.data);
    }

    // Apply delta if present
    if (packet.delta && this.lastState) {
      packet.data = this._applyDelta(this.lastState, packet.delta);
    }

    // Store in history
    this.stateHistory.push({
      id: packet.id,
      data: packet.data,
      timestamp: Date.now()
    });

    if (this.stateHistory.length > this.maxHistorySize) {
      this.stateHistory.shift();
    }

    this.lastState = packet.data;
    this.receiveQueue.push(packet);

    return packet.data;
  }

  // Interpolate between states
  interpolateState(currentState, targetState, alpha = 0.5) {
    const interpolated = { ...currentState };

    for (const key in targetState) {
      if (typeof targetState[key] === 'number' && typeof currentState[key] === 'number') {
        interpolated[key] = currentState[key] + (targetState[key] - currentState[key]) * alpha;
      } else if (typeof targetState[key] === 'object' && targetState[key] !== null) {
        interpolated[key] = this.interpolateState(currentState[key] || {}, targetState[key], alpha);
      }
    }

    return interpolated;
  }

  // Apply lag compensation
  applyLagCompensation(state) {
    if (!this.lagCompensation) return state;

    // Adjust object positions based on current latency
    const latencyFactor = this.latency / 1000;
    const compensated = { ...state };

    if (state.position && state.velocity) {
      compensated.position = {
        ...state.position,
        x: state.position.x + state.velocity.x * latencyFactor,
        y: state.position.y + state.velocity.y * latencyFactor,
        z: state.position.z + state.velocity.z * latencyFactor
      };
    }

    return compensated;
  }

  // Get connection quality
  getConnectionQuality() {
    return {
      quality: this.connectionQuality,
      latency: this.latency,
      bandwidth: this.bandwidth.toFixed(2),
      packetLoss: this.packetLoss.toFixed(2),
      jitterAvg: this._getAverageJitter().toFixed(2)
    };
  }

  // Get network diagnostics
  getDiagnostics() {
    const packetLossRate = this.diagnostics.sentPackets > 0
      ? (this.diagnostics.lostPackets / this.diagnostics.sentPackets * 100).toFixed(2)
      : 0;

    return {
      ...this.diagnostics,
      packetLossRate,
      queueSizes: {
        send: this.sendQueue.length,
        receive: this.receiveQueue.length
      },
      compression: this.compressionEnabled,
      interpolation: this.interpolation,
      lagCompensation: this.lagCompensation
    };
  }

  // Optimize network settings based on quality
  optimizeForQuality() {
    if (this.connectionQuality === 'poor') {
      this.compressionEnabled = true;
      this.compressionLevel = 9;
      this.targetFPS = 30;
    } else if (this.connectionQuality === 'fair') {
      this.compressionEnabled = true;
      this.compressionLevel = 6;
      this.targetFPS = 45;
    } else {
      this.compressionEnabled = false;
      this.targetFPS = 60;
    }
  }

  // Get send queue status
  getSendQueueStatus() {
    return {
      queueSize: this.sendQueue.length,
      maxSize: this.maxQueueSize,
      utilizationPercent: (this.sendQueue.length / this.maxQueueSize * 100).toFixed(2),
      packetsQueued: this.sendQueue.length
    };
  }

  // Get receive queue status
  getReceiveQueueStatus() {
    return {
      queueSize: this.receiveQueue.length,
      maxSize: this.maxQueueSize,
      utilizationPercent: (this.receiveQueue.length / this.maxQueueSize * 100).toFixed(2),
      packetsQueued: this.receiveQueue.length
    };
  }

  // Clear queues
  clearQueues() {
    this.sendQueue = [];
    this.receiveQueue = [];
  }

  // Get network report
  getNetworkReport() {
    return {
      connection: this.getConnectionQuality(),
      diagnostics: this.getDiagnostics(),
      queueStatus: {
        send: this.getSendQueueStatus(),
        receive: this.getReceiveQueueStatus()
      },
      recommendations: this._getRecommendations()
    };
  }

  // Private methods

  _startDiagnostics() {
    // Measure latency periodically
    setInterval(() => {
      this.measureLatency();
      this.measureBandwidth();
    }, 10000); // Every 10 seconds
  }

  _updateConnectionQuality() {
    const avgJitter = this._getAverageJitter();

    if (this.latency < 50 && avgJitter < 20 && this.bandwidth > 10) {
      this.connectionQuality = 'excellent';
    } else if (this.latency < 100 && avgJitter < 50 && this.bandwidth > 5) {
      this.connectionQuality = 'good';
    } else if (this.latency < 200 && avgJitter < 100 && this.bandwidth > 2) {
      this.connectionQuality = 'fair';
    } else {
      this.connectionQuality = 'poor';
    }
  }

  _getAverageJitter() {
    if (this.jitter.length === 0) return 0;

    const avg = this.jitter.reduce((a, b) => a + b, 0) / this.jitter.length;
    const variance = this.jitter.reduce((sum, val) => sum + Math.pow(val - avg, 2), 0) / this.jitter.length;

    return Math.sqrt(variance);
  }

  _compressData(data) {
    // Simple compression using JSON stringification
    return btoa(JSON.stringify(data));
  }

  _decompressData(data) {
    try {
      return JSON.parse(atob(data));
    } catch {
      return data;
    }
  }

  _calculateDelta(previous, current) {
    const delta = {};

    for (const key in current) {
      if (JSON.stringify(current[key]) !== JSON.stringify(previous[key])) {
        delta[key] = current[key];
      }
    }

    return delta;
  }

  _applyDelta(previous, delta) {
    return { ...previous, ...delta };
  }

  _generatePacketId() {
    return Date.now() + '_' + Math.random().toString(36).slice(2);
  }

  _getRecommendations() {
    const recommendations = [];

    if (this.latency > this.maxLatency) {
      recommendations.push('Latency is high - consider closer server or network optimization');
    }

    if (this._getAverageJitter() > 100) {
      recommendations.push('Jitter is high - network stability is poor');
    }

    if (this.bandwidth < 1) {
      recommendations.push('Bandwidth is low - enable compression');
    }

    if (this.sendQueue.length > this.maxQueueSize * 0.8) {
      recommendations.push('Send queue is full - reduce packet frequency');
    }

    if (this.diagnostics.packetLoss > 0) {
      recommendations.push('Packet loss detected - enable resend mechanism');
    }

    if (recommendations.length === 0) {
      recommendations.push('Network connection is optimal');
    }

    return recommendations;
  }
}

// Global instance
window.NetworkOptimizer = new NetworkOptimizer();

// Helper functions
window.network = {
  ping: () => window.NetworkOptimizer.measureLatency(),
  bandwidth: () => window.NetworkOptimizer.measureBandwidth(),
  quality: () => window.NetworkOptimizer.getConnectionQuality(),
  diagnostics: () => window.NetworkOptimizer.getDiagnostics(),
  report: () => window.NetworkOptimizer.getNetworkReport(),
  queue: (data, opts) => window.NetworkOptimizer.queuePacket(data, opts)
};

export { NetworkOptimizer };
