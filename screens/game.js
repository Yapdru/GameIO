// Game screen - loads and plays current game

import { Screen, screenManager } from '../screens.js';
import { gameState } from '../state.js';
import { firebase } from '../firebase.js';
import { GAMES } from '../config.js';
import { audioSystem } from '../audio-system.js';
import { FishanaGame } from '../games/fishana.js';
import { CarsGame } from '../games/cars.js';
import { BadaamGame } from '../games/badaam.js';
import { SpaceGame } from '../games/space.js';
import { ObbyGame } from '../games/obby.js';
import { QuizGame } from '../games/quiz.js';
import { MathDashGame } from '../games/mathdash.js';

// Game descriptions for instruction screens
const GAME_EXPLANATIONS = {
  fishana: {
    title: '🐟 Fishana Evolution',
    rules: [
      'Swim around and collect pearls',
      'Avoid the enemy fish',
      'Collect enough pearls to evolve',
      'Higher levels = more points'
    ]
  },
  cars: {
    title: '🏎️ Cars Horizon',
    rules: [
      'Drive smoothly around the track',
      'Use ARROW KEYS or WASD to steer',
      'Drift around corners for bonus points',
      'Complete laps before time runs out'
    ]
  },
  badaam: {
    title: '🃏 Badaam Saat',
    rules: [
      '7s are always playable',
      'Match suit or rank to play',
      'Score points from card values',
      'Play or Pass - strategic choices'
    ]
  },
  space: {
    title: '🚀 Space Dash',
    rules: [
      'Navigate through the asteroid field',
      'Avoid obstacles',
      'Collect stars for bonus points',
      'Survive as long as possible'
    ]
  },
  obby: {
    title: '🧗 Sky Obby',
    rules: [
      'Jump across platforms',
      'Reach checkpoints to progress',
      'Avoid falling off the edges',
      'Reach the top to win'
    ]
  },
  quiz: {
    title: '🧠 Quiz Master',
    rules: [
      'Answer multiple choice questions',
      'Each correct answer = 10 points',
      'Answer quickly for bonus time',
      'Beat the 60-second challenge'
    ]
  },
  mathdash: {
    title: '🔢 Math Dash',
    rules: [
      'Solve math problems quickly',
      'Each correct answer = 10 points',
      'Problems get harder as you go',
      'Accuracy matters more than speed'
    ]
  }
};

export class GameScreen extends Screen {
  constructor() {
    super();
    this.element.className = 'screen';
    this.game = null;
    this.syncInterval = null;
    this.gameStarted = false;
  }

  build() {
    this.element.innerHTML = '';
    this.element.style.display = 'flex';
    this.element.style.flexDirection = 'column';
    this.element.style.background = '#000';

    // HUD
    const hud = this.createElement('div', 'flex justify-between items-center', '');
    hud.style.background = '#1a1a1a';
    hud.style.color = 'white';
    hud.style.padding = '12px 20px';
    hud.style.borderBottom = '2px solid #0f8fe8';
    hud.style.fontSize = '14px';

    const gameInfo = this.createElement('div', 'flex gap-4 items-center', '');

    const gameTitle = this.createElement('span', '', gameState.currentGame.toUpperCase());
    gameTitle.style.fontWeight = 'bold';
    gameTitle.style.fontSize = '16px';

    const playerCount = this.createElement('span', '', `Players: ${gameState.players.length}`);
    gameInfo.appendChild(gameTitle);
    gameInfo.appendChild(playerCount);

    const scoreDisplay = this.createElement('div', '', '');
    scoreDisplay.style.fontSize = '16px';
    scoreDisplay.id = 'scoreDisplay';
    scoreDisplay.style.fontWeight = 'bold';

    const controls = this.createElement('div', 'flex gap-2', '');

    const backBtn = this.createElement('button', 'secondary', '← Back to Lobby');
    backBtn.style.fontSize = '12px';
    backBtn.style.padding = '6px 12px';
    backBtn.onclick = () => this.backToLobby();

    controls.appendChild(backBtn);

    hud.appendChild(gameInfo);
    hud.appendChild(scoreDisplay);
    hud.appendChild(controls);

    // Canvas container
    const canvasContainer = this.createElement('div', '', '');
    canvasContainer.style.flex = '1';
    canvasContainer.style.position = 'relative';

    const canvas = this.createElement('canvas');
    canvas.id = 'gameCanvas';
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight - 60; // Account for HUD

    canvasContainer.appendChild(canvas);

    this.element.appendChild(hud);
    this.element.appendChild(canvasContainer);

    // Load game based on currentGame
    this.loadGame(canvas);
  }

