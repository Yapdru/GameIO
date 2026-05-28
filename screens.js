// Screen management system

import { gameState } from './state.js';

const screenRegistry = new Map();

class ScreenManager {
  constructor(root) {
    this.root = root;
    this.currentScreen = null;
  }

  register(name, screenClass) {
    screenRegistry.set(name, screenClass);
  }

  async show(name) {
    // Hide current screen
    if (this.currentScreen) {
      if (this.currentScreen.onHide) {
        await this.currentScreen.onHide();
      }
      this.currentScreen.element.remove();
    }

    // Create and show new screen
    const ScreenClass = screenRegistry.get(name);
    if (!ScreenClass) {
      throw new Error(`Screen not registered: ${name}`);
    }

    this.currentScreen = new ScreenClass();
    this.currentScreen.element.classList.add('screen', 'active');
    this.root.appendChild(this.currentScreen.element);

    gameState.setScreen(name);

    if (this.currentScreen.onShow) {
      await this.currentScreen.onShow();
    }
  }
}

// Base screen class
export class Screen {
  constructor() {
    this.element = document.createElement('div');
  }

  createElement(tag, classes = '', html = '') {
    const el = document.createElement(tag);
    if (classes) el.className = classes;
    if (html) el.innerHTML = html;
    return el;
  }

  onShow() {} // Override in subclass
  onHide() {} // Override in subclass
}

// Export singleton
export const screenManager = new ScreenManager(document.getElementById('root'));
