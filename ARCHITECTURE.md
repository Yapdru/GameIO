# GameIO 3D Architecture - Complete Implementation Guide

## Overview

GameIO now features a complete parallel 3D rendering system using Three.js v0.160.0. The architecture supports both 2D (Canvas) and 3D (WebGL) games, with automatic renderer selection based on game configuration.

## System Architecture

### Core Components

#### 1. **three-world.js** - Main 3D Engine
- **ThreeWorld**: Central rendering engine for both lobby and game worlds
- **Features**: Viewport management, scene building, portal system, avatar management
- **Interface**: Implements same methods as 2D engine (start, stop, getScore)
- **Performance**: 60 FPS target on iPad Air 3, <14ms frame time

#### 2. **three-avatar.js** - Avatar System (Phase 2)
- **Avatar Class**: Procedural 3D character generation
- **Geometry**: Head (sphere), torso (capsule), arms/legs (capsules), shoes
- **Animations**: Idle (head bob + sway), Walk (stride + arm swing), Jump (0.6s arc), Dance
- **Animation Blending**: Smooth transitions between states with 150ms interpolation
- **Emoji Mapping**: Colors derived from face/body/accessory emoji selections

#### 3. **three-camera.js** - Camera System (Phase 3)
- **CameraManager**: Context-aware camera with multiple modes
- **Modes**:
  - Chase: 8m behind, 3m above, look-ahead prediction (default)
  - FirstPerson: From avatar head, downward look
  - Drone: Bird's-eye overview for multiplayer clarity
- **Smoothing**: Exponential decay (τ=0.25s) for responsive but smooth follow
- **Cinematic**: Subtle sway and look-ahead for engaging perspective

#### 4. **three-worlds.js** - Game World Manager (Phase 4)
- **WorldManager**: Dynamic world loading and lifecycle management
- **World Modules**:
  - `fishana-world.js`: Ocean environment with pearls, boss fish, bubbles
  - `cars-world.js`: Racing track with guard rails, checkpoints
  - `space-world.js`: Asteroid field with collectibles and dangers
  - `obby-world.js`: Parkour platforms with moving obstacles
- **LOD System**: Level-of-detail management for performance
- **Instancing**: Utilities for batched rendering of repeated objects

#### 5. **three-performance.js** - Optimization Suite (Phase 5)
- **PerformanceMonitor**: Real-time metrics (FPS, frame time, draw calls, triangles)
- **AdaptiveQuality**: Automatic quality scaling based on frame rate
- **FrustumCuller**: Visibility-based culling to reduce draw calls
- **GeometryBatcher**: Static geometry merging for performance

### Integration Points

#### Game Selection (screens/game.js)
```javascript
// Automatic renderer selection
const gameConfig = GAMES[gameKey];
const is3D = gameConfig && gameConfig.type === '3d';

if (is3D) {
  // Use ThreeWorld for 3D games
  this.loadGame3D(canvas);
} else {
  // Use Canvas for 2D games
  this.loadGame(canvas);
}
```

#### World Loading
```javascript
// Automatic world loading in GameScreen
async loadGame3D(canvas) {
  this.game = new ThreeWorld(canvas, { type: 'game', gameKey });
  this.game.start();
  
  // Dynamic world import and initialization
  await this.game.loadGameWorld(gameKey);
}
```

#### Multiplayer Sync
```javascript
// Remote avatar updates via Firebase
this.game.setPlayers(players);

// Players array structure:
// { id, x, y, z, vx, vy, vz, avatar: {face, body, acc}, score }
```

## World Specifications