  loadGame(canvas) {
    const gameKey = gameState.currentGame;

    if (gameKey === 'fishana') {
      this.game = new FishanaGame(canvas);
      this.game.start();
    } else if (gameKey === 'cars') {
      this.game = new CarsGame(canvas);
      this.game.start();
    } else if (gameKey === 'badaam') {
      this.game = new BadaamGame();
      this.renderBadaam(canvas);
    } else if (gameKey === 'space') {
      this.game = new SpaceGame(canvas);
      this.game.start();
    } else if (gameKey === 'obby') {
      this.game = new ObbyGame(canvas);
      this.game.start();
    } else if (gameKey === 'quiz') {
      this.game = new QuizGame();
      this.renderQuiz(canvas);
    } else if (gameKey === 'mathdash') {
      this.game = new MathDashGame();
      this.renderMathDash(canvas);
    } else {
      // Placeholder for other games
      this.game = {
        getScore: () => Math.random() * 100,
        stop: () => {}
      };
      const ctx = canvas.getContext('2d');
      ctx.fillStyle = '#333';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = 'white';
      ctx.font = '32px system-ui';
      ctx.fillText(`${gameKey} coming soon`, canvas.width / 2 - 100, canvas.height / 2);
    }
  }

  renderBadaam(canvas) {
    const container = canvas.parentElement;
    container.innerHTML = '';

    const gameUI = this.createElement('div', 'flex flex-col gap-4', '');
    gameUI.style.padding = '20px';
    gameUI.style.flex = '1';
    gameUI.style.overflowY = 'auto';

    // Table cards
    const tableLabel = this.createElement('h3', '', 'Table Cards');
    const tableCards = this.createElement('div', 'flex gap-2 flex-wrap', '');
    this.game.table.forEach(card => {
      const cardEl = this.createElement('button', 'card', `${card.rank}${card.suit}`);
      cardEl.style.flex = '0 0 60px';
      cardEl.style.height = '80px';
      cardEl.style.fontSize = '18px';
      tableCards.appendChild(cardEl);
    });

    // Your hand
    const handLabel = this.createElement('h3', '', 'Your Hand');
    const hand = this.createElement('div', 'flex gap-2 flex-wrap', '');
    this.game.hand.forEach((card, idx) => {
      const cardEl = this.createElement('button', 'card', `${card.rank}${card.suit}`);
      cardEl.style.flex = '0 0 60px';
      cardEl.style.height = '80px';
      cardEl.style.fontSize = '18px';
      const isValid = this.game.isValidMove(card);
      if (!isValid) {
        cardEl.style.opacity = '0.5';
        cardEl.disabled = true;
      }
      cardEl.onclick = () => {
        if (this.game.playCard(idx)) {
          this.renderBadaam(canvas);
        }
      };
      hand.appendChild(cardEl);
    });

    // Actions
    const actions = this.createElement('div', 'flex gap-2', '');
    const passBtn = this.createElement('button', '', 'Pass Round');
    passBtn.onclick = () => {
      this.game.passRound();
      this.renderBadaam(canvas);
    };

    actions.appendChild(passBtn);

    gameUI.appendChild(tableLabel);
    gameUI.appendChild(tableCards);
    gameUI.appendChild(handLabel);
    gameUI.appendChild(hand);
    gameUI.appendChild(actions);

    container.appendChild(gameUI);
  }

