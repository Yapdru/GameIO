// Performance monitoring and optimization

export class PerformanceMonitor {
  constructor() {
    this.metrics = {
      frameTime: [],
      networkLatency: [],
      renderTime: [],
      updateTime: []
    };
    this.maxSamples = 60; // Keep 60 samples for rolling average
  }

  recordFrame(duration) {
    this.metrics.frameTime.push(duration);
    if (this.metrics.frameTime.length > this.maxSamples) {
      this.metrics.frameTime.shift();
    }
  }

  recordNetworkLatency(duration) {
    this.metrics.networkLatency.push(duration);
    if (this.metrics.networkLatency.length > this.maxSamples) {
      this.metrics.networkLatency.shift();
    }
  }

  recordRenderTime(duration) {
    this.metrics.renderTime.push(duration);
    if (this.metrics.renderTime.length > this.maxSamples) {
      this.metrics.renderTime.shift();
    }
  }

  recordUpdateTime(duration) {
    this.metrics.updateTime.push(duration);
    if (this.metrics.updateTime.length > this.maxSamples) {
      this.metrics.updateTime.shift();
    }
  }

  getAverageFPS() {
    if (this.metrics.frameTime.length === 0) return 0;
    const avgFrameTime = this.metrics.frameTime.reduce((a, b) => a + b) / this.metrics.frameTime.length;
    return Math.round(1000 / avgFrameTime);
  }

  getAverageLatency() {
    if (this.metrics.networkLatency.length === 0) return 0;
    return Math.round(
      this.metrics.networkLatency.reduce((a, b) => a + b) / this.metrics.networkLatency.length
    );
  }

  getRenderTime() {
    if (this.metrics.renderTime.length === 0) return 0;
    return Math.round(
      this.metrics.renderTime.reduce((a, b) => a + b) / this.metrics.renderTime.length
    );
  }

  getUpdateTime() {
    if (this.metrics.updateTime.length === 0) return 0;
    return Math.round(
      this.metrics.updateTime.reduce((a, b) => a + b) / this.metrics.updateTime.length
    );
  }

  getSummary() {
    return {
      fps: this.getAverageFPS(),
      frameTime: this.getAverageFPS() > 0 ? Math.round(1000 / this.getAverageFPS()) : 0,
      networkLatency: this.getAverageLatency(),
      renderTime: this.getRenderTime(),
      updateTime: this.getUpdateTime(),
      isPerformanceGood: this.getAverageFPS() >= 50
    };
  }

  getHealthStatus() {
    const fps = this.getAverageFPS();
    if (fps >= 55) return '✅ Excellent';
    if (fps >= 45) return '🟢 Good';
    if (fps >= 30) return '🟡 Fair';
    return '🔴 Poor';
  }

  reset() {
    Object.keys(this.metrics).forEach(key => {
      this.metrics[key] = [];
    });
  }
}

export class MemoryMonitor {
  static getMemoryUsage() {
    if (!performance.memory) return null;

    return {
      usedJSHeapSize: Math.round(performance.memory.usedJSHeapSize / 1048576),
      totalJSHeapSize: Math.round(performance.memory.totalJSHeapSize / 1048576),
      jsHeapSizeLimit: Math.round(performance.memory.jsHeapSizeLimit / 1048576)
    };
  }

  static getMemoryPercentage() {
    const memory = this.getMemoryUsage();
    if (!memory) return null;
    return Math.round((memory.usedJSHeapSize / memory.jsHeapSizeLimit) * 100);
  }

  static getMemoryStatus() {
    const percentage = this.getMemoryPercentage();
    if (percentage === null) return 'Unknown';
    if (percentage < 50) return '✅ Good';
    if (percentage < 75) return '🟡 Warning';
    return '🔴 Critical';
  }
}

export class ResourceMonitor {
  static getResourceTiming() {
    const resources = performance.getEntriesByType('resource');
    const timing = {
      total: resources.length,
      images: 0,
      scripts: 0,
      stylesheets: 0,
      totalSize: 0,
      avgLoadTime: 0
    };

    let totalTime = 0;
    resources.forEach(resource => {
      if (resource.name.includes('.png') || resource.name.includes('.jpg')) timing.images++;
      if (resource.name.includes('.js')) timing.scripts++;
      if (resource.name.includes('.css')) timing.stylesheets++;
      totalTime += resource.duration;
      timing.totalSize += resource.transferSize || 0;
    });

    timing.avgLoadTime = resources.length > 0 ? Math.round(totalTime / resources.length) : 0;
    timing.totalSize = Math.round(timing.totalSize / 1024); // Convert to KB

    return timing;
  }

