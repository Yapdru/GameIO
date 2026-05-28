// Network resilience and error recovery

export class NetworkManager {
  constructor() {
    this.isOnline = navigator.onLine;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.reconnectDelay = 1000; // Start with 1 second
    this.retryCallbacks = [];

    this.setupListeners();
  }

  setupListeners() {
    window.addEventListener('online', () => this.handleOnline());
    window.addEventListener('offline', () => this.handleOffline());
  }

  handleOnline() {
    this.isOnline = true;
    console.log('Network: Online');

    // Retry pending operations
    this.retryCallbacks.forEach(callback => {
      try {
        callback();
      } catch (e) {
        console.error('Retry callback failed:', e);
      }
    });
    this.retryCallbacks = [];
  }

  handleOffline() {
    this.isOnline = false;
    console.log('Network: Offline');
  }

  async retryWithBackoff(operation, maxAttempts = 3) {
    let lastError;

    for (let attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        const delay = Math.min(1000 * Math.pow(2, attempt), 10000);
        console.log(`Attempt ${attempt + 1} failed, retrying in ${delay}ms...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }

    throw lastError;
  }

  registerRetryCallback(callback) {
    this.retryCallbacks.push(callback);
  }
}

export class SyncQueue {
  constructor() {
    this.queue = [];
    this.isProcessing = false;
    this.maxQueueSize = 100;
  }

  enqueue(operation) {
    if (this.queue.length >= this.maxQueueSize) {
      console.warn('Sync queue full, dropping oldest item');
      this.queue.shift();
    }
    this.queue.push(operation);
    this.processQueue();
  }

  async processQueue() {
    if (this.isProcessing || this.queue.length === 0) return;

    this.isProcessing = true;

    while (this.queue.length > 0) {
      const operation = this.queue.shift();
      try {
        await operation();
      } catch (error) {
        console.error('Sync operation failed:', error);
        // Re-queue on failure
        this.queue.unshift(operation);
        break;
      }
    }

    this.isProcessing = false;
  }

  clear() {
    this.queue = [];
  }

  size() {
    return this.queue.length;
  }
}

export class ConnectionStatus {
  constructor() {
    this.latency = 0;
    this.lastPing = Date.now();
    this.measurementInterval = null;
  }

  startMeasuring(pingFunction, interval = 5000) {
    this.measurementInterval = setInterval(async () => {
      const start = Date.now();
      try {
        await pingFunction();
        this.latency = Date.now() - start;
      } catch (e) {
        this.latency = -1; // Connection failed
      }
    }, interval);
  }

  stopMeasuring() {
    if (this.measurementInterval) {
      clearInterval(this.measurementInterval);
      this.measurementInterval = null;
    }
  }

  getStatus() {
    if (this.latency === -1) return 'offline';
    if (this.latency > 1000) return 'slow';
    if (this.latency > 200) return 'fair';
    return 'good';
  }

  getLatencyBar() {
    const statuses = {
      'offline': '⛔',
      'slow': '🟡',
      'fair': '🟢',
      'good': '🟢'
    };
    return statuses[this.getStatus()];
  }
}

// Global instances
export const networkManager = new NetworkManager();
export const syncQueue = new SyncQueue();
export const connectionStatus = new ConnectionStatus();