  renderQuiz(canvas) {
    const container = canvas.parentElement;
    container.innerHTML = '';

    const gameUI = this.createElement('div', 'flex flex-col gap-4', '');
    gameUI.style.padding = '20px';
    gameUI.style.flex = '1';
    gameUI.style.overflowY = 'auto';
    gameUI.style.display = 'flex';
    gameUI.style.flexDirection = 'column';
    gameUI.style.justifyContent = 'center';
    gameUI.style.alignItems = 'center';

    // Progress
    const progress = this.createElement('div', '', `Question ${this.game.getProgress()}`);
    progress.style.fontSize = '16px';
    progress.style.marginBottom = '20px';

    // Timer
    const timeRemaining = Math.ceil(this.game.getTimeRemaining());
    const timer = this.createElement('div', '', `Time: ${timeRemaining}s`);
    timer.style.fontSize = '18px';
    timer.style.color = timeRemaining < 5 ? '#ff6b6b' : 'white';
    timer.style.marginBottom = '20px';

    // Question
    const question = this.game.getCurrentQuestion();
    const qEl = this.createElement('h2', '', question.q);
    qEl.style.textAlign = 'center';
    qEl.style.marginBottom = '40px';
    qEl.style.fontSize = '28px';

    // Answers
    const answers = this.createElement('div', 'flex flex-col gap-3', '');
    answers.style.maxWidth = '500px';
    question.a.forEach((answer, idx) => {
      const answerBtn = this.createElement('button', 'primary', answer);
      answerBtn.style.padding = '15px 20px';
      answerBtn.style.fontSize = '18px';
      answerBtn.style.width = '100%';
      answerBtn.onclick = () => {
        this.game.answerQuestion(idx);
        setTimeout(() => {
          if (this.game.isRunning) {
            this.renderQuiz(canvas);
          }
        }, 1000);
      };
      answers.appendChild(answerBtn);
    });

    gameUI.appendChild(progress);
    gameUI.appendChild(timer);
    gameUI.appendChild(qEl);
    gameUI.appendChild(answers);

    container.appendChild(gameUI);
  }

  renderMathDash(canvas) {
    const container = canvas.parentElement;
    container.innerHTML = '';

    const gameUI = this.createElement('div', 'flex flex-col gap-4', '');
    gameUI.style.padding = '20px';
    gameUI.style.flex = '1';
    gameUI.style.overflowY = 'auto';
    gameUI.style.display = 'flex';
    gameUI.style.flexDirection = 'column';
    gameUI.style.justifyContent = 'center';
    gameUI.style.alignItems = 'center';

    // Progress
    const progress = this.createElement('div', '', `Problem ${this.game.getProgress()}`);
    progress.style.fontSize = '16px';
    progress.style.marginBottom = '20px';

    // Timer
    const timeRemaining = Math.ceil(this.game.getTimeRemaining());
    const timer = this.createElement('div', '', `Time: ${timeRemaining}s`);
    timer.style.fontSize = '18px';
    timer.style.color = timeRemaining < 5 ? '#ff6b6b' : 'white';
    timer.style.marginBottom = '20px';

    // Problem
    const problem = this.game.currentProblem;
    const problemEl = this.createElement('h2', '', `${problem.a} ${problem.op} ${problem.b} = ?`);
    problemEl.style.textAlign = 'center';
    problemEl.style.marginBottom = '40px';
    problemEl.style.fontSize = '32px';

    // Answer choices
    const choices = this.createElement('div', 'flex flex-col gap-3', '');
    choices.style.maxWidth = '500px';
    problem.choices.forEach((choice, idx) => {
      const choiceBtn = this.createElement('button', 'primary', choice.toString());
      choiceBtn.style.padding = '15px 20px';
      choiceBtn.style.fontSize = '20px';
      choiceBtn.style.width = '100%';
      choiceBtn.onclick = () => {
        this.game.answerProblem(idx);
        setTimeout(() => {
          if (this.game.isRunning) {
            this.renderMathDash(canvas);
          }
        }, 800);
      };
      choices.appendChild(choiceBtn);
    });

    gameUI.appendChild(progress);
    gameUI.appendChild(timer);
    gameUI.appendChild(problemEl);
    gameUI.appendChild(choices);

    container.appendChild(gameUI);
  }

