// Quiz/Riddle - multiple choice Q&A game

import { gameState } from '../state.js';

export class QuizGame {
  constructor() {
    this.questions = [
      {
        q: 'What color is the sky?',
        a: ['Blue', 'Green', 'Red', 'Yellow'],
        correct: 0
      },
      {
        q: 'What is 2 + 2?',
        a: ['3', '4', '5', '6'],
        correct: 1
      },
      {
        q: 'Which planet is closest to the sun?',
        a: ['Venus', 'Mercury', 'Earth', 'Mars'],
        correct: 1
      },
      {
        q: 'What is the capital of France?',
        a: ['London', 'Berlin', 'Paris', 'Madrid'],
        correct: 2
      },
      {
        q: 'How many sides does a triangle have?',
        a: ['2', '3', '4', '5'],
        correct: 1
      },
      {
        q: 'What is the largest ocean?',
        a: ['Atlantic', 'Indian', 'Pacific', 'Arctic'],
        correct: 2
      },
      {
        q: 'What year did the internet become public?',
        a: ['1989', '1991', '1995', '2000'],
        correct: 2
      },
      {
        q: 'Which element is most abundant in the universe?',
        a: ['Oxygen', 'Hydrogen', 'Carbon', 'Nitrogen'],
        correct: 1
      }
    ];

    this.currentQuestionIndex = 0;
    this.score = 0;
    this.timePerQuestion = 15; // seconds
    this.questionStartTime = Date.now();
    this.isRunning = true;
    this.answered = false;
    this.gameTime = 0;
    this.startTime = Date.now();
  }

  getCurrentQuestion() {
    return this.questions[this.currentQuestionIndex];
  }

  getProgress() {
    return `${this.currentQuestionIndex + 1}/${this.questions.length}`;
  }

  getTimeRemaining() {
    const elapsed = (Date.now() - this.questionStartTime) / 1000;
    return Math.max(0, this.timePerQuestion - elapsed);
  }

  answerQuestion(answerIndex) {
    if (this.answered) return;

    const question = this.getCurrentQuestion();
    this.answered = true;

    const timeUsed = (Date.now() - this.questionStartTime) / 1000;
    let points = 0;

    if (answerIndex === question.correct) {
      // Correct answer
      const timeBonus = Math.max(0, (this.timePerQuestion - timeUsed) / this.timePerQuestion * 50);
      points = 100 + Math.floor(timeBonus);
    } else {
      // Wrong answer
      points = 0;
    }

    this.score += points;

    // Move to next question after delay
    setTimeout(() => {
      if (this.currentQuestionIndex < this.questions.length - 1) {
        this.currentQuestionIndex++;
        this.questionStartTime = Date.now();
        this.answered = false;
      } else {
        this.isRunning = false;
      }
    }, 1000);
  }

  update() {
    this.gameTime = (Date.now() - this.startTime) / 1000;

    // Auto-move to next question if time runs out
    if (!this.answered && this.getTimeRemaining() <= 0) {
      this.answerQuestion(-1); // Wrong answer
    }
  }

  getScore() {
    return this.score;
  }
}
