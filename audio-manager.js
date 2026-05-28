// Advanced Audio Management System
// Sound effects, music, spatial audio, and audio analytics

class AudioManager {
  constructor() {
    this.audioContext = null;
    this.masterGain = null;
    this.musicGain = null;
    this.sfxGain = null;
    this.sounds = new Map();
    this.musicTracks = new Map();
    this.currentMusic = null;
    this.soundInstances = [];
    this.isEnabled = true;
    this.isMuted = false;
    this.volumes = {
      master: 1,
      music: 0.7,
      sfx: 0.8,
      ambiance: 0.6
    };
    this.audioSprites = new Map();
    this.playlist = [];
    this.playlistIndex = 0;

    this._initAudioContext();
  }

  // Initialize Web Audio API
  _initAudioContext() {
    if (this.audioContext) return;

    try {
      window.AudioContext = window.AudioContext || window.webkitAudioContext;
      this.audioContext = new window.AudioContext();

      // Create gain nodes
      this.masterGain = this.audioContext.createGain();
      this.masterGain.connect(this.audioContext.destination);
      this.masterGain.gain.value = this.volumes.master;

      this.musicGain = this.audioContext.createGain();
      this.musicGain.connect(this.masterGain);
      this.musicGain.gain.value = this.volumes.music;

      this.sfxGain = this.audioContext.createGain();
      this.sfxGain.connect(this.masterGain);
      this.sfxGain.gain.value = this.volumes.sfx;

      // Resume audio context on user interaction
      document.addEventListener('click', () => {
        if (this.audioContext?.state === 'suspended') {
          this.audioContext.resume();
        }
      });
    } catch (e) {
      console.warn('[AudioManager] Web Audio API not supported');
    }
  }

  // Load sound from URL
  async loadSound(name, url) {
    try {
      const response = await fetch(url);
      const arrayBuffer = await response.arrayBuffer();
      const audioBuffer = await this.audioContext.decodeAudioData(arrayBuffer);

      this.sounds.set(name, {
        name,
        buffer: audioBuffer,
        url,
        duration: audioBuffer.duration,
        volume: this.volumes.sfx
      });

      return true;
    } catch (e) {
      console.error(`[AudioManager] Failed to load sound: ${name}`, e);
      return false;
    }
  }

  // Load music track
  async loadMusic(name, url) {
    try {
      const response = await fetch(url);
      const arrayBuffer = await response.arrayBuffer();
      const audioBuffer = await this.audioContext.decodeAudioData(arrayBuffer);

      this.musicTracks.set(name, {
        name,
        buffer: audioBuffer,
        url,
        duration: audioBuffer.duration,
        volume: this.volumes.music
      });

      return true;
    } catch (e) {
      console.error(`[AudioManager] Failed to load music: ${name}`, e);
      return false;
    }
  }

  // Play sound effect
  playSound(name, options = {}) {
    const sound = this.sounds.get(name);

    if (!sound || !this.audioContext) {
      console.warn(`[AudioManager] Sound not found: ${name}`);
      return null;
    }

    const {
      volume = sound.volume,
      rate = 1,
      loop = false,
      delay = 0,
      pan = 0,
      spatial = false
    } = options;

    const source = this.audioContext.createBufferSource();
    const gainNode = this.audioContext.createGain();
    const panNode = this.audioContext.createStereoPanner();

    source.buffer = sound.buffer;
    source.playbackRate.value = rate;
    source.loop = loop;

    gainNode.gain.value = volume;
    panNode.pan.value = Math.max(-1, Math.min(1, pan));

    if (spatial) {
      const panner = this.audioContext.createPanner();
      source.connect(panner);
      panner.connect(gainNode);
    } else {
      source.connect(gainNode);
    }

    gainNode.connect(panNode);
    panNode.connect(this.sfxGain);

    const startTime = this.audioContext.currentTime + delay;
    source.start(startTime);

    const instance = {
      name,
      source,
      gainNode,
      panNode,
      startTime,
      volume,
      rate,
      duration: sound.buffer.duration / rate
    };

    this.soundInstances.push(instance);

    // Remove from instances when finished
    source.onended = () => {
      const index = this.soundInstances.indexOf(instance);
      if (index !== -1) {
        this.soundInstances.splice(index, 1);
      }
    };

    return instance;
  }

