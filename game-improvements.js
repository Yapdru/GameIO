// Game improvements and enhancements

export class GameStatePersistence {
  constructor(storageKey = 'gameioGameState') {
    this.storageKey = storageKey;
  }

  saveGameState(gameKey, state) {
    const data = {
      game: gameKey,
      state: state,
      timestamp: Date.now()
    };
    localStorage.setItem(this.storageKey, JSON.stringify(data));
  }

  loadGameState(gameKey) {
    const stored = localStorage.getItem(this.storageKey);
    if (!stored) return null;

    try {
      const data = JSON.parse(stored);
      if (data.game === gameKey) {
        // Only return if saved within last hour
        if (Date.now() - data.timestamp < 3600000) {
          return data.state;
        }
      }
    } catch (e) {
      console.error('Failed to load game state:', e);
    }

    return null;
  }

  clearGameState() {
    localStorage.removeItem(this.storageKey);
  }

  hasUnfinishedGame(gameKey) {
    const state = this.loadGameState(gameKey);
    return state !== null;
  }
}

export class QuestionBank {
  constructor() {
    this.questions = {
      general: [
        { q: 'What color is the sky?', a: ['Blue', 'Green', 'Red', 'Yellow'], c: 0 },
        { q: 'What is the capital of France?', a: ['London', 'Berlin', 'Paris', 'Madrid'], c: 2 },
        { q: 'What is the largest ocean?', a: ['Atlantic', 'Indian', 'Pacific', 'Arctic'], c: 2 },
        { q: 'Which country has the largest population?', a: ['India', 'USA', 'China', 'Indonesia'], c: 2 },
        { q: 'What is the smallest country in the world?', a: ['Monaco', 'Liechtenstein', 'Vatican City', 'Malta'], c: 2 },
        { q: 'Which continent is the largest?', a: ['Africa', 'Asia', 'Europe', 'North America'], c: 1 },
        { q: 'What is the deepest ocean trench?', a: ['Mariana Trench', 'Tonga Trench', 'Kuril Trench', 'Kermadec Trench'], c: 0 },
        { q: 'How many countries are in the EU?', a: ['25', '27', '29', '31'], c: 1 },
        { q: 'What is the oldest university in the world?', a: ['Oxford', 'Cambridge', 'Al-Azhar', 'Harvard'], c: 2 },
        { q: 'Which mountain is the tallest?', a: ['K2', 'Mount Everest', 'Kangchenjunga', 'Lhotse'], c: 1 }
      ],

      math: [
        { q: 'What is 2 + 2?', a: ['3', '4', '5', '6'], c: 1 },
        { q: 'What is 10 × 5?', a: ['40', '50', '60', '70'], c: 1 },
        { q: 'What is 100 ÷ 4?', a: ['20', '25', '30', '35'], c: 1 },
        { q: 'What is 7²?', a: ['42', '49', '56', '63'], c: 1 },
        { q: 'What is √144?', a: ['10', '11', '12', '13'], c: 2 },
        { q: 'What is 15% of 200?', a: ['20', '25', '30', '35'], c: 2 },
        { q: 'What is the sum of angles in a triangle?', a: ['90°', '180°', '270°', '360°'], c: 1 },
        { q: 'What is π rounded to 2 decimals?', a: ['3.12', '3.14', '3.16', '3.18'], c: 1 },
        { q: 'How many prime numbers are under 20?', a: ['7', '8', '9', '10'], c: 1 },
        { q: 'What is 2⁵?', a: ['16', '32', '64', '128'], c: 1 }
      ],

      science: [
        { q: 'Which planet is closest to the sun?', a: ['Venus', 'Mercury', 'Earth', 'Mars'], c: 1 },
        { q: 'Which element is most abundant in the universe?', a: ['Oxygen', 'Hydrogen', 'Carbon', 'Nitrogen'], c: 1 },
        { q: 'How many sides does a triangle have?', a: ['2', '3', '4', '5'], c: 1 },
        { q: 'What does DNA stand for?', a: ['Deoxyribose Nucleic Acid', 'Deoxyribonucleic Acid', 'Dynamic Nuclear Acid', 'Deoxyribose Nuclear Acid'], c: 1 },
        { q: 'What is the chemical symbol for gold?', a: ['Go', 'Gd', 'Au', 'Ag'], c: 2 },
        { q: 'What is the speed of light?', a: ['100,000 km/s', '200,000 km/s', '300,000 km/s', '400,000 km/s'], c: 2 },
        { q: 'How many bones are in the human body?', a: ['186', '206', '226', '246'], c: 1 },
        { q: 'What is the boiling point of water?', a: ['80°C', '90°C', '100°C', '110°C'], c: 2 },
        { q: 'Which gas do plants use for photosynthesis?', a: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'], c: 2 },
        { q: 'What is the basic unit of life?', a: ['Atom', 'Molecule', 'Cell', 'Organelle'], c: 2 }
      ],

      history: [
        { q: 'What year did the Titanic sink?', a: ['1912', '1913', '1914', '1915'], c: 0 },
        { q: 'Who was the first president of the USA?', a: ['Thomas Jefferson', 'George Washington', 'John Adams', 'Benjamin Franklin'], c: 1 },
        { q: 'In what year did WWII end?', a: ['1943', '1944', '1945', '1946'], c: 2 },
        { q: 'Who invented the light bulb?', a: ['Nikola Tesla', 'Thomas Edison', 'Alexander Graham Bell', 'Louis Pasteur'], c: 1 },
        { q: 'What year was the Declaration of Independence signed?', a: ['1774', '1775', '1776', '1777'], c: 2 },
        { q: 'Who wrote the Declaration of Independence?', a: ['Benjamin Franklin', 'John Adams', 'Thomas Jefferson', 'James Madison'], c: 2 },
        { q: 'In what year did the Berlin Wall fall?', a: ['1988', '1989', '1990', '1991'], c: 1 },
        { q: 'Who was the first emperor of Rome?', a: ['Julius Caesar', 'Augustus', 'Nero', 'Tiberius'], c: 1 },
        { q: 'What year was the Magna Carta signed?', a: ['1215', '1315', '1415', '1515'], c: 0 },
        { q: 'Who discovered America?', a: ['Leif Erikson', 'Christopher Columbus', 'John Cabot', 'Ferdinand Magellan'], c: 1 }
      ]
    };
  }

  getQuestions(category, count = 10) {
    const questions = this.questions[category] || this.questions.general;
    return this.shuffleArray(questions).slice(0, count).map(q => ({
      q: q.q,
      a: this.shuffleArray([...q.a]),
      correct: this.findCorrectIndex(this.shuffleArray([...q.a]), q.a[q.c])
    }));
  }

  shuffleArray(array) {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }

  findCorrectIndex(shuffledArray, correctAnswer) {
    return shuffledArray.findIndex(a => a === correctAnswer);
  }
}

export class InputValidator {
  static validateRoomCode(code) {
    if (!code) return { valid: false, error: 'Room code is required' };
    if (code.length !== 6) return { valid: false, error: 'Room code must be 6 characters' };
    if (!/^[A-Z0-9]{6}$/.test(code)) return { valid: false, error: 'Room code must be alphanumeric' };
    return { valid: true };
  }