  static getNavigationTiming() {
    const nav = performance.getEntriesByType('navigation')[0];
    if (!nav) return null;

    return {
      dns: Math.round(nav.domainLookupEnd - nav.domainLookupStart),
      tcp: Math.round(nav.connectEnd - nav.connectStart),
      request: Math.round(nav.responseStart - nav.requestStart),
      response: Math.round(nav.responseEnd - nav.responseStart),
      dom: Math.round(nav.domComplete - nav.domLoading),
      load: Math.round(nav.loadEventEnd - nav.loadEventStart),
      total: Math.round(nav.loadEventEnd - nav.fetchStart)
    };
  }
}

export class DevTools {
  static showPerformanceOverlay(monitor) {
    const overlay = document.createElement('div');
    overlay.id = 'gameio-perf-overlay';
    overlay.style.cssText = `
      position: fixed;
      top: 10px;
      right: 10px;
      background: rgba(0,0,0,0.8);
      color: #0f0;
      font-family: monospace;
      padding: 10px;
      border-radius: 6px;
      font-size: 12px;
      z-index: 99999;
      max-width: 250px;
    `;

    const update = () => {
      const summary = monitor.getSummary();
      const memory = MemoryMonitor.getMemoryUsage();

      overlay.innerHTML = `
        <div style="color: #ffd84d; font-weight: bold; margin-bottom: 5px;">GameIO Performance</div>
        <div>FPS: ${summary.fps} ${monitor.getHealthStatus()}</div>
        <div>Frame: ${summary.frameTime}ms</div>
        <div>Network: ${summary.networkLatency}ms</div>
        <div>Render: ${summary.renderTime}ms</div>
        <div>Update: ${summary.updateTime}ms</div>
        ${memory ? `
        <div style="margin-top: 5px; border-top: 1px solid #0f0; padding-top: 5px;">
          <div>Memory: ${memory.usedJSHeapSize}/${memory.jsHeapSizeLimit}MB</div>
          <div>${MemoryMonitor.getMemoryStatus()}</div>
        </div>
        ` : ''}
      `;

      requestAnimationFrame(update);
    };

    document.body.appendChild(overlay);
    update();

    return overlay;
  }

  static logPerformanceReport(monitor) {
    console.log('=== GameIO Performance Report ===');
    const summary = monitor.getSummary();
    console.log(`FPS: ${summary.fps} ${monitor.getHealthStatus()}`);
    console.log(`Average Frame Time: ${summary.frameTime}ms`);
    console.log(`Network Latency: ${summary.networkLatency}ms`);
    console.log(`Render Time: ${summary.renderTime}ms`);
    console.log(`Update Time: ${summary.updateTime}ms`);

    const resources = ResourceMonitor.getResourceTiming();
    console.log('=== Resources ===');
    console.log(`Total Resources: ${resources.total}`);
    console.log(`Images: ${resources.images}, Scripts: ${resources.scripts}, Stylesheets: ${resources.stylesheets}`);
    console.log(`Total Size: ${resources.totalSize}KB`);
    console.log(`Average Load Time: ${resources.avgLoadTime}ms`);

    const navTiming = ResourceMonitor.getNavigationTiming();
    if (navTiming) {
      console.log('=== Page Load Timing ===');
      console.log(`DNS: ${navTiming.dns}ms, TCP: ${navTiming.tcp}ms`);
      console.log(`Request: ${navTiming.request}ms, Response: ${navTiming.response}ms`);
      console.log(`DOM: ${navTiming.dom}ms, Load: ${navTiming.load}ms`);
      console.log(`Total: ${navTiming.total}ms`);
    }
  }

  static enableDebugMode() {
    window.gameioDebug = true;
    console.log('GameIO Debug Mode Enabled');
    console.log('Use window.gameioDebug to access debug info');
  }
}

// Global instance
export const performanceMonitor = new PerformanceMonitor();
