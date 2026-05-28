// Advanced Configuration Manager
// Game settings, feature flags, and tuning parameters

class ConfigurationManager {
  constructor(options = {}) {
    this.config = new Map();
    this.defaults = new Map();
    this.overrides = new Map();
    this.featureFlags = new Map();
    this.profiles = new Map();
    this.listeners = new Map();
    this.history = [];
    this.maxHistory = 50;
    this.persistToStorage = options.persistToStorage !== false;
    this.storagePrefix = options.storagePrefix || 'gameio_config_';

    this._loadFromStorage();
  }

  // Set default value
  setDefault(key, value, metadata = {}) {
    this.defaults.set(key, {
      value,
      type: typeof value,
      metadata
    });

    if (!this.config.has(key)) {
      this.config.set(key, value);
    }
  }

  // Set configuration value
  set(key, value) {
    const old = this.get(key);

    if (old === value) return true;

    this.config.set(key, value);
    this._recordChange(key, old, value);
    this._notifyListeners(key, value);

    if (this.persistToStorage) {
      this._saveToStorage(key, value);
    }

    return true;
  }

  // Get configuration value
  get(key) {
    if (this.overrides.has(key)) {
      return this.overrides.get(key);
    }
    return this.config.get(key);
  }

  // Get with fallback
  getOrDefault(key, defaultValue) {
    return this.config.has(key) ? this.get(key) : defaultValue;
  }

  // Reset to default
  reset(key) {
    const defaultConfig = this.defaults.get(key);

    if (defaultConfig) {
      this.set(key, defaultConfig.value);
      return true;
    }

    return false;
  }

  // Reset all to defaults
  resetAll() {
    this.defaults.forEach((config, key) => {
      this.set(key, config.value);
    });
  }

  // Create profile
  createProfile(name, settings = {}) {
    this.profiles.set(name, {
      name,
      settings: { ...settings },
      createdAt: Date.now()
    });
  }

  // Load profile
  loadProfile(name) {
    const profile = this.profiles.get(name);

    if (!profile) {
      console.warn(`[ConfigManager] Profile not found: ${name}`);
      return false;
    }

    Object.entries(profile.settings).forEach(([key, value]) => {
      this.set(key, value);
    });

    return true;
  }

  // Save current as profile
  saveAsProfile(name) {
    const settings = {};

    this.config.forEach((value, key) => {
      settings[key] = value;
    });

    this.createProfile(name, settings);
    return true;
  }

  // List profiles
  listProfiles() {
    return Array.from(this.profiles.keys());
  }

  // Delete profile
  deleteProfile(name) {
    return this.profiles.delete(name);
  }

  // Set feature flag
  setFeatureFlag(flag, enabled) {
    this.featureFlags.set(flag, enabled);
    this._notifyListeners(`feature_${flag}`, enabled);
  }

  // Check feature flag
  isFeatureEnabled(flag) {
    return this.featureFlags.get(flag) || false;
  }

  // Get all feature flags
  getAllFeatureFlags() {
    return Object.fromEntries(this.featureFlags);
  }

  // Override value temporarily
  override(key, value) {
    this.overrides.set(key, value);
    this._notifyListeners(key, value);
  }

  // Clear override
  clearOverride(key) {
    this.overrides.delete(key);
    this._notifyListeners(key, this.config.get(key));
  }

  // Watch for changes
  watch(key, callback) {
    if (!this.listeners.has(key)) {
      this.listeners.set(key, []);
    }

    this.listeners.get(key).push(callback);

    // Return unwatch function
    return () => {
      const listeners = this.listeners.get(key);
      const index = listeners.indexOf(callback);
      if (index !== -1) {
        listeners.splice(index, 1);
      }
    };
  }

  // Get all configuration
  getAll() {
    const all = {};

    this.config.forEach((value, key) => {
      all[key] = this.get(key);
    });

    return all;
  }

  // Set all configuration
  setAll(config) {
    Object.entries(config).forEach(([key, value]) => {
      this.set(key, value);
    });
  }

  // Export configuration
  export() {
    return {
      config: Object.fromEntries(this.config),
      profiles: Object.fromEntries(this.profiles),
      featureFlags: Object.fromEntries(this.featureFlags),
      timestamp: Date.now()
    };
  }

  // Import configuration
  import(data) {
    if (data.config) {
      Object.entries(data.config).forEach(([key, value]) => {
        this.set(key, value);
      });
    }

    if (data.profiles) {
      Object.entries(data.profiles).forEach(([name, profile]) => {
        this.profiles.set(name, profile);
      });
    }

    if (data.featureFlags) {
      Object.entries(data.featureFlags).forEach(([flag, enabled]) => {
        this.setFeatureFlag(flag, enabled);
      });
    }
  }

