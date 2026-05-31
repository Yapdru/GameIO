// Performance Profiling and Optimization System
// FPS monitoring, memory tracking, and performance analytics

class PerformanceProfiler {
  constructor(options = {}) {
    this.fps = 0;
    this.frameTime = 0;
    this.memoryUsage = 0;
    this.targetFPS = options.targetFPS || 60;
    this.enabled = options.enabled !== false;
    this.detailed = options.detailed || false;

    // Timing data
    this.timings = new Map();
    this.frameTimings = [];
    this.maxFrames = 300;

    // Performance metrics
    this.metrics = {
      totalFrames: 0,
      totalTime: 0,
      frameTimeMin: Infinity,
      frameTimeMax: 0,
      frameTimeAvg: 0,
      droppedFrames: 0,
      stutters: 0
    };

    // Performance history
    this.history = {
      fps: [],
      memory: [],
      frameTime: []
    };

    this.lastFrameTime = Date.now();
    this.frameCounter = 0;
    this.fpsCounter = 0;
    this.lastSecond = Date.now();

    // Start monitoring
    this.monitor();
  }

  // Start a timer
  startTimer(label) {
    if (!this.timings.has(label)) {
      this.timings.set(label, []);
    }
    return {
      label,
      startTime: performance.now()
    };
  }

  // End a timer
  endTimer(timerObj) {
    const duration = performance.now() - timerObj.startTime;
    const data = this.timings.get(timerObj.label);

    data.push(duration);
    if (data.length > 100) {
      data.shift();
    }

    return duration;
  }

  // Get timing statistics
  getTimingStats(label) {
    const data = this.timings.get(label) || [];

    if (data.length === 0) {
      return null;
    }

    const avg = data.reduce((a, b) => a + b, 0) / data.length;
    const min = Math.min(...data);
    const max = Math.max(...data);
    const median = data.slice().sort((a, b) => a - b)[Math.floor(data.length / 2)];

    return {
      count: data.length,
      avg: avg.toFixed(2),
      min: min.toFixed(2),
      max: max.toFixed(2),
      median: median.toFixed(2),
      total: (avg * data.length).toFixed(2)
    };
  }

  // Get all timing stats
  getAllTimingStats() {
    const stats = {};
    this.timings.forEach((data, label) => {
      stats[label] = this.getTimingStats(label);
    });
    return stats;
  }

  // Mark performance
  mark(label) {
    performance.mark(label);
  }

  // Measure performance
  measure(label, startMark, endMark) {
    try {
      performance.measure(label, startMark, endMark);
      const measure = performance.getEntriesByName(label)[0];
      return measure.duration;
    } catch (e) {
      console.warn(`[Profiler] Measure failed: ${label}`);
      return null;
    }
  }

  // Update FPS counter
  updateFPS() {
    const now = Date.now();
    const deltaTime = now - this.lastFrameTime;
    this.lastFrameTime = now;
    this.frameCounter++;
    this.fpsCounter++;

    // Update frame time
    this.frameTime = deltaTime;
    this.frameTimings.push(deltaTime);
    if (this.frameTimings.length > this.maxFrames) {
      this.frameTimings.shift();
    }

    // Update metrics
    this.metrics.totalFrames++;
    this.metrics.totalTime += deltaTime;
    this.metrics.frameTimeMin = Math.min(this.metrics.frameTimeMin, deltaTime);
    this.metrics.frameTimeMax = Math.max(this.metrics.frameTimeMax, deltaTime);

    // Check for dropped frames
    if (deltaTime > (1000 / this.targetFPS) * 1.5) {
      this.metrics.droppedFrames++;
    }

    // Update FPS every second
    if (now - this.lastSecond > 1000) {
      this.fps = this.fpsCounter;
      this.fpsCounter = 0;

      // Record history
      this.history.fps.push({
        fps: this.fps,
        timestamp: now
      });

      // Update metrics
      this.metrics.frameTimeAvg = this.metrics.totalTime / this.metrics.totalFrames;

      if (this.history.fps.length > 300) {
        this.history.fps.shift();
      }

      this.lastSecond = now;
    }
  }

  // Get memory usage
  updateMemory() {
    if (performance.memory) {
      this.memoryUsage = {
        used: (performance.memory.usedJSHeapSize / 1048576).toFixed(2),
        limit: (performance.memory.jsHeapSizeLimit / 1048576).toFixed(2),
        percentage: ((performance.memory.usedJSHeapSize / performance.memory.jsHeapSizeLimit) * 100).toFixed(1)
      };

      this.history.memory.push({
        ...this.memoryUsage,
        timestamp: Date.now()
      });

      if (this.history.memory.length > 300) {
        this.history.memory.shift();
      }
    }
  }

  // Get current metrics
  getMetrics() {
    const avgFrameTime = this.frameTimings.length > 0
      ? (this.frameTimings.reduce((a, b) => a + b, 0) / this.frameTimings.length).toFixed(2)
      : 0;

    return {
      fps: this.fps,
      frameTime: this.frameTime.toFixed(2),
      avgFrameTime,
      targetFPS: this.targetFPS,
      memory: this.memoryUsage,
      metrics: this.metrics,
      health: this._calculateHealthScore()
    };
  }

