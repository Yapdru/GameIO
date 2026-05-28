// Badaam Saat - Strategic card game
export class Badaam {
  constructor(container, onScore) {
    this.container = container;
    this.onScore = onScore;
    this.score = 0;

    // Game state
    this.table = [];
    this.hand = [];
    this.gameTime = 0;
    this.maxTime = 45000; // 45 seconds
    this.moveCount = 0;

    this.init();
    this.render();
  }

  init() {
    // Create simple deck
    const suits = ['♥', '♣', '♦', '♠'];
    const values = ['6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];

    const deck = [];
    for (const suit of suits) {
      for (const value of values) {
        deck.push({ suit, value });
      }
    }

    // Shuffle
    for (let i = deck.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [deck[i], deck[j]] = [deck[j], deck[i]];
    }

    // Deal
    this.table = deck.slice(0, 3);
    this.hand = deck.slice(3, 10);
  }

  isValidMove(card) {
    if (this.table.length === 0) return true;

    const lastCard = this.table[this.table.length - 1];
    const cardValue = parseInt(card.value) || (card.value === 'J' ? 11 : card.value === 'Q' ? 12 : card.value === 'K' ? 13 : 14);
    const lastValue = parseInt(lastCard.value) || (lastCard.value === 'J' ? 11 : lastCard.value === 'Q' ? 12 : lastCard.value === 'K' ? 13 : 14);

    // Can play card with same suit or higher value
    return card.suit === lastCard.suit || cardValue > lastValue;
  }

  playCard(index) {
    const card = this.hand[index];
    if (!this.isValidMove(card)) return false;

    this.table.push(card);
    this.hand.splice(index, 1);
    this.moveCount++;
    this.score += 50 + (this.moveCount * 5);
    this.onScore(this.score);

    return true;
  }

  passMove() {
    this.moveCount++;
    this.score += 10;
    this.onScore(this.score);
    return true;
  }

  update(dt) {
    this.gameTime += dt;
    return this.gameTime < this.maxTime && this.hand.length > 0;
  }

  render() {
    this.container.innerHTML = '';

    const gameDiv = document.createElement('div');
    gameDiv.style.padding = '20px';
    gameDiv.style.maxWidth = '800px';
    gameDiv.style.margin = '0 auto';

    // Table cards
    const tableDiv = document.createElement('div');
    tableDiv.style.marginBottom = '30px';

    const tableLabel = document.createElement('div');
    tableLabel.textContent = 'Table Cards';
    tableLabel.style.marginBottom = '10px';
    tableLabel.style.fontWeight = '600';
    tableDiv.appendChild(tableLabel);

    const tableCards = document.createElement('div');
    tableCards.style.display = 'flex';
    tableCards.style.gap = '10px';
    tableCards.style.flexWrap = 'wrap';
    tableCards.style.marginBottom = '20px';

    this.table.forEach(card => {
      const cardEl = document.createElement('div');
      cardEl.style.background = card.suit === '♥' || card.suit === '♦' ? '#FFE0E0' : '#E0E0FF';
      cardEl.style.border = '2px solid #999';
      cardEl.style.borderRadius = '8px';
      cardEl.style.padding = '12px 16px';
      cardEl.style.fontSize = '20px';
      cardEl.style.fontWeight = '600';
      cardEl.style.minWidth = '50px';
      cardEl.style.textAlign = 'center';
      cardEl.textContent = `${card.value}${card.suit}`;
      tableCards.appendChild(cardEl);
    });

    tableDiv.appendChild(tableCards);
    gameDiv.appendChild(tableDiv);

    // Hand
    const handLabel = document.createElement('div');
    handLabel.textContent = 'Your Hand';
    handLabel.style.marginBottom = '10px';
    handLabel.style.fontWeight = '600';
    gameDiv.appendChild(handLabel);

    const handCards = document.createElement('div');
    handCards.style.display = 'grid';
    handCards.style.gridTemplateColumns = 'repeat(auto-fit, minmax(70px, 1fr))';
    handCards.style.gap = '10px';
    handCards.style.marginBottom = '20px';

    this.hand.forEach((card, i) => {
      const valid = this.isValidMove(card);
      const cardBtn = document.createElement('button');
      cardBtn.style.background = valid ? '#D7F7FF' : '#F5F5F5';
      cardBtn.style.border = valid ? '2px solid #0099FF' : '2px solid #CCC';
      cardBtn.style.borderRadius = '8px';
      cardBtn.style.padding = '12px 8px';
      cardBtn.style.fontSize = '18px';
      cardBtn.style.fontWeight = '600';
      cardBtn.style.cursor = valid ? 'pointer' : 'not-allowed';
      cardBtn.style.opacity = valid ? '1' : '0.6';
      cardBtn.textContent = `${card.value}${card.suit}`;
      cardBtn.onclick = () => {
        if (valid && this.playCard(i)) {
          this.render();
        }
      };
      handCards.appendChild(cardBtn);
    });

    gameDiv.appendChild(handCards);

    // Pass button
    const passBtn = document.createElement('button');
    passBtn.className = 'btn btn-secondary';
    passBtn.textContent = 'Pass Move';
    passBtn.style.marginBottom = '20px';
    passBtn.onclick = () => {
      this.passMove();
      this.render();
    };
    gameDiv.appendChild(passBtn);

    // Info
    const info = document.createElement('div');
    info.style.background = '#F5F5F5';
    info.style.padding = '12px';
    info.style.borderRadius = '8px';
    info.style.marginTop = '20px';
    info.innerHTML = `
      <div>Score: <strong>${this.score}</strong></div>
      <div>Moves: <strong>${this.moveCount}</strong></div>
      <div>Cards Left: <strong>${this.hand.length}</strong></div>
    `;
    gameDiv.appendChild(info);

    this.container.appendChild(gameDiv);
  }

  getResult() {
    return { score: this.score, moves: this.moveCount };
  }
}
