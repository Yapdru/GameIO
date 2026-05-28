// Quick Quiz - Multiple choice questions
const QUESTIONS = [
  { q: 'What is 2 + 2?', a: ['4', '5', '3', '6'], correct: 0 },
  { q: 'What is the capital of France?', a: ['London', 'Paris', 'Berlin', 'Rome'], correct: 1 },
  { q: 'What color is the sky?', a: ['Green', 'Red', 'Blue', 'Yellow'], correct: 2 },
  { q: 'How many legs does a dog have?', a: ['2', '3', '4', '5'], correct: 2 },
  { q: 'What is the largest planet?', a: ['Saturn', 'Jupiter', 'Mars', 'Neptune'], correct: 1 },
  { q: 'What is 10 - 3?', a: ['6', '7', '8', '9'], correct: 1 },
  { q: 'How many continents are there?', a: ['5', '6', '7', '8'], correct: 2 },
  { q: 'What is the smallest prime number?', a: ['1', '2', '3', '4'], correct: 1 }
];

export class Quiz {
  constructor(container, onScore) {
    this.container = container;
    this.onScore = onScore;
    this.score = 0;
    this.gameTime = 0;
    this.maxTime = 30000;
    this.questionIdx = 0;
    this.correct = 0;

    // Shuffle questions
    this.questions = QUESTIONS.sort(() => Math.random() - 0.5).slice(0, 5);
    this.render();
  }

  selectAnswer(idx) {
    const q = this.questions[this.questionIdx];
    if (idx === q.correct) {
      this.score += 100;
      this.correct++;
      this.onScore(this.score);
    }
    this.questionIdx++;
    if (this.questionIdx < this.questions.length) {
      this.render();
    }
  }

  update(dt) {
    this.gameTime += dt;
    return this.gameTime < this.maxTime && this.questionIdx < this.questions.length;
  }

  render() {
    this.container.innerHTML = '';
    const div = document.createElement('div');
    div.style.padding = '30px';
    div.style.maxWidth = '600px';
    div.style.margin = '0 auto';

    if (this.questionIdx >= this.questions.length) {
      const end = document.createElement('div');
      end.style.textAlign = 'center';
      end.innerHTML = `
        <h2 style="color: #0099FF;">Quiz Complete!</h2>
        <div style="font-size: 2rem; margin: 20px 0;">${this.correct} / ${this.questions.length}</div>
        <div style="font-size: 1.5rem; color: #FFD700;">Score: ${this.score}</div>
      `;
      this.container.appendChild(end);
      return;
    }

    const q = this.questions[this.questionIdx];

    // Question
    const qDiv = document.createElement('div');
    qDiv.style.fontSize = '1.3rem';
    qDiv.style.fontWeight = '600';
    qDiv.style.padding = '20px';
    qDiv.style.background = '#E0F4FF';
    qDiv.style.borderRadius = '12px';
    qDiv.style.marginBottom = '30px';
    qDiv.style.textAlign = 'center';
    qDiv.textContent = q.q;
    div.appendChild(qDiv);

    // Options
    const optDiv = document.createElement('div');
    optDiv.style.display = 'grid';
    optDiv.style.gap = '12px';

    q.a.forEach((ans, i) => {
      const btn = document.createElement('button');
      btn.style.padding = '16px';
      btn.style.fontSize = '1rem';
      btn.style.border = '2px solid #DDD';
      btn.style.background = '#FFF';
      btn.style.borderRadius = '12px';
      btn.style.cursor = 'pointer';
      btn.textContent = ans;
      btn.onmouseover = () => {
        btn.style.background = '#E0F4FF';
        btn.style.borderColor = '#0099FF';
      };
      btn.onmouseout = () => {
        btn.style.background = '#FFF';
        btn.style.borderColor = '#DDD';
      };
      btn.onclick = () => this.selectAnswer(i);
      optDiv.appendChild(btn);
    });

    div.appendChild(optDiv);

    // Progress
    const prog = document.createElement('div');
    prog.style.marginTop = '30px';
    prog.style.textAlign = 'center';
    prog.style.color = '#666';
    prog.innerHTML = `Question ${this.questionIdx + 1} / ${this.questions.length}<br><strong style="color: #0099FF;">Score: ${this.score}</strong>`;
    div.appendChild(prog);

    this.container.appendChild(div);
  }

  getResult() {
    return { score: this.score, correct: this.correct };
  }
}
