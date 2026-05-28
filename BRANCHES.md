# GameIO Branch Guide

All branches are named after the core games of GameIO for clarity and inspiration.

## Active Branches

### 🐟 **GameFish-Pearl-Complete**
**Fishana Evolution Inspired** - Complete 3D Multiplayer Arcade

**Status**: ✅ Production Ready

**What's Here**:
- Complete MasterMind 3D Transition (all 5 phases)
- Parallel rendering system (2D + 3D)
- 3D lobby with avatars and portals
- 4 game worlds (Fishana, Cars, Space, Obby)
- Performance optimization suite
- All 7 games integrated and playable

**Latest Commit**: `b42776a` - Complete MasterMind implementation - all 5 phases done

**Key Files**:
- `three-world.js` - Main 3D engine
- `three-avatar.js` - Avatar system with animations
- `three-camera.js` - Camera manager
- `three-worlds.js` - Game world manager
- `three-performance.js` - Performance monitoring
- `worlds/` - Game world builders

**Performance**: 60 FPS, <14ms per frame, all budgets met

**Use This For**: 
- Production deployment with 3D features
- Understanding complete 3D architecture
- Reference implementation

---

### 🃏 **GameSat-Card-Handoff**
**Badaam Saat Inspired** - Architecture & Guidelines Document

**Status**: 📋 Reference/Guide

**What's Here**:
- `NextSteps.txt` - Complete handoff document
- Early implementation with 3D lobby
- Clean shell with multiplayer foundation
- Original game implementations (Fishana, Cars, Badaam Saat)

**Latest Commit**: `fccc0a2` - Update DoneClaude with final 3D lessons

**Key File**:
- `NextSteps.txt` - Architecture guidelines and lessons learned

**Use This For**:
- Understanding design philosophy
- Learning from previous attempts
- Reference for correct build order
- Multiplayer implementation patterns

---

## Branch Naming Convention

Branch names follow the pattern: `Game[Name]-[Reference]-[Descriptor]`

Examples:
- `GameFish-Pearl-Complete` - Fishana (pearls) - Complete implementation
- `GameSat-Card-Handoff` - Badaam Saat (cards) - Handoff document

This naming keeps branches organized around GameIO's core identity: a multiplayer arcade universe.

---

## Game References

Each branch can reference GameIO's 7 core games:

1. 🐟 **Fishana Evolution** - Pearl collection, evolution mechanics
2. 🏎️ **Cars Horizon** - Racing, drift, speed mechanics
3. 🃏 **Badaam Saat** - Card game, strategy, valid moves
4. 🚀 **Space Dash** - Asteroids, collection, speed challenges
5. 🧗 **Obby Run** - Parkour, jumping, obstacle courses
6. 🧠 **Quiz Master** - Trivia, thinking, knowledge
7. 🔢 **Math Dash** - Calculation, speed, difficulty

---

## Recommended Development Flow

### For New Features:
Create branches named: `Game[Inspiration]-[Feature]-[Number]`

Examples:
- `GameSpace-Stars-99` (Space Dash - new star mechanics)
- `GameObby-Jump-88` (Obby Run - improved jumping)
- `GameCar-Drift-77` (Cars - drift physics enhancement)

### Naming Tips:
- Use the game name that best matches the feature
- Include a specific reference (mechanic, item, action)
- Add a number for tracking/priority

---

## Repository Structure

```
GameIO/
├── GameFish-Pearl-Complete ← Main production branch
│   ├── three-world.js (3D engine)
│   ├── three-avatar.js (avatars)
│   ├── worlds/ (game worlds)
│   └── ARCHITECTURE.md
│
├── GameSat-Card-Handoff ← Reference/guide branch
│   ├── NextSteps.txt (architecture guide)
│   └── Early implementations
│
└── master (stable, occasionally updated)
```

---

## Quick Reference

| Branch | Purpose | Status | Use When |
|--------|---------|--------|----------|
| GameFish-Pearl-Complete | Production 3D | ✅ Ready | Deploying, extending features |
| GameSat-Card-Handoff | Architecture guide | 📋 Reference | Learning design patterns |
| master | Stable baseline | 📌 Baseline | Official releases |

---

**Last Updated**: 2026-05-28
**Created**: After MasterMind completion
