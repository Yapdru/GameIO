// Badaam Saat - Indian card game

import { gameState } from '../state.js';

export class BadaamGame {
  constructor() {
    // Card deck
    this.suits = ['♥', '♦', '♣', '♠'];
    this.ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];

    // Game state
    this.table = [];
    this.hand = [];
    this.score = 0;
    this.roundCount = 0;
    this.maxRounds = 5;
    this.gameTime = Date.now();
    this.roundTime = 30; // seconds per round
    this.isRunning = true;

    this.initRound();
  }

  initRound() {
    this.roundCount += 1;

    // Generate random cards for table
    this.table = this.generateCards(3);

    // Generate hand
    this.hand = this.generateCards(5);
  }

  generateCards(count) {
    const cards = [];
    for (let i = 0; i < count; i++) {
      const suit = this.suits[Math.floor(Math.random() * this.suits.length)];
      const rank = this.ranks[Math.floor(Math.random() * this.ranks.length)];
      cards.push({ suit, rank, id: Math.random() });
    }
    return cards;
  }

  isValidMove(card) {
    // Simple rule: can play if suit or rank matches any table card
    if (this.table.length === 0) return true;

    return this.table.some(tableCard =>
      tableCard.suit === card.suit || tableCard.rank === card.rank
    );
  }

  playCard(cardIndex) {
    const card = this.hand[cardIndex];

    if (!this.isValidMove(card)) {
      return false; // Invalid move
    }

    this.table.push(card);
    this.hand.splice(cardIndex, 1);
    this.score += 10; // Points for playing a card

    // If hand is empty, draw new cards
    if (this.hand.length === 0) {
      this.hand = this.generateCards(3);
      this.score += 20; // Bonus for clearing hand
    }

    return true;
  }

  passRound() {
    // Player passes
    this.score += 5;
    this.table = [];
    this.hand = this.generateCards(3);
  }

  isRoundOver() {
    const elapsed = (Date.now() - this.gameTime) / 1000;
    return elapsed > this.roundTime || this.roundCount >= this.maxRounds;
  }

  getScore() {
    return this.score;
  }
}
