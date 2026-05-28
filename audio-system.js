// Audio system for GameIO
// Handles ambient music and sound effects across the game

export class AudioSystem {
  constructor() {
    this.audioContext = null;
    this.oscillators = {};
    this.gainNodes = {};
    this.masterGain = null;
    this.initialized = false;
    this.soundEnabled = true;

    // Audio settings
    this.audioSettings = {
      masterVolume: 0.5,
      musicVolume: 0.3,
      sfxVolume: 0.7
    };
  }

  initialize() {
    if (this.initialized) return;

    const AudioContext = window.AudioContext || window.webkitAudioContext;
    this.audioContext = new AudioContext();
    this.masterGain = this.audioContext.createGain();
    this.masterGain.gain.value = this.audioSettings.masterVolume;
    this.masterGain.connect(this.audioContext.destination);

    this.initialized = true;
  }

  setVolume(volume) {
    if (!this.initialized) this.initialize();
    this.audioSettings.masterVolume = Math.max(0, Math.min(1, volume));
    this.masterGain.gain.value = this.audioSettings.masterVolume;
  }

  playLobbyAmbience() {
    if (!this.soundEnabled || !this.initialized) return;

    // Stop existing ambience
    this.stopSound('ambience');

    const ctx = this.audioContext;
    const now = ctx.currentTime;

    // Create layered ambient pads using oscillators
    const frequencies = [110, 220, 330]; // A2, A3, E4
    const nodes = [];

    frequencies.forEach((freq, idx) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = 'sine';
      osc.frequency.value = freq;
      gain.gain.setValueAtTime(0.05, now);

      osc.connect(gain);
      gain.connect(this.masterGain);
      nodes.push({ osc, gain });

      osc.start(now);
    });

    this.oscillators['ambience'] = nodes;
  }

  stopSound(name) {
    if (this.oscillators[name]) {
      this.oscillators[name].forEach(({ osc }) => {
        try {
          osc.stop();
        } catch (e) {}
      });
      delete this.oscillators[name];
    }
  }

  playSFX(type) {
    if (!this.soundEnabled || !this.initialized) return;

    const ctx = this.audioContext;
    const now = ctx.currentTime;
    const duration = 0.15;

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    const env = ctx.createGain();

    gain.gain.value = this.audioSettings.sfxVolume;
    env.gain.setValueAtTime(0.3, now);
    env.gain.exponentialRampToValueAtTime(0.01, now + duration);

    osc.connect(gain);
    gain.connect(env);
    env.connect(this.masterGain);

    // Different sounds for different events
    switch (type) {
      case 'portal-enter':
        osc.frequency.setValueAtTime(800, now);
        osc.frequency.exponentialRampToValueAtTime(600, now + duration);
        osc.type = 'sine';
        break;

      case 'score':
        osc.frequency.setValueAtTime(1000, now);
        osc.frequency.exponentialRampToValueAtTime(1200, now + duration);
        osc.type = 'triangle';
        break;

      case 'win':
        osc.frequency.setValueAtTime(1200, now);
        osc.frequency.exponentialRampToValueAtTime(1500, now + duration);
        osc.type = 'sine';
        break;

      case 'lose':
        osc.frequency.setValueAtTime(400, now);
        osc.frequency.exponentialRampToValueAtTime(200, now + duration);
        osc.type = 'sine';
        break;

      case 'collect':
        osc.frequency.setValueAtTime(1200, now);
        osc.frequency.exponentialRampToValueAtTime(1000, now + duration * 0.5);
        osc.type = 'sine';
        break;

      case 'menu-click':
        osc.frequency.setValueAtTime(600, now);
        osc.frequency.exponentialRampToValueAtTime(700, now + duration * 0.3);
        osc.type = 'square';
        break;

      default:
        osc.frequency.setValueAtTime(700, now);
        osc.type = 'sine';
    }

    osc.start(now);
    osc.stop(now + duration);
  }

  playGameStartJingle() {
    if (!this.soundEnabled || !this.initialized) return;

    const ctx = this.audioContext;
    const now = ctx.currentTime;
    const notes = [
      { freq: 523.25, time: 0 },       // C5
      { freq: 659.25, time: 0.15 },    // E5
      { freq: 783.99, time: 0.3 }      // G5
    ];

    notes.forEach(({ freq, time }) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      const env = ctx.createGain();

      gain.gain.value = this.audioSettings.sfxVolume * 0.8;
      env.gain.setValueAtTime(0.3, now + time);
      env.gain.exponentialRampToValueAtTime(0.01, now + time + 0.2);

      osc.frequency.value = freq;
      osc.type = 'sine';

      osc.connect(gain);
      gain.connect(env);
      env.connect(this.masterGain);

      osc.start(now + time);
      osc.stop(now + time + 0.2);
    });
  }

  playGameEndSound(didWin) {
    if (!this.soundEnabled || !this.initialized) return;

    const ctx = this.audioContext;
    const now = ctx.currentTime;

    if (didWin) {
      // Win jingle: ascending notes
      const notes = [600, 800, 1000, 1200];
      notes.forEach((freq, idx) => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        const env = ctx.createGain();

        gain.gain.value = this.audioSettings.sfxVolume;
        env.gain.setValueAtTime(0.2, now + idx * 0.1);
        env.gain.exponentialRampToValueAtTime(0.01, now + idx * 0.1 + 0.15);

        osc.frequency.value = freq;
        osc.type = 'sine';

        osc.connect(gain);
        gain.connect(env);
        env.connect(this.masterGain);

        osc.start(now + idx * 0.1);
        osc.stop(now + idx * 0.1 + 0.15);
      });
    } else {
      // Lose sound: descending tone
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      const env = ctx.createGain();

      gain.gain.value = this.audioSettings.sfxVolume;
      env.gain.setValueAtTime(0.3, now);
      env.gain.exponentialRampToValueAtTime(0.01, now + 0.4);

      osc.frequency.setValueAtTime(800, now);
      osc.frequency.exponentialRampToValueAtTime(300, now + 0.4);
      osc.type = 'sine';

      osc.connect(gain);
      gain.connect(env);
      env.connect(this.masterGain);

      osc.start(now);
      osc.stop(now + 0.4);
    }
  }

  destroy() {
    Object.keys(this.oscillators).forEach(key => {
      this.stopSound(key);
    });

    if (this.audioContext) {
      this.audioContext.close();
    }
  }
}

// Global audio system instance
export const audioSystem = new AudioSystem();
