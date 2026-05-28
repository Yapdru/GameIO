// Badaam Saat - Card game
export class Badaam {
  constructor(container, onScore) {
    this.container = container;
    this.onScore = onScore;
    this.score = 0;
    this.gameTime = 0;
    this.maxTime = 45000;
    this.moveCount = 0;

    // Initialize
    this.initCards();
    this.render();
  }

  initCards() {
    // Simple deck
    const suits = ['♥', '♣', '♦'];
    const values = ['6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];

    let deck = [];
    for (let suit of suits) {
      for (let val of values) {
        deck.push({ suit, value: val });
      }
    }

    // Shuffle
    for (let i = deck.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [deck[i], deck[j]] = [deck[j], deck[i]];
    }

    this.table = deck.slice(0, 3);
    this.hand = deck.slice(3, 11);
  }

  isValidMove(card) {
    if (this.table.length === 0) return true;
    const lastCard = this.table[this.table.length - 1];

    const cardVal = this.getCardValue(card.value);
    const lastVal = this.getCardValue(lastCard.value);

    return card.suit === lastCard.suit || cardVal > lastVal;
  }

  getCardValue(val) {
    const values = { '6': 6, '7': 7, '8': 8, '9': 9, '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14 };
    return values[val] || 0;
  }

  playCard(idx) {
    const card = this.hand[idx];
    if (this.isValidMove(card)) {
      this.table.push(card);
      this.hand.splice(idx, 1);
      this.moveCount++;
      this.score += 50;
      this.onScore(this.score);
      this.render();
    }
  }

  pass() {
    this.moveCount++;
    this.score += 10;
    this.onScore(this.score);
  }

  update(dt) {
    this.gameTime += dt;
    return this.gameTime < this.maxTime && this.hand.length > 0;
  }

  render() {
    this.container.innerHTML = '';
    const div = document.createElement('div');
    div.style.padding = '20px';
    div.style.maxWidth = '800px';
    div.style.margin = '0 auto';

    // Table cards
    const tableDiv = document.createElement('div');
    tableDiv.innerHTML = '<h3>Table</h3>';
    const tableCards = document.createElement('div');
    tableCards.style.display = 'flex';
    tableCards.style.gap = '10px';
    tableCards.style.flexWrap = 'wrap';
    tableCards.style.marginBottom = '20px';

    this.table.forEach(card => {
      const el = document.createElement('div');
      el.style.background = card.suit === '♥' || card.suit === '♦' ? '#FFE0E0' : '#E0E0FF';
      el.style.border = '2px solid #333';
      el.style.borderRadius = '8px';
      el.style.padding = '12px 16px';
      el.style.fontSize = '20px';
      el.style.fontWeight = '600';
      el.textContent = `${card.value}${card.suit}`;
      tableCards.appendChild(el);
    });

    tableDiv.appendChild(tableCards);
    div.appendChild(tableDiv);

    // Hand
    const handLabel = document.createElement('h3');
    handLabel.textContent = 'Your Hand';
    div.appendChild(handLabel);

    const handDiv = document.createElement('div');
    handDiv.style.display = 'grid';
    handDiv.style.gridTemplateColumns = 'repeat(auto-fit, minmax(70px, 1fr))';
    handDiv.style.gap = '10px';
    handDiv.style.marginBottom = '20px';

    this.hand.forEach((card, i) => {
      const valid = this.isValidMove(card);
      const btn = document.createElement('button');
      btn.style.background = valid ? '#D7F7FF' : '#F5F5F5';
      btn.style.border = valid ? '2px solid #0099FF' : '2px solid #CCC';
      btn.style.borderRadius = '8px';
      btn.style.padding = '12px 8px';
      btn.style.fontSize = '16px';
      btn.style.fontWeight = '600';
      btn.style.cursor = valid ? 'pointer' : 'not-allowed';
      btn.style.opacity = valid ? '1' : '0.6';
      btn.textContent = `${card.value}${card.suit}`;
      btn.onclick = () => {
        if (valid) this.playCard(i);
      };
      handDiv.appendChild(btn);
    });

    div.appendChild(handDiv);

    // Buttons
    const btnDiv = document.createElement('div');
    btnDiv.style.display = 'flex';
    btnDiv.style.gap = '10px';
    const passBtn = document.createElement('button');
    passBtn.textContent = 'Pass Move';
    passBtn.style.padding = '12px 20px';
    passBtn.style.cursor = 'pointer';
    passBtn.style.borderRadius = '8px';
    passBtn.style.border = 'none';
    passBtn.style.background = '#FFD700';
    passBtn.style.fontWeight = '600';
    passBtn.onclick = () => {
      this.pass();
      this.render();
    };
    btnDiv.appendChild(passBtn);
    div.appendChild(btnDiv);

    this.container.appendChild(div);
  }

  getResult() {
    return { score: this.score, moves: this.moveCount };
  }
}