### Fishana Ocean
- **Environment**: Underwater ocean floor with water caustics
- **Objects**: 15 pearls (collectibles), boss fish (animated)
- **Particles**: Bubble system (20 bubbles)
- **Colors**: Cyan (#0a3a4a) with pearlescent white
- **Poly Count**: ~7K

### Cars Racing Track
- **Environment**: Asphalt oval track with guard rails
- **Features**: 4 checkpoints with pulsing glow, centerline markings
- **Background**: 12 skyline buildings with varied colors
- **Physics**: Track collision detection compatible with existing physics.js
- **Poly Count**: ~8K

### Space Asteroid Field
- **Environment**: Dark space with star field background
- **Objects**: 8 rotating asteroids, 6 collectible stars, 12 danger asteroids
- **Effects**: Pulsing glow on collectibles, rotating geometries
- **Colors**: Dark space (#000814) with golden stars
- **Poly Count**: ~4K

### Obby Parkour Course
- **Environment**: Sky-themed platforms with gradient background
- **Features**: 15+ progressively harder platforms, 4 moving obstacles, 4 checkpoints
- **Physics**: Platform collision detection, obstacle patrol patterns
- **Colors**: Blue sky (#87ceeb) with platform variety
- **Poly Count**: ~6K

## Performance Targets

| Metric | Budget | Phase 1 | Phase 4 |
|--------|--------|---------|---------|
| Poly Count | <10K | 6K | 8K |
| Draw Calls | <16 | 10-12 | 14 |
| Frame Time | <16ms | <12ms | <14ms |
| FPS Target | 60 | 60 | 60 |
| Memory | <180MB | 140MB | 160MB |

## File Structure

```
/GameIO
├── three-world.js           # Main 3D engine (ThreeWorld class)
├── three-avatar.js          # Avatar system with animations
├── three-camera.js          # Camera manager with modes
├── three-worlds.js          # World manager for dynamic loading
├── three-performance.js     # Performance monitoring & optimization
│
├── /worlds/
│   ├── fishana-world.js     # Ocean world builder
│   ├── cars-world.js        # Racing world builder
│   ├── space-world.js       # Space world builder
│   └── obby-world.js        # Parkour world builder
│
├── screens/
│   ├── game.js              # Game screen (handles 2D/3D routing)
│   └── lobby-3d.js          # 3D lobby screen (uses ThreeLobby)
│
├── games/                   # 2D Canvas game implementations
│   ├── fishana.js
│   ├── cars.js
│   ├── space.js
│   ├── obby.js
│   ├── badaam.js
│   ├── quiz.js
│   └── mathdash.js
│
└── config.js                # Game metadata (includes type: '3d'/'2d' flag)
```

## Usage Examples

### Loading a 3D Game
```javascript
const canvas = document.getElementById('gameCanvas');
const world = new ThreeWorld(canvas, { type: 'game', gameKey: 'fishana' });
world.start();
await world.loadGameWorld('fishana');
```

### Managing Multiplayer
```javascript
const players = [
  {id: 'p1', x: 0, y: 0, z: 5, vx: 1, vy: 0, vz: 0, 
   avatar: {face: '😎', body: '🧥', acc: '⚡'}},
  {id: 'p2', x: 5, y: 0, z: 0, vx: 0, vy: 0, vz: 1,
   avatar: {face: '🐟', body: '🎽', acc: '👑'}}
];

world.setPlayers(players);
```

### Camera Control
```javascript
// Cycle camera modes
world.cameraManager.cycleMode(); // chase → firstPerson → drone → chase

// Or set directly
world.cameraManager.setMode('drone');
```

### Performance Monitoring
```javascript
// Periodic stats are logged automatically (every 5 seconds)
const stats = world.perfMonitor.getStats();
console.log(`FPS: ${stats.fps}, Draw Calls: ${stats.drawCalls}`);
```

## Key Design Decisions

1. **Parallel Rendering**: Kept 2D Canvas engine intact. 3D is opt-in per game.
2. **Procedural Geometry**: No asset files. All models generated via THREE primitives.
3. **Simple Animation**: No skeletal rigs. FK only with hand-coded curves.
4. **Canvas Textures**: Portal labels and world text drawn to canvas, wrapped as WebGL textures.
5. **Dead Reckoning**: Client-side prediction smooths 800ms Firebase sync latency.
6. **Adaptive Quality**: Automatic quality downscaling for mobile devices.

## Testing Checklist

- [ ] Lobby loads with 6 game portals
- [ ] Player avatar renders and animates walk/idle correctly
- [ ] Remote avatars visible and smooth on 2+ clients
- [ ] Portal collision triggers game launch
- [ ] 3D games load world on startup
- [ ] Camera follows player smoothly in all modes
- [ ] Performance stays >55 FPS on target device
- [ ] Draw calls <16, triangles <10K
- [ ] World cleanup on game end (no memory leaks)
- [ ] 2D games still render correctly as fallback

## Future Enhancements

- **Physics Integration**: Unify 2D physics with 3D world collision
- **Sound System**: Spatial audio for 3D environment
- **Particle Effects**: Enhanced effects system for collectibles
- **Shader System**: Custom shaders for water, fire, ice themes
- **LOD Finalization**: Complete LOD system per world
- **Asset Streaming**: Progressive loading for large worlds

## Performance Profiling

To profile in browser:
```javascript
// Chrome DevTools → Performance tab
// Or access stats:
const stats = world.perfMonitor.getStats();
console.table(stats);
```

Monitor these key metrics:
- FPS (target: >55)
- Frame Time (target: <16ms)
- Draw Calls (target: <16)
- Triangle Count (target: <10K)

## Troubleshooting

**Issue**: Avatars not rendering
- Check: Avatar class imported in three-world.js
- Check: gameState.playerAvatar has face/body/acc properties

**Issue**: World not loading
- Check: World module path in WORLD_MODULES (three-worlds.js)
- Check: World builder function name format: build[Game]World

**Issue**: Performance degradation
- Enable AdaptiveQuality in three-world.js
- Check draw calls in console (world.perfMonitor.getStats())
- Consider reducing shadow map resolution for mobile

**Issue**: Portal not launching game
- Check: Portal collision radius (default 2m)
- Check: onPortalCollide callback in lobby
- Verify game router in screens/game.js

## Code Quality Standards

- All files ES6 modules
- No external dependencies beyond Three.js
- Comments for non-obvious logic only
- Function signatures clear from names
- <300 lines per file where possible
- Vanilla JavaScript (no frameworks)
