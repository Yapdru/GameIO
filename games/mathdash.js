// Math Dash - Speed math challenges
export class MathDash {
  constructor(container, onScore) {
    this.container = container;
    this.onScore = onScore;
    this.score = 0;
    this.gameTime = 0;
    this.maxTime = 45000;
    this.problems = [];
    this.currentIndex = 0;
    this.correct = 0;
    this.totalAnswered = 0;

    this.generateProblems();
    this.render();
  }

  generateProblems() {
    const ops = ['+', '-', '×', '÷'];
    const count = 10;

    for (let i = 0; i < count; i++) {
      const op = ops[Math.floor(Math.random() * ops.length)];
      let a, b, answer;

      if (op === '+') {
        a = Math.floor(Math.random() * 20) + 1;
        b = Math.floor(Math.random() * 20) + 1;
        answer = a + b;
      } else if (op === '-') {
        a = Math.floor(Math.random() * 30) + 10;
        b = Math.floor(Math.random() * a);
        answer = a - b;
      } else if (op === '×') {
        a = Math.floor(Math.random() * 12) + 1;
        b = Math.floor(Math.random() * 12) + 1;
        answer = a * b;
      } else {
        a = Math.floor(Math.random() * 12) + 1;
        b = a * (Math.floor(Math.random() * 12) + 1);
        answer = b / a;
      }

      // Generate wrong answers
      const wrong = [answer];
      while (wrong.length < 4) {
        const w = answer + (Math.random() - 0.5) * 20;
        if (!wrong.includes(w) && w > 0) wrong.push(Math.floor(w));
      }

      const options = wrong.sort(() => Math.random() - 0.5);
      const correctIndex = options.indexOf(answer);

      this.problems.push({
        a,
        b,
        op,
        answer,
        options,
        correctIndex
      });
    }
  }

  selectAnswer(index) {
    const p = this.problems[this.currentIndex];
    this.totalAnswered++;

    if (index === p.correctIndex) {
      this.correct++;
      this.score += 50;
      this.onScore(this.score);
    } else {
      this.score = Math.max(0, this.score - 10);
      this.onScore(this.score);
    }

    this.currentIndex++;
    if (this.currentIndex < this.problems.length) {
      this.render();
    }
  }

  update(dt) {
    this.gameTime += dt;
    return this.gameTime < this.maxTime && this.currentIndex < this.problems.length;
  }

  render() {
    this.container.innerHTML = '';

    if (this.currentIndex >= this.problems.length) {
      const accuracy = Math.floor((this.correct / this.totalAnswered) * 100);
      const endDiv = document.createElement('div');
      endDiv.style.textAlign = 'center';
      endDiv.style.padding = '40px';
      endDiv.innerHTML = `
        <h2 style="color: #0099FF; margin-bottom: 20px;">Math Dash Complete!</h2>
        <div style="font-size: 1.3rem; margin: 20px 0;">
          <div>Correct: <strong>${this.correct} / ${this.totalAnswered}</strong></div>
          <div>Accuracy: <strong>${accuracy}%</strong></div>
        </div>
        <div style="font-size: 1.5rem; color: #FFD700; margin-top: 20px;">Score: ${this.score}</div>
      `;
      this.container.appendChild(endDiv);
      return;
    }

    const p = this.problems[this.currentIndex];

    const mathDiv = document.createElement('div');
    mathDiv.style.padding = '30px';
    mathDiv.style.maxWidth = '600px';
    mathDiv.style.margin = '0 auto';

    // Problem
    const problemDiv = document.createElement('div');
    problemDiv.style.fontSize = '3rem';
    problemDiv.style.fontWeight = '700';
    problemDiv.style.marginBottom = '30px';
    problemDiv.style.padding = '30px';
    problemDiv.style.background = 'linear-gradient(135deg, #FFD700 0%, #FFA500 100%)';
    problemDiv.style.borderRadius = '16px';
    problemDiv.style.textAlign = 'center';
    problemDiv.style.color = '#333';
    problemDiv.textContent = `${p.a} ${p.op} ${p.b} = ?`;
    mathDiv.appendChild(problemDiv);

    // Options
    const optionsDiv = document.createElement('div');
    optionsDiv.style.display = 'grid';
    optionsDiv.style.gridTemplateColumns = 'repeat(2, 1fr)';
    optionsDiv.style.gap = '12px';
    optionsDiv.style.marginBottom = '30px';

    p.options.forEach((opt, i) => {
      const btn = document.createElement('button');
      btn.style.padding = '24px';
      btn.style.fontSize = '1.5rem';
      btn.style.fontWeight = '600';
      btn.style.border = '3px solid #DDD';
      btn.style.background = '#FFF';
      btn.style.borderRadius = '12px';
      btn.style.cursor = 'pointer';
      btn.style.transition = 'all 0.2s';
      btn.textContent = opt;
      btn.onmouseover = () => {
        btn.style.background = '#E0F4FF';
        btn.style.borderColor = '#0099FF';
        btn.style.transform = 'scale(1.05)';
      };
      btn.onmouseout = () => {
        btn.style.background = '#FFF';
        btn.style.borderColor = '#DDD';
        btn.style.transform = 'scale(1)';
      };
      btn.onclick = () => this.selectAnswer(i);
      optionsDiv.appendChild(btn);
    });

    mathDiv.appendChild(optionsDiv);

    // Progress
    const progress = document.createElement('div');
    progress.style.textAlign = 'center';
    progress.style.color = '#666';
    progress.innerHTML = `
      Problem ${this.currentIndex + 1} of ${this.problems.length}<br>
      <strong style="color: #0099FF;">Score: ${this.score}</strong> |
      <strong style="color: #00CC88;">Correct: ${this.correct}</strong>
    `;
    mathDiv.appendChild(progress);

    this.container.appendChild(mathDiv);
  }

  getResult() {
    return { score: this.score, correct: this.correct, total: this.totalAnswered };
  }
}
