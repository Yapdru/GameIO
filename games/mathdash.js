// Math Dash - Speed math challenges
export class MathDash {
  constructor(container, onScore) {
    this.container = container;
    this.onScore = onScore;
    this.score = 0;
    this.gameTime = 0;
    this.maxTime = 45000;
    this.problemIdx = 0;
    this.correct = 0;
    this.total = 0;

    this.generateProblems();
    this.render();
  }

  generateProblems() {
    const ops = ['+', '-', '×', '÷'];
    this.problems = [];

    for (let i = 0; i < 10; i++) {
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
        const w = answer + Math.floor((Math.random() - 0.5) * 20);
        if (!wrong.includes(w) && w > 0) wrong.push(w);
      }

      const options = wrong.sort(() => Math.random() - 0.5);
      const correctIdx = options.indexOf(answer);

      this.problems.push({
        a,
        b,
        op,
        answer,
        options,
        correctIdx
      });
    }
  }

  selectAnswer(idx) {
    const p = this.problems[this.problemIdx];
    this.total++;

    if (idx === p.correctIdx) {
      this.correct++;
      this.score += 50;
      this.onScore(this.score);
    } else {
      this.score = Math.max(0, this.score - 10);
      this.onScore(this.score);
    }

    this.problemIdx++;
    if (this.problemIdx < this.problems.length) {
      this.render();
    }
  }

  update(dt) {
    this.gameTime += dt;
    return this.gameTime < this.maxTime && this.problemIdx < this.problems.length;
  }

  render() {
    this.container.innerHTML = '';
    const div = document.createElement('div');
    div.style.padding = '30px';
    div.style.maxWidth = '600px';
    div.style.margin = '0 auto';

    if (this.problemIdx >= this.problems.length) {
      const acc = Math.floor((this.correct / this.total) * 100);
      const end = document.createElement('div');
      end.style.textAlign = 'center';
      end.innerHTML = `
        <h2 style="color: #0099FF;">Math Dash Complete!</h2>
        <div style="font-size: 1.3rem; margin: 20px 0;">
          <div>Correct: <strong>${this.correct} / ${this.total}</strong></div>
          <div>Accuracy: <strong>${acc}%</strong></div>
        </div>
        <div style="font-size: 1.5rem; color: #FFD700; margin-top: 20px;">Score: ${this.score}</div>
      `;
      this.container.appendChild(end);
      return;
    }

    const p = this.problems[this.problemIdx];

    // Problem
    const pDiv = document.createElement('div');
    pDiv.style.fontSize = '3rem';
    pDiv.style.fontWeight = '700';
    pDiv.style.padding = '30px';
    pDiv.style.background = 'linear-gradient(135deg, #FFD700 0%, #FFA500 100%)';
    pDiv.style.borderRadius = '16px';
    pDiv.style.marginBottom = '30px';
    pDiv.style.textAlign = 'center';
    pDiv.style.color = '#333';
    pDiv.textContent = `${p.a} ${p.op} ${p.b} = ?`;
    div.appendChild(pDiv);

    // Options (2x2 grid)
    const optDiv = document.createElement('div');
    optDiv.style.display = 'grid';
    optDiv.style.gridTemplateColumns = 'repeat(2, 1fr)';
    optDiv.style.gap = '12px';
    optDiv.style.marginBottom = '30px';

    p.options.forEach((opt, i) => {
      const btn = document.createElement('button');
      btn.style.padding = '24px';
      btn.style.fontSize = '1.5rem';
      btn.style.fontWeight = '600';
      btn.style.border = '3px solid #DDD';
      btn.style.background = '#FFF';
      btn.style.borderRadius = '12px';
      btn.style.cursor = 'pointer';
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
      optDiv.appendChild(btn);
    });

    div.appendChild(optDiv);

    // Progress
    const prog = document.createElement('div');
    prog.style.textAlign = 'center';
    prog.style.color = '#666';
    prog.innerHTML = `
      Problem ${this.problemIdx + 1} / ${this.problems.length}<br>
      <strong style="color: #0099FF;">Score: ${this.score}</strong> |
      <strong style="color: #00CC88;">Correct: ${this.correct}</strong>
    `;
    div.appendChild(prog);

    this.container.appendChild(div);
  }

  getResult() {
    return { score: this.score, correct: this.correct };
  }
}