  showGameInstructions() {
    const modal = this.createElement('div', '', '');
    modal.style.position = 'fixed';
    modal.style.inset = '0';
    modal.style.background = 'rgba(0,0,0,0.95)';
    modal.style.display = 'flex';
    modal.style.flexDirection = 'column';
    modal.style.alignItems = 'center';
    modal.style.justifyContent = 'center';
    modal.style.zIndex = '1000';
    modal.style.gap = '20px';
    modal.style.color = 'white';

    const gameKey = gameState.currentGame;
    const explanation = GAME_EXPLANATIONS[gameKey] || { title: gameKey, rules: [] };

    const title = this.createElement('h1', '', explanation.title);
    title.style.fontSize = '48px';
    title.style.margin = '0 0 20px 0';

    const rules = this.createElement('div', '', '');
    rules.style.fontSize = '20px';
    rules.style.maxWidth = '600px';
    rules.style.lineHeight = '2';
    rules.innerHTML = explanation.rules.map(r => `• ${r}`).join('<br>');

    const startBtn = this.createElement('button', 'primary', 'Start Game');
    startBtn.style.padding = '15px 40px';
    startBtn.style.fontSize = '18px';
    startBtn.style.marginTop = '40px';
    startBtn.onclick = () => {
      modal.remove();
      this.gameStarted = true;
      if (this.game) {
        if (this.game.start && typeof this.game.start === 'function') {
          this.game.start();
        }
      }
      audioSystem.playSFX('menu-click');
    };

    modal.appendChild(title);
    modal.appendChild(rules);
    modal.appendChild(startBtn);

    this.element.appendChild(modal);
  }

  backToLobby() {
    if (this.game) {
      this.game.stop();
    }
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
    }
    screenManager.show('lobby');
  }

  onShow() {
    this.build();

    // Show instructions first
    setTimeout(() => {
      this.showGameInstructions();
    }, 100);

    // Sync score every second (only if game started)
    this.syncInterval = setInterval(() => {
      if (this.gameStarted) {
        this.syncScore();
      }
    }, 1000);

    // Handle window resize
    window.addEventListener('resize', () => this.handleResize());
  }

  onHide() {
    if (this.game) {
      this.game.stop();
    }
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
    }
    window.removeEventListener('resize', () => this.handleResize());
  }

  handleResize() {
    const canvas = document.getElementById('gameCanvas');
    if (canvas) {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight - 60;
    }
  }

  syncScore() {
    if (!this.game) return;

    const score = Math.floor(this.game.getScore());
    const scoreDisplay = document.getElementById('scoreDisplay');
    if (scoreDisplay) {
      scoreDisplay.textContent = `Score: ${score}`;
    }

    // Sync to Firebase if host
    if (gameState.isHost && gameState.roomCode) {
      gameState.addScore(gameState.playerId, score);
      firebase.updateRoom(gameState.roomCode, {
        scores: gameState.scores
      });
    }
  }

  async endGame() {
    if (this.game) {
      this.game.stop();
    }

    const finalScore = Math.floor(this.game?.getScore() || 0);
    gameState.addScore(gameState.playerId, finalScore);

    // Sync final score
    if (gameState.roomCode) {
      await firebase.updateRoom(gameState.roomCode, {
        scores: gameState.scores
      });
    }

    // Show results screen
    screenManager.show('results');
  }
}