  static validatePlayerName(name) {
    if (!name) return { valid: false, error: 'Player name is required' };
    if (name.length < 2) return { valid: false, error: 'Player name must be at least 2 characters' };
    if (name.length > 20) return { valid: false, error: 'Player name must be less than 20 characters' };
    if (!/^[a-zA-Z0-9\s]+$/.test(name)) return { valid: false, error: 'Player name can only contain letters, numbers, and spaces' };
    return { valid: true };
  }

  static sanitizeInput(input) {
    return input.replace(/[<>\"'&]/g, '').trim();
  }

  static validateScore(score) {
    return typeof score === 'number' && score >= 0 && isFinite(score);
  }
}

export class GameReplay {
  constructor() {
    this.recordings = {};
  }

  startRecording(gameKey) {
    this.recordings[gameKey] = {
      game: gameKey,
      startTime: Date.now(),
      events: [],
      score: 0
    };
  }

  recordEvent(gameKey, eventType, data) {
    if (!this.recordings[gameKey]) return;

    this.recordings[gameKey].events.push({
      type: eventType,
      data: data,
      timestamp: Date.now() - this.recordings[gameKey].startTime
    });
  }

  finishRecording(gameKey, finalScore) {
    if (!this.recordings[gameKey]) return null;

    this.recordings[gameKey].score = finalScore;
    this.recordings[gameKey].duration = Date.now() - this.recordings[gameKey].startTime;

    return this.recordings[gameKey];
  }

  saveRecording(gameKey, filename) {
    const recording = this.recordings[gameKey];
    if (!recording) return false;

    const json = JSON.stringify(recording);
    const blob = new Blob([json], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename || `${gameKey}-${Date.now()}.json`;
    link.click();
    URL.revokeObjectURL(url);

    return true;
  }

  getRecordingStats(gameKey) {
    const recording = this.recordings[gameKey];
    if (!recording) return null;

    return {
      game: recording.game,
      score: recording.score,
      duration: recording.duration,
      eventCount: recording.events.length,
      durationSeconds: Math.round(recording.duration / 1000)
    };
  }
}

export class GameTutorial {
  constructor() {
    this.tutorialSteps = {
      fishana: [
        { text: 'Move with ARROW KEYS or WASD', delay: 0 },
        { text: 'Eat pearls (white dots) to grow', delay: 3000 },
        { text: 'Avoid the red fish!', delay: 6000 },
        { text: 'Collect 15 pearls to evolve to the next level', delay: 9000 }
      ],
      cars: [
        { text: 'Steer with ARROW KEYS or WASD', delay: 0 },
        { text: 'Press SPACE to boost', delay: 3000 },
        { text: 'Drift around corners for bonus points', delay: 6000 },
        { text: 'Complete laps before time runs out', delay: 9000 }
      ],
      obby: [
        { text: 'Jump with SPACE or W/UP ARROW', delay: 0 },
        { text: 'Move with ARROW KEYS or WASD', delay: 3000 },
        { text: 'Reach each checkpoint to progress', delay: 6000 },
        { text: 'Don\'t fall off the platforms!', delay: 9000 }
      ],
      space: [
        { text: 'Move with ARROW KEYS or WASD', delay: 0 },
        { text: 'Avoid the asteroids', delay: 3000 },
        { text: 'Collect stars for points', delay: 6000 },
        { text: 'Survive as long as possible', delay: 9000 }
      ]
    };
  }

  showTutorial(gameKey, onComplete) {
    const steps = this.tutorialSteps[gameKey];
    if (!steps) {
      if (onComplete) onComplete();
      return;
    }

    const overlay = document.createElement('div');
    overlay.style.cssText = `
      position: fixed;
      inset: 0;
      background: rgba(0,0,0,0.7);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 500;
    `;

    const message = document.createElement('div');
    message.style.cssText = `
      background: white;
      padding: 20px 30px;
      border-radius: 12px;
      font-size: 18px;
      font-weight: bold;
      text-align: center;
      max-width: 500px;
    `;

    let stepIndex = 0;

    const showStep = () => {
      if (stepIndex >= steps.length) {
        overlay.remove();
        if (onComplete) onComplete();
        return;
      }

      const step = steps[stepIndex];
      message.textContent = step.text;

      setTimeout(() => {
        stepIndex++;
        showStep();
      }, step.delay + 2000);
    };

    overlay.appendChild(message);
    document.body.appendChild(overlay);
    showStep();
  }
}

export const gameStatePersistence = new GameStatePersistence();
export const questionBank = new QuestionBank();
export const gameReplay = new GameReplay();
export const gameTutorial = new GameTutorial();