  // Get performance summary
  getSummary() {
    return {
      fps: this.fps,
      memory: this.memoryUsage,
      droppedFrames: this.metrics.droppedFrames,
      totalFrames: this.metrics.totalFrames,
      averageFrameTime: this.metrics.frameTimeAvg.toFixed(2),
      timings: this.getAllTimingStats(),
      recommendations: this._getRecommendations()
    };
  }

  // Get performance history
  getHistory(type = 'fps', limit = 100) {
    return this.history[type]?.slice(-limit) || [];
  }

  // Start monitoring
  monitor() {
    const loop = () => {
      this.updateFPS();
      this.updateMemory();

      if (this.enabled) {
        requestAnimationFrame(loop);
      }
    };

    requestAnimationFrame(loop);
  }

  // Create performance chart data
  getChartData() {
    return {
      fps: this.history.fps.map((d, i) => ({ x: i, y: d.fps })),
      memory: this.history.memory.map((d, i) => ({ x: i, y: parseFloat(d.used) })),
      frameTime: this.frameTimings.map((d, i) => ({ x: i, y: d }))
    };
  }

  // Get profiler report
  getReport() {
    const report = [];
    report.push('=== PERFORMANCE PROFILER REPORT ===');
    report.push(`FPS: ${this.fps}/${this.targetFPS}`);
    report.push(`Frame Time: ${this.frameTime.toFixed(2)}ms (avg: ${this.metrics.frameTimeAvg.toFixed(2)}ms)`);
    report.push(`Total Frames: ${this.metrics.totalFrames}`);
    report.push(`Dropped Frames: ${this.metrics.droppedFrames}`);

    if (this.memoryUsage) {
      report.push(`Memory: ${this.memoryUsage.used}MB / ${this.memoryUsage.limit}MB (${this.memoryUsage.percentage}%)`);
    }

    report.push('\n=== TIMING STATS ===');
    this.getAllTimingStats().forEach((stats, label) => {
      if (stats) {
        report.push(`${label}:`);
        report.push(`  Avg: ${stats.avg}ms | Min: ${stats.min}ms | Max: ${stats.max}ms | Count: ${stats.count}`);
      }
    });

    report.push('\n=== RECOMMENDATIONS ===');
    this._getRecommendations().forEach(rec => {
      report.push(`• ${rec}`);
    });

    return report.join('\n');
  }

  // Clear data
  clear() {
    this.timings.clear();
    this.frameTimings = [];
    this.history = {
      fps: [],
      memory: [],
      frameTime: []
    };
    this.metrics = {
      totalFrames: 0,
      totalTime: 0,
      frameTimeMin: Infinity,
      frameTimeMax: 0,
      frameTimeAvg: 0,
      droppedFrames: 0,
      stutters: 0
    };
  }

  // Private: Calculate health score
  _calculateHealthScore() {
    let score = 100;

    // FPS penalty
    if (this.fps < this.targetFPS * 0.8) {
      score -= (this.targetFPS - this.fps) * 0.5;
    }

    // Memory penalty
    if (this.memoryUsage && this.memoryUsage.percentage > 80) {
      score -= 30;
    }

    // Frame time stability penalty
    const frameTimeVariance = this.metrics.frameTimeMax - this.metrics.frameTimeMin;
    if (frameTimeVariance > 16.67) {
      score -= 20;
    }

    return Math.max(0, Math.min(100, score));
  }

  // Private: Get performance recommendations
  _getRecommendations() {
    const recommendations = [];

    if (this.fps < this.targetFPS * 0.9) {
      recommendations.push('FPS is below target - consider optimizing render loop');
    }

    if (this.metrics.droppedFrames > this.metrics.totalFrames * 0.05) {
      recommendations.push('High number of dropped frames - check for long-running operations');
    }

    if (this.memoryUsage && this.memoryUsage.percentage > 80) {
      recommendations.push('Memory usage is high - consider cleanup or reducing object count');
    }

    const frameTimeVariance = this.metrics.frameTimeMax - this.metrics.frameTimeMin;
    if (frameTimeVariance > 16.67) {
      recommendations.push('Frame time is unstable - check for async operations or GC pauses');
    }

    if (recommendations.length === 0) {
      recommendations.push('Performance is good!');
    }

    return recommendations;
  }
}

// Global profiler instance
window.Profiler = new PerformanceProfiler();

// Helper functions
window.profile = {
  start: (label) => window.Profiler.startTimer(label),
  end: (timerObj) => window.Profiler.endTimer(timerObj),
  mark: (label) => window.Profiler.mark(label),
  measure: (label, start, end) => window.Profiler.measure(label, start, end),
  report: () => console.log(window.Profiler.getReport()),
  getMetrics: () => window.Profiler.getMetrics(),
  getSummary: () => window.Profiler.getSummary()
};

export { PerformanceProfiler };
