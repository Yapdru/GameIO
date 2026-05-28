// Advanced Save/Load System
// Game state persistence, backups, and recovery

class SaveLoadSystem {
  constructor(options = {}) {
    this.storageType = options.storageType || 'localStorage'; // localStorage, indexedDB, cloud
    this.encryptSensitiveData = options.encrypt || false;
    this.autoBackup = options.autoBackup !== false;
    this.backupInterval = options.backupInterval || 300000; // 5 minutes
    this.maxBackups = options.maxBackups || 10;
    this.saves = new Map();
    this.backups = [];
    this.metadata = new Map();
    this.cloudSync = null;

    if (this.autoBackup) {
      this._startAutoBackup();
    }
  }

  // Save game state
  save(filename, gameState, metadata = {}) {
    const saveData = {
      filename,
      timestamp: Date.now(),
      version: '1.0',
      data: gameState,
      metadata: {
        playerName: metadata.playerName || 'Unknown',
        level: metadata.level || 0,
        score: metadata.score || 0,
        playtime: metadata.playtime || 0,
        description: metadata.description || '',
        ...metadata
      },
      hash: this._generateHash(gameState)
    };

    if (this.encryptSensitiveData) {
      saveData.data = this._encryptData(gameState);
      saveData.encrypted = true;
    }

    // Save to local storage
    const storageKey = `gameio_save_${filename}`;
    try {
      localStorage.setItem(storageKey, JSON.stringify(saveData));
      this.saves.set(filename, saveData);
      this.metadata.set(filename, saveData.metadata);
      return true;
    } catch (e) {
      console.error('[SaveLoadSystem] Failed to save:', e);
      return false;
    }
  }

  // Load game state
  load(filename) {
    const storageKey = `gameio_save_${filename}`;

    try {
      const json = localStorage.getItem(storageKey);
      if (!json) {
        console.warn(`[SaveLoadSystem] Save file not found: ${filename}`);
        return null;
      }

      const saveData = JSON.parse(json);

      // Verify integrity
      if (!this._verifyHash(saveData.data, saveData.hash)) {
        console.warn('[SaveLoadSystem] Save file integrity check failed');
        return null;
      }

      // Decrypt if needed
      if (saveData.encrypted) {
        saveData.data = this._decryptData(saveData.data);
      }

      return saveData;
    } catch (e) {
      console.error('[SaveLoadSystem] Failed to load:', e);
      return null;
    }
  }

  // Delete save file
  deleteSave(filename) {
    const storageKey = `gameio_save_${filename}`;

    try {
      localStorage.removeItem(storageKey);
      this.saves.delete(filename);
      this.metadata.delete(filename);
      return true;
    } catch (e) {
      console.error('[SaveLoadSystem] Failed to delete:', e);
      return false;
    }
  }

