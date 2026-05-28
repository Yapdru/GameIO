// Quick Quiz - Answer questions for points
import { QUIZ_QUESTIONS } from '../new-game-data.js';

export class Quiz {
  constructor(container, onScore) {
    this.container = container;
    this.onScore = onScore;
    this.score = 0;
    this.gameTime = 0;
    this.maxTime = 30000;
    this.questionIndex = 0;
    this.totalCorrect = 0;

    this.questions = QUIZ_QUESTIONS.sort(() => Math.random() - 0.5).slice(0, 5);
    this.render();
  }

  selectAnswer(index) {
    const q = this.questions[this.questionIndex];
    if (index === q.correct) {
      this.score += 100;
      this.totalCorrect++;
      this.onScore(this.score);
    }

    this.questionIndex++;
    if (this.questionIndex < this.questions.length) {
      this.render();
    }
  }

  update(dt) {
    this.gameTime += dt;
    return this.gameTime < this.maxTime && this.questionIndex < this.questions.length;
  }

  render() {
    this.container.innerHTML = '';

    if (this.questionIndex >= this.questions.length) {
      const endDiv = document.createElement('div');
      endDiv.style.textAlign = 'center';
      endDiv.style.padding = '40px';
      endDiv.innerHTML = `
        <h2 style="color: #0099FF; margin-bottom: 20px;">Quiz Complete!</h2>
        <div style="font-size: 2rem; margin: 20px 0;">${this.totalCorrect} / ${this.questions.length}</div>
        <div style="font-size: 1.5rem; color: #FFD700;">Score: ${this.score}</div>
      `;
      this.container.appendChild(endDiv);
      return;
    }

    const q = this.questions[this.questionIndex];

    const quizDiv = document.createElement('div');
    quizDiv.style.padding = '30px';
    quizDiv.style.maxWidth = '600px';
    quizDiv.style.margin = '0 auto';

    // Question
    const qDiv = document.createElement('div');
    qDiv.style.fontSize = '1.3rem';
    qDiv.style.fontWeight = '600';
    qDiv.style.marginBottom = '30px';
    qDiv.style.padding = '20px';
    qDiv.style.background = '#E0F4FF';
    qDiv.style.borderRadius = '12px';
    qDiv.style.textAlign = 'center';
    qDiv.textContent = q.q;
    quizDiv.appendChild(qDiv);

    // Options
    const optionsDiv = document.createElement('div');
    optionsDiv.style.display = 'grid';
    optionsDiv.style.gap = '12px';

    q.options.forEach((option, i) => {
      const btn = document.createElement('button');
      btn.style.padding = '16px';
      btn.style.fontSize = '1.1rem';
      btn.style.border = '2px solid #DDD';
      btn.style.background = '#FFF';
      btn.style.borderRadius = '12px';
      btn.style.cursor = 'pointer';
      btn.style.transition = 'all 0.2s';
      btn.textContent = option;
      btn.onmouseover = () => {
        btn.style.background = '#E0F4FF';
        btn.style.borderColor = '#0099FF';
      };
      btn.onmouseout = () => {
        btn.style.background = '#FFF';
        btn.style.borderColor = '#DDD';
      };
      btn.onclick = () => this.selectAnswer(i);
      optionsDiv.appendChild(btn);
    });

    quizDiv.appendChild(optionsDiv);

    // Progress
    const progress = document.createElement('div');
    progress.style.marginTop = '30px';
    progress.style.textAlign = 'center';
    progress.style.color = '#666';
    progress.innerHTML = `
      Question ${this.questionIndex + 1} of ${this.questions.length}<br>
      <strong style="color: #0099FF;">Score: ${this.score}</strong>
    `;
    quizDiv.appendChild(progress);

    this.container.appendChild(quizDiv);
  }

  getResult() {
    return { score: this.score, correct: this.totalCorrect, total: this.questions.length };
  }
}