  // Validate configuration
  validate() {
    const issues = [];

    this.config.forEach((value, key) => {
      const defaultConfig = this.defaults.get(key);

      if (defaultConfig && typeof value !== defaultConfig.type) {
        issues.push({
          key,
          issue: `Type mismatch: ${typeof value} vs ${defaultConfig.type}`,
          severity: 'warning'
        });
      }
    });

    return {
      valid: issues.length === 0,
      issues
    };
  }

  // Get configuration history
  getHistory(limit = 10) {
    return this.history.slice(-limit);
  }

  // Clear history
  clearHistory() {
    this.history = [];
  }

  // Create preset
  createPreset(name, config = {}) {
    return this.createProfile(`preset_${name}`, config);
  }

  // Load preset
  loadPreset(name) {
    return this.loadProfile(`preset_${name}`);
  }

  // Get debug info
  getDebugInfo() {
    return {
      configSize: this.config.size,
      profileCount: this.profiles.size,
      featureFlagCount: this.featureFlags.size,
      historySize: this.history.length,
      overrideCount: this.overrides.size,
      validation: this.validate()
    };
  }

  // Private methods

  _notifyListeners(key, value) {
    if (this.listeners.has(key)) {
      this.listeners.get(key).forEach(callback => callback(value));
    }

    // Notify wildcard listeners
    if (this.listeners.has('*')) {
      this.listeners.get('*').forEach(callback => callback(key, value));
    }
  }

  _recordChange(key, oldValue, newValue) {
    this.history.push({
      key,
      oldValue,
      newValue,
      timestamp: Date.now()
    });

    if (this.history.length > this.maxHistory) {
      this.history.shift();
    }
  }

  _saveToStorage(key, value) {
    try {
      localStorage.setItem(
        this.storagePrefix + key,
        JSON.stringify(value)
      );
    } catch (e) {
      console.warn('[ConfigManager] Failed to save to storage:', e);
    }
  }

  _loadFromStorage() {
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);

      if (key && key.startsWith(this.storagePrefix)) {
        const configKey = key.replace(this.storagePrefix, '');
        const value = localStorage.getItem(key);

        try {
          this.config.set(configKey, JSON.parse(value));
        } catch (e) {
          // Invalid JSON, skip
        }
      }
    }
  }
}

// Predefined presets
class GamePresets {
  static createLowEndPreset() {
    return {
      graphics_quality: 'low',
      resolution_scale: 0.75,
      shadow_enabled: false,
      particle_count: 100,
      max_fps: 30,
      post_processing: false,
      texture_quality: 'low',
      anti_aliasing: false,
      physics_quality: 'low',
      network_bandwidth_limit: 100000
    };
  }

  static createBalancedPreset() {
    return {
      graphics_quality: 'medium',
      resolution_scale: 1.0,
      shadow_enabled: true,
      particle_count: 500,
      max_fps: 60,
      post_processing: true,
      texture_quality: 'medium',
      anti_aliasing: true,
      physics_quality: 'medium',
      network_bandwidth_limit: 500000
    };
  }

  static createHighEndPreset() {
    return {
      graphics_quality: 'high',
      resolution_scale: 1.5,
      shadow_enabled: true,
      particle_count: 2000,
      max_fps: 120,
      post_processing: true,
      texture_quality: 'high',
      anti_aliasing: true,
      physics_quality: 'high',
      network_bandwidth_limit: 2000000
    };
  }

  static createBatteryModePreset() {
    return {
      graphics_quality: 'low',
      resolution_scale: 0.5,
      shadow_enabled: false,
      particle_count: 50,
      max_fps: 24,
      post_processing: false,
      texture_quality: 'low',
      anti_aliasing: false,
      physics_quality: 'low',
      network_bandwidth_limit: 50000,
      wifi_only: true,
      auto_save_interval: 120000
    };
  }
}

// Global instance
window.Config = new ConfigurationManager();

// Load default presets
window.Config.createPreset('low_end', GamePresets.createLowEndPreset());
window.Config.createPreset('balanced', GamePresets.createBalancedPreset());
window.Config.createPreset('high_end', GamePresets.createHighEndPreset());
window.Config.createPreset('battery', GamePresets.createBatteryModePreset());

// Helper functions
window.config = {
  set: (key, val) => window.Config.set(key, val),
  get: (key, def) => window.Config.getOrDefault(key, def),
  feature: (flag) => window.Config.isFeatureEnabled(flag),
  toggle: (flag) => window.Config.setFeatureFlag(flag, !window.Config.isFeatureEnabled(flag)),
  preset: (name) => window.Config.loadPreset(name),
  export: () => window.Config.export(),
  import: (data) => window.Config.import(data),
  validate: () => window.Config.validate()
};

export { ConfigurationManager, GamePresets };