  // Play music
  playMusic(name, options = {}) {
    const music = this.musicTracks.get(name);

    if (!music || !this.audioContext) {
      console.warn(`[AudioManager] Music not found: ${name}`);
      return null;
    }

    const { fadeIn = 0, loop = true, volume = this.volumes.music } = options;

    // Stop current music if playing
    if (this.currentMusic) {
      this.stopMusic(fadeIn);
    }

    const source = this.audioContext.createBufferSource();
    const gainNode = this.audioContext.createGain();

    source.buffer = music.buffer;
    source.loop = loop;

    gainNode.gain.value = fadeIn ? 0 : volume;
    gainNode.connect(this.musicGain);
    source.connect(gainNode);

    source.start(0);

    if (fadeIn) {
      const startTime = this.audioContext.currentTime;
      const endTime = startTime + fadeIn / 1000;
      gainNode.gain.linearRampToValueAtTime(volume, endTime);
    }

    this.currentMusic = {
      name,
      source,
      gainNode,
      volume,
      duration: music.buffer.duration
    };

    return this.currentMusic;
  }

  // Stop music with fade out
  stopMusic(fadeOut = 0) {
    if (!this.currentMusic) return;

    const gainNode = this.currentMusic.gainNode;
    const source = this.currentMusic.source;

    if (fadeOut > 0) {
      const startTime = this.audioContext.currentTime;
      const endTime = startTime + fadeOut / 1000;
      gainNode.gain.linearRampToValueAtTime(0, endTime);

      setTimeout(() => {
        source.stop();
        this.currentMusic = null;
      }, fadeOut);
    } else {
      source.stop();
      this.currentMusic = null;
    }
  }

  // Set volume
  setVolume(category, volume) {
    volume = Math.max(0, Math.min(1, volume));
    this.volumes[category] = volume;

    if (category === 'master' && this.masterGain) {
      this.masterGain.gain.value = volume;
    } else if (category === 'music' && this.musicGain) {
      this.musicGain.gain.value = volume;
    } else if (category === 'sfx' && this.sfxGain) {
      this.sfxGain.gain.value = volume;
    }
  }

  // Get volume
  getVolume(category) {
    return this.volumes[category] || 0;
  }

  // Mute/unmute
  setMuted(muted) {
    this.isMuted = muted;

    if (this.masterGain) {
      this.masterGain.gain.value = muted ? 0 : this.volumes.master;
    }
  }

  // Fade in
  fadeIn(instance, duration = 1000) {
    if (!instance || !instance.gainNode) return;

    const startTime = this.audioContext.currentTime;
    const endTime = startTime + duration / 1000;

    instance.gainNode.gain.setValueAtTime(0, startTime);
    instance.gainNode.gain.linearRampToValueAtTime(instance.volume, endTime);
  }

  // Fade out
  fadeOut(instance, duration = 1000) {
    if (!instance || !instance.gainNode) return;

    const startTime = this.audioContext.currentTime;
    const endTime = startTime + duration / 1000;

    instance.gainNode.gain.setValueAtTime(instance.gainNode.gain.value, startTime);
    instance.gainNode.gain.linearRampToValueAtTime(0, endTime);

    setTimeout(() => {
      instance.source?.stop?.();
    }, duration);
  }

  // Create audio sprite (multiple sounds in one file)
  createSprite(name, audioBuffer, spritePoints = []) {
    const sprite = {
      name,
      buffer: audioBuffer,
      sprites: spritePoints // [ { name: 'hit', start: 0, duration: 0.5 } ]
    };

    this.audioSprites.set(name, sprite);
    return sprite;
  }

