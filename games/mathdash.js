// Math Dash - quick mental math game

import { gameState } from '../state.js';

export class MathDashGame {
  constructor() {
    this.score = 0;
    this.difficulty = 1;
    this.currentProblem = null;
    this.problemStartTime = Date.now();
    this.timePerProblem = 20; // seconds
    this.answered = false;
    this.correctAnswers = 0;
    this.wrongAnswers = 0;
    this.isRunning = true;
    this.gameTime = 0;
    this.startTime = Date.now();

    this.generateProblem();
  }

  generateProblem() {
    const operations = ['+', '-', '*'];
    const op = operations[Math.floor(Math.random() * operations.length)];

    let a, b, answer;

    if (this.difficulty === 1) {
      // Easy: addition/subtraction up to 20
      a = Math.floor(Math.random() * 20) + 1;
      b = Math.floor(Math.random() * 20) + 1;
    } else if (this.difficulty === 2) {
      // Medium: multiplication/division up to 10
      a = Math.floor(Math.random() * 10) + 1;
      b = Math.floor(Math.random() * 10) + 1;
    } else {
      // Hard: larger numbers
      a = Math.floor(Math.random() * 50) + 10;
      b = Math.floor(Math.random() * 50) + 10;
    }

    if (op === '+') {
      answer = a + b;
    } else if (op === '-') {
      answer = a - b;
    } else {
      answer = a * b;
    }

    // Generate wrong answers
    const wrongAnswers = [
      answer + Math.floor(Math.random() * 10) + 1,
      answer - Math.floor(Math.random() * 10) - 1,
      Math.floor(Math.random() * 100) + 1
    ];

    const allAnswers = [answer, ...wrongAnswers].sort(() => Math.random() - 0.5);

    this.currentProblem = {
      a,
      b,
      op,
      answer,
      choices: allAnswers,
      correctIndex: allAnswers.indexOf(answer)
    };

    this.problemStartTime = Date.now();
    this.answered = false;
  }

  getProgress() {
    return `${this.correctAnswers + this.wrongAnswers}/${this.correctAnswers + this.wrongAnswers + 5}`;
  }

  getTimeRemaining() {
    const elapsed = (Date.now() - this.problemStartTime) / 1000;
    return Math.max(0, this.timePerProblem - elapsed);
  }

  answerProblem(choiceIndex) {
    if (this.answered) return;

    this.answered = true;

    const timeUsed = (Date.now() - this.problemStartTime) / 1000;
    const isCorrect = choiceIndex === this.currentProblem.correctIndex;

    if (isCorrect) {
      this.correctAnswers++;
      const timeBonus = Math.max(0, (this.timePerProblem - timeUsed) / this.timePerProblem * 50);
      const points = 100 + Math.floor(timeBonus);
      this.score += points;

      // Increase difficulty on 3 correct answers
      if (this.correctAnswers % 3 === 0) {
        this.difficulty = Math.min(3, this.difficulty + 1);
      }
    } else {
      this.wrongAnswers++;
      this.score = Math.max(0, this.score - 20);
    }

    // Move to next problem after delay
    setTimeout(() => {
      if (this.correctAnswers + this.wrongAnswers < 15) {
        // 15 total problems
        this.generateProblem();
      } else {
        this.isRunning = false;
      }
    }, 800);
  }

  update() {
    this.gameTime = (Date.now() - this.startTime) / 1000;

    // Auto-answer if time runs out
    if (!this.answered && this.getTimeRemaining() <= 0) {
      this.answerProblem(-1); // Wrong answer
    }
  }

  getScore() {
    return this.score;
  }
}