  // List all saves
  listSaves() {
    const saves = [];

    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key.startsWith('gameio_save_')) {
        const filename = key.replace('gameio_save_', '');
        const json = localStorage.getItem(key);
        const saveData = JSON.parse(json);
        saves.push({
          filename,
          ...saveData.metadata,
          timestamp: saveData.timestamp,
          size: json.length
        });
      }
    }

    return saves.sort((a, b) => b.timestamp - a.timestamp);
  }

  // Quick save
  quickSave(gameState, metadata = {}) {
    return this.save('quicksave', gameState, {
      ...metadata,
      description: 'Quick save',
      isQuickSave: true
    });
  }

  // Quick load
  quickLoad() {
    return this.load('quicksave');
  }

  // Create backup
  createBackup(gameState, label = '') {
    const backup = {
      id: 'backup_' + Date.now(),
      label: label || `Backup ${this.backups.length + 1}`,
      timestamp: Date.now(),
      data: gameState,
      size: JSON.stringify(gameState).length
    };

    this.backups.push(backup);

    // Keep only recent backups
    if (this.backups.length > this.maxBackups) {
      this.backups.shift();
    }

    // Store in localStorage
    try {
      localStorage.setItem(
        `gameio_backup_${backup.id}`,
        JSON.stringify(backup)
      );
    } catch (e) {
      console.warn('[SaveLoadSystem] Backup storage full, removing oldest');
      if (this.backups.length > 0) {
        const oldest = this.backups[0];
        localStorage.removeItem(`gameio_backup_${oldest.id}`);
        this.backups.shift();
      }
    }

    return backup;
  }

  // Restore from backup
  restoreFromBackup(backupId) {
    const backup = this.backups.find(b => b.id === backupId);

    if (!backup) {
      console.warn(`[SaveLoadSystem] Backup not found: ${backupId}`);
      return null;
    }

    return backup.data;
  }

  // List all backups
  listBackups() {
    return this.backups.map(b => ({
      id: b.id,
      label: b.label,
      timestamp: b.timestamp,
      size: b.size,
      age: Date.now() - b.timestamp
    }));
  }

  // Delete old backups
  deleteOldBackups(maxAge = 86400000) { // 24 hours default
    this.backups = this.backups.filter(b => {
      const age = Date.now() - b.timestamp;
      const keep = age < maxAge;

      if (!keep) {
        localStorage.removeItem(`gameio_backup_${b.id}`);
      }

      return keep;
    });
  }

  // Export save to JSON file
  exportSave(filename) {
    const saveData = this.load(filename);

    if (!saveData) {
      console.warn(`[SaveLoadSystem] Cannot export: ${filename}`);
      return null;
    }

    const json = JSON.stringify(saveData, null, 2);
    const blob = new Blob([json], { type: 'application/json' });
    const url = URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    a.download = `${filename}.json`;
    a.click();

    URL.revokeObjectURL(url);
    return url;
  }

  // Import save from JSON file
  async importSave(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();

      reader.onload = (e) => {
        try {
          const saveData = JSON.parse(e.target.result);
          const filename = file.name.replace('.json', '');

          this.saves.set(filename, saveData);
          localStorage.setItem(
            `gameio_save_${filename}`,
            JSON.stringify(saveData)
          );

          resolve(saveData);
        } catch (err) {
          reject(err);
        }
      };

      reader.readAsText(file);
    });
  }

  // Get save statistics
  getStatistics() {
    const saves = this.listSaves();
    const totalSize = saves.reduce((sum, s) => sum + (s.size || 0), 0);

    return {
      totalSaves: saves.length,
      totalSize: (totalSize / 1024).toFixed(2) + ' KB',
      totalBackups: this.backups.length,
      backupSize: this.backups.reduce((sum, b) => sum + b.size, 0),
      oldestSave: saves.length > 0 ? saves[saves.length - 1].timestamp : null,
      newestSave: saves.length > 0 ? saves[0].timestamp : null
    };
  }

  // Validate save file
  validateSave(filename) {
    const saveData = this.load(filename);

    if (!saveData) {
      return { valid: false, reason: 'File not found' };
    }

    if (!saveData.version) {
      return { valid: false, reason: 'Missing version' };
    }

    if (!saveData.data) {
      return { valid: false, reason: 'Missing data' };
    }

    if (!saveData.metadata) {
      return { valid: false, reason: 'Missing metadata' };
    }

    return { valid: true, data: saveData };
  }

  // Compress save data
  compressSave(filename) {
    const saveData = this.load(filename);

    if (!saveData) {
      return false;
    }

    // Simple compression: remove unnecessary data
    const compressed = {
      ...saveData,
      data: this._compressObject(saveData.data)
    };

    const storageKey = `gameio_save_${filename}`;
    localStorage.setItem(storageKey, JSON.stringify(compressed));

    return true;
  }

  // Private methods

  _startAutoBackup() {
    setInterval(() => {
      if (window.GameState) {
        const state = window.GameState.currentState || {};
        this.createBackup(state, 'Auto-backup');
      }
    }, this.backupInterval);
  }

  _generateHash(data) {
    const str = JSON.stringify(data);
    let hash = 0;

    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }

    return Math.abs(hash).toString(16);
  }

  _verifyHash(data, hash) {
    return this._generateHash(data) === hash;
  }

  _encryptData(data) {
    // Simple XOR encryption (not cryptographically secure, for demo only)
    const str = JSON.stringify(data);
    const key = 'gameio_secret_key';
    let encrypted = '';

    for (let i = 0; i < str.length; i++) {
      encrypted += String.fromCharCode(
        str.charCodeAt(i) ^ key.charCodeAt(i % key.length)
      );
    }

    return btoa(encrypted);
  }

  _decryptData(encrypted) {
    const str = atob(encrypted);
    const key = 'gameio_secret_key';
    let decrypted = '';

    for (let i = 0; i < str.length; i++) {
      decrypted += String.fromCharCode(
        str.charCodeAt(i) ^ key.charCodeAt(i % key.length)
      );
    }

    return JSON.parse(decrypted);
  }

  _compressObject(obj) {
    if (typeof obj !== 'object' || obj === null) {
      return obj;
    }

    if (Array.isArray(obj)) {
      return obj.map(item => this._compressObject(item));
    }

    const compressed = {};

    for (const [key, value] of Object.entries(obj)) {
      if (value !== null && value !== undefined && value !== '') {
        compressed[key] = this._compressObject(value);
      }
    }

    return compressed;
  }
}

// Global instance
window.SaveLoad = new SaveLoadSystem();

export { SaveLoadSystem };