  // Play sprite from audio file
  playSprite(spriteName, spriteKey, options = {}) {
    const sprite = this.audioSprites.get(spriteName);

    if (!sprite) {
      console.warn(`[AudioManager] Sprite not found: ${spriteName}`);
      return null;
    }

    const spriteData = sprite.sprites.find(s => s.name === spriteKey);

    if (!spriteData) {
      console.warn(`[AudioManager] Sprite key not found: ${spriteKey}`);
      return null;
    }

    const source = this.audioContext.createBufferSource();
    const gainNode = this.audioContext.createGain();

    source.buffer = sprite.buffer;
    gainNode.connect(this.sfxGain);
    source.connect(gainNode);

    gainNode.gain.value = options.volume || this.volumes.sfx;

    source.start(this.audioContext.currentTime, spriteData.start, spriteData.duration);

    return {
      source,
      gainNode,
      duration: spriteData.duration
    };
  }

  // Create playlist
  createPlaylist(tracks) {
    this.playlist = tracks;
    this.playlistIndex = 0;
  }

  // Play next in playlist
  playNextInPlaylist(options = {}) {
    if (this.playlist.length === 0) return null;

    const track = this.playlist[this.playlistIndex];
    this.playlistIndex = (this.playlistIndex + 1) % this.playlist.length;

    return this.playMusic(track, options);
  }

  // Stop all sounds
  stopAllSounds() {
    this.soundInstances.forEach(instance => {
      instance.source?.stop?.();
    });
    this.soundInstances = [];
  }

  // Get audio analytics
  getAnalytics() {
    return {
      activeSounds: this.soundInstances.length,
      currentMusic: this.currentMusic?.name || null,
      volume: this.volumes,
      isMuted: this.isMuted,
      audioContextState: this.audioContext?.state || 'unavailable',
      loadedSounds: this.sounds.size,
      loadedTracks: this.musicTracks.size
    };
  }

  // Create visualizer data
  getVisualizerData() {
    if (!this.audioContext) return null;

    const analyser = this.audioContext.createAnalyser();
    this.masterGain.connect(analyser);

    const dataArray = new Uint8Array(analyser.frequencyBinCount);
    analyser.getByteFrequencyData(dataArray);

    return {
      frequencies: Array.from(dataArray),
      average: dataArray.reduce((a, b) => a + b, 0) / dataArray.length,
      peak: Math.max(...dataArray)
    };
  }

  // Enable/disable audio
  setEnabled(enabled) {
    this.isEnabled = enabled;

    if (!enabled) {
      this.stopAllSounds();
      this.stopMusic();
    }
  }

  // Get available sounds
  getAvailableSounds() {
    return Array.from(this.sounds.keys());
  }

  // Get available tracks
  getAvailableTracks() {
    return Array.from(this.musicTracks.keys());
  }

  // Preload audio for performance
  async preloadAudio(names, type = 'sound') {
    const promises = names.map(name => {
      if (type === 'sound') {
        return this.loadSound(name, `/assets/sounds/${name}.mp3`);
      } else {
        return this.loadMusic(name, `/assets/music/${name}.mp3`);
      }
    });

    return Promise.all(promises);
  }
}

// Global audio manager instance
window.AudioManager = new AudioManager();

// Helper functions
window.audio = {
  play: (name, options) => window.AudioManager.playSound(name, options),
  music: (name, options) => window.AudioManager.playMusic(name, options),
  stopMusic: (fadeOut) => window.AudioManager.stopMusic(fadeOut),
  setVolume: (cat, vol) => window.AudioManager.setVolume(cat, vol),
  mute: (muted) => window.AudioManager.setMuted(muted),
  analytics: () => window.AudioManager.getAnalytics(),
  sounds: () => window.AudioManager.getAvailableSounds(),
  tracks: () => window.AudioManager.getAvailableTracks()
};

export { AudioManager };
