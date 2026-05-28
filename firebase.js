// Firebase integration - for multiplayer rooms
// Works with existing Firebase config or offline mode

const DB_URL = "https://gameio-7e343-default-rtdb.firebaseio.com";

export async function apiCall(path, method = 'GET', data = null) {
  try {
    const options = {
      method,
      headers: { 'Content-Type': 'application/json' }
    };
    if (data) options.body = JSON.stringify(data);

    const response = await fetch(`${DB_URL}${path}.json`, options);
    if (!response.ok) return null;
    return await response.json();
  } catch (err) {
    console.log('Firebase unavailable - offline mode');
    return null;
  }
}

export async function createRoom(playerData) {
  const code = generateRoomCode();
  const roomData = {
    code,
    createdAt: Date.now(),
    host: playerData.id,
    players: { [playerData.id]: playerData },
    currentGame: 0,
    started: false
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

export async function startGame(code, gameIndex) {
  await apiCall(`/rooms/${code}/started`, 'PUT', true);
  await apiCall(`/rooms/${code}/currentGame`, 'PUT', gameIndex);
}

function generateRoomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
}

// Offline room for Quick Play
export class OfflineRoom {
  constructor(playerData) {
    this.code = 'OFFLINE';
    this.host = playerData.id;
    this.players = { [playerData.id]: playerData };
    this.currentGame = 0;
    this.started = false;
  }

  addPlayer(playerData) {
    this.players[playerData.id] = playerData;
  }

  updateScore(playerId, score) {
    if (this.players[playerId]) {
      this.players[playerId].score = score;
    }
  }

  setCurrentGame(index) {
    this.currentGame = index;
  }
}
