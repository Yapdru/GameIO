// Firebase REST API integration for multiplayer

import { FIREBASE_CONFIG } from './config.js';

class Firebase {
  constructor() {
    this.baseUrl = FIREBASE_CONFIG.baseUrl;
  }

  async request(path, method = 'GET', data = null) {
    const url = `${this.baseUrl}${path}.json`;
    const options = {
      method,
      headers: { 'Content-Type': 'application/json' }
    };

    if (data) {
      options.body = JSON.stringify(data);
    }

    try {
      const res = await fetch(url, options);
      if (!res.ok) {
        console.error(`Firebase error: ${res.status}`);
        return null;
      }
      return await res.json();
    } catch (err) {
      console.error('Firebase request error:', err);
      return null;
    }
  }

  // Room operations
  async createRoom(roomCode, roomData) {
    return this.request(`/rooms/${roomCode}`, 'PUT', roomData);
  }

  async getRoom(roomCode) {
    return this.request(`/rooms/${roomCode}`, 'GET');
  }

  async updateRoom(roomCode, updates) {
    return this.request(`/rooms/${roomCode}`, 'PATCH', updates);
  }

  // Player operations
  async setPlayer(roomCode, playerId, playerData) {
    return this.request(`/rooms/${roomCode}/players/${playerId}`, 'PUT', playerData);
  }

  async getPlayers(roomCode) {
    const room = await this.getRoom(roomCode);
    return room?.players || {};
  }

  async removePlayer(roomCode, playerId) {
    return this.request(`/rooms/${roomCode}/players/${playerId}`, 'DELETE');
  }

  // Score operations
  async updateScore(roomCode, playerId, score) {
    return this.request(`/rooms/${roomCode}/players/${playerId}/score`, 'PUT', score);
  }

  // Game state
  async setGameState(roomCode, gameState) {
    return this.request(`/rooms/${roomCode}/gameState`, 'PUT', gameState);
  }

  async getGameState(roomCode) {
    return this.request(`/rooms/${roomCode}/gameState`, 'GET');
  }

  // Polling for room updates
  async pollRoom(roomCode, lastUpdate = 0) {
    const room = await this.getRoom(roomCode);
    if (!room) return null;

    return {
      players: room.players || {},
      gameState: room.gameState || {},
      lastUpdate: Date.now()
    };
  }
}

// Singleton
export const firebase = new Firebase();
