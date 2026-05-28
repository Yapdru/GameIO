// Badaam Saat - Authentic Indian card game
// Rules: Match cards by suit or rank, special 7s, build sequences
// Strategy: When to play, when to pass, combo scoring

import { gameState } from '../state.js';

export class BadaamGame {
  constructor() {
    // Full deck
    this.suits = ['♥', '♦', '♣', '♠'];
    this.ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];

    // Game state
    this.deck = this.createDeck();
    this.shuffleDeck();

    this.table = [];           // Cards on table
    this.hand = [];            // Player's hand
    this.discardPile = [];     // Played cards
    this.score = 0;
    this.combo = 0;            // Chain for bonus
    this.roundCount = 0;
    this.maxRounds = 5;

    this.gameTime = Date.now();
    this.roundTime = 45; // seconds per round
    this.isRunning = true;
    this.roundStartTime = Date.now();

    this.initRound();
  }

  createDeck() {
    const deck = [];
    for (let suit of this.suits) {
      for (let rank of this.ranks) {
        deck.push({ suit, rank, id: Math.random() });
      }
    }
    return deck;
  }

  shuffleDeck() {
    for (let i = this.deck.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [this.deck[i], this.deck[j]] = [this.deck[j], this.deck[i]];
    }
  }

  initRound() {
    this.roundCount += 1;
    this.roundStartTime = Date.now();
    this.combo = 0;

    // Deal cards
    this.table = [];
    this.hand = [];

    // Draw 5 cards to hand
    for (let i = 0; i < 5; i++) {
      if (this.deck.length > 0) {
        this.hand.push(this.deck.pop());
      }
    }

    // Seed table with 2 starting cards (easier to match)
    for (let i = 0; i < 2; i++) {
      if (this.deck.length > 0) {
        this.table.push(this.deck.pop());
      }
    }
  }

  isValidMove(card) {
    // Rule 1: 7s are always playable (Badaam Saat rule)
    if (card.rank === '7') return true;

    // Rule 2: Match suit or rank with any table card
    if (this.table.length === 0) return true;

    return this.table.some(tableCard =>
      tableCard.suit === card.suit || tableCard.rank === card.rank
    );
  }

  playCard(cardIndex) {
    const card = this.hand[cardIndex];

    if (!this.isValidMove(card)) {
      this.combo = 0; // Combo reset on invalid move
      return false;
    }

    this.hand.splice(cardIndex, 1);
    this.table.push(card);
    this.discardPile.push(card);

    // Scoring logic
    let points = 10; // Base points

    // Bonus: Playing a 7 (Badaam = 7s)
    if (card.rank === '7') {
      points += 25;
      this.combo += 2;
    }

    // Bonus: Matching multiple cards
    const matchingCards = this.table.filter(tc =>
      tc.suit === card.suit || tc.rank === card.rank
    ).length;

    if (matchingCards > 2) {
      points += matchingCards * 5; // Sequence bonus
      this.combo += 1;
    }

    // Combo multiplier
    points *= (1 + this.combo * 0.1);
    this.score += Math.floor(points);

    // Draw replacement card
    if (this.hand.length < 5 && this.deck.length > 0) {
      this.hand.push(this.deck.pop());
    }

    // Clear table if all cards are same rank (special rule)
    const allSameRank = this.table.every(c => c.rank === card.rank);
    if (allSameRank && this.table.length >= 3) {
      this.score += 50; // Clear bonus
      this.table = [];
      this.combo = 0;
    }

    return true;
  }

  passRound() {
    // Passing ends your turn
    this.combo = 0; // Combo resets
    this.score += 5; // Small penalty

    // Reshuffle table and redraw
    if (this.table.length > 0) {
      this.table.forEach(c => this.discardPile.push(c));
    }

    this.table = [];

    // Redraw hand if needed
    while (this.hand.length < 5 && this.deck.length > 0) {
      this.hand.push(this.deck.pop());
    }
  }

  getTimeRemaining() {
    const elapsed = (Date.now() - this.roundStartTime) / 1000;
    return Math.max(0, this.roundTime - elapsed);
  }

  isRoundOver() {
    return this.getTimeRemaining() <= 0 || this.roundCount >= this.maxRounds;
  }

  update() {
    // Check if round time is up
    if (this.isRoundOver()) {
      this.isRunning = false;
    }
  }

  getScore() {
    return this.score;
  }

  stop() {
    this.isRunning = false;
  }
}
