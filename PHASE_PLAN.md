# GAMEIO REBUILD - PHASE PLAN

## ✅ PHASE 1: CLEAN APP SHELL (COMPLETE)

**What's built:**
- Start screen with 3 modes (Create, Join, Quick Play)
- Avatar builder (shapes + colors)
- Lobby screen (room code, player list, game selector)
- Game placeholder screen
- Results screen with leaderboard
- Complete screen flow navigation

**Files created:**
- `index.html` - Clean entry point
- `style.css` - Modern arcade theme
- `app.js` - Main controller (900 lines)
- `game-data.js` - Game metadata
- `avatars.js` - Avatar system
- `firebase.js` - Optional multiplayer

**Status:** App shell works perfectly. Can navigate all screens.

---

## 📋 PHASE 2: PLAYABLE GAMES

**What to build:**
Each game needs:
- `games/[name].js` with GameClass
- Constructor(canvas, onScore)
- update(dt) → returns true to continue
- draw() → render to canvas
- getResult() → returns {score, ...}

**Quick Play must work offline.**

### Game 1: Fishana Evolution
- Canvas game
- Player fish controlled by mouse
- Pearls to collect (+10 each)
- Enemy sharks to avoid
- 30 second timer
- Visual evolution stages

### Game 2: Cars Drift
- Top-down driving
- Arrow keys for steering
- Checkpoints/lap system
- Drift mechanics
- 30 second race

### Game 3: Badaam Saat
- DOM-based card game
- Show cards in hand
- Valid moves highlighted
- Play/Pass mechanic
- 45 seconds

### Game 4: Space Dash
- Avoid obstacles
- Collect stars
- Scrolling shooter
- 40 seconds

### Game 5: Obby Run
- Platform jumping
- Timer pressure
- 45 seconds

### Game 6: Quiz
- Multiple choice questions
- 5 questions per game
- 30 seconds

### Game 7: Math Dash
- Quick math problems
- 10 problems
- 45 seconds

---

## 🔄 PHASE 3: GAME INTEGRATION

**What to do:**
1. Import each game into app.js
2. Instantiate game on play screen
3. Call game.update() and game.draw() in loop
4. Handle game end → next game
5. Collect scores

**File changes:**
- `app.js` - Add game loader and loop

---

## 🌐 PHASE 4: FIREBASE MULTIPLAYER

**What to add:**
- Create room with Firebase
- Join room by code
- Player list syncs
- Scores sync in real-time
- Host can start games
- Non-host players see lobby

**Work only if Quick Play is solid.**

---

## 🎨 PHASE 5: VISUAL POLISH

**What to improve:**
- Smooth transitions
- Hover effects
- Button feedback
- Animation timing
- Color refinement
- Sound effects (optional)

**Only after games work.**

---

## CURRENT PRIORITIES

1. **NOW:** Test app shell - can you navigate all screens?
2. **NEXT:** Build Fishana (simplest canvas game)
3. **THEN:** Build remaining games
4. **AFTER:** Add Firebase
5. **LAST:** Polish visuals

---

## HOW TO TEST PHASE 1

```bash
cd /home/user/GameIO
python3 -m http.server 8000
# Visit: http://localhost:8000/
```

**Try:**
- Click "Quick Play"
- Customize avatar
- See game screen
- See results
- Play again

All screens should flow smoothly.

---

## NEXT STEP

Create `games/fishana.js` with a working Fishana game.
