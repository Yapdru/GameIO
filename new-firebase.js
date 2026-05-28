// Firebase Realtime Database integration for multiplayer
const DB_URL = "https://gameio-7e343-default-rtdb.firebaseio.com";

export async function apiCall(path, method = 'GET', data = null) {
  try {
    const options = { method, headers: { 'Content-Type': 'application/json' } };
    if (data) options.body = JSON.stringify(data);

    const response = await fetch(`${DB_URL}${path}.json`, options);
    if (!response.ok) return null;
    return await response.json();
  } catch (err) {
    console.warn('Firebase error:', err);
    return null;
  }
}

export async function createRoom(gameCode, playerData) {
  const code = generateRoomCode();
  const roomData = {
    code,
    game: gameCode,
    createdAt: Date.now(),
    players: { [playerData.id]: playerData },
    started: false,
    scores: {}
  };

  await apiCall(`/rooms/${code}`, 'PUT', roomData);
  return code;
}

export async function joinRoom(code, playerData) {
  const room = await apiCall(`/rooms/${code}`);
  if (!room) return null;

  await apiCall(`/rooms/${code}/players/${playerData.id}`, 'PUT', playerData);
  return room;
}

export async function getRoom(code) {
  return await apiCall(`/rooms/${code}`);
}

export async function updatePlayerScore(code, playerId, score) {
  await apiCall(`/rooms/${code}/players/${playerId}/score`, 'PUT', score);
}

export async function startRoom(code) {
  await apiCall(`/rooms/${code}/started`, 'PUT', true);
}

export async function deleteRoom(code) {
  await apiCall(`/rooms/${code}`, 'DELETE');
}

export async function waitForRoom(code, maxWait = 8000) {
  const startTime = Date.now();
  while (Date.now() - startTime < maxWait) {
    const room = await apiCall(`/rooms/${code}`);
    if (room && room.players) return room;
    await new Promise(r => setTimeout(r, 250));
  }
  return null;
}

function generateRoomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
}

// Offline mode fallback
export class OfflineRoom {
  constructor(code, playerData) {
    this.code = code;
    this.players = { [playerData.id]: playerData };
    this.started = false;
    this.scores = {};
  }

  addPlayer(playerData) {
    this.players[playerData.id] = playerData;
  }

  start() {
    this.started = true;
  }

  updateScore(playerId, score) {
    this.scores[playerId] = score;
  }
}
