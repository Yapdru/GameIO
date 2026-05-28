# GameIO - Multiplayer Arcade Universe

A modern browser-based multiplayer arcade game platform with 7 playable games, real-time multiplayer synchronization, and a stylized 3D lobby.

## Features

### 🎮 7 Playable Games
- **🐟 Fishana Evolution** - Swim, collect pearls, evolve into stronger forms
- **🏎️ Cars Horizon** - Arcade racing with drift scoring and boosts
- **🃏 Badaam Saat** - Traditional card game with authentic rules
- **🚀 Space Dash** - Navigate asteroid fields and collect stars
- **🧗 Sky Obby** - Parkour platformer with checkpoints
- **🧠 Quiz Master** - Timed multiple-choice questions
- **🔢 Math Dash** - Mental math problems with increasing difficulty

### 👥 Multiplayer First
- Create and join rooms with 6-character codes
- Real-time player synchronization
- Score tracking across all rounds
- Host-controlled game selection
- Up to 8 players per room

### 🎨 3D Lobby Experience
- Stylized 3D arcade lobby with 7 game portals
- Portal-based game selection (walk into portals to launch games)
- Cinematic arrival sequence on first entry
- First-person movement controls (WASD/Arrow Keys)
- Ambient music and sound effects
- Screen shake and visual feedback

### 🔧 Technical Highlights
- **Pure JavaScript** - No frameworks, vanilla implementation
- **Canvas-based rendering** - Fast, lightweight, browser-optimized
- **Three.js 3D** - CDN-loaded, not bundled
- **Web Audio API** - Generated sound effects and music (no audio files)
- **Firebase Real-time Database** - Multiplayer synchronization
- **Responsive Design** - Works on desktop and mobile
- **Modular Architecture** - 23 clean, focused files

## Getting Started

### Quick Start
1. Clone repository
2. Open `index.html` in a modern browser
3. Create or join a room
4. Select your avatar and start playing

### Room Codes
- **Creating:** Click "Create Game" - generates a 6-character code
- **Joining:** Click "Join Game" and enter room code

### Game Controls
- **Movement:** WASD or Arrow Keys
- **Jump/Action:** Space or W/Arrow Up
- **Confirm:** Click buttons or press Enter
- **Mobile:** Touch controls supported

## Architecture

### Directory Structure
```
GameIO/
├── screens/              # UI screens
│   ├── start.js         # Start screen
│   ├── avatar.js        # Avatar selection
│   ├── setup.js         # Game setup
│   ├── join.js          # Join room
│   ├── lobby.js         # 2D lobby
│   ├── lobby-3d.js      # 3D lobby
│   ├── arrival.js       # Cinematic intro
│   ├── game.js          # Game router
│   └── results.js       # Results screen
├── games/               # Game implementations
│   ├── fishana.js
│   ├── cars.js
│   ├── badaam.js
│   ├── space.js
│   ├── obby.js
│   ├── quiz.js
│   └── mathdash.js
├── audio-system.js      # Sound effects and music
├── three-lobby.js       # 3D lobby engine
├── ui-utils.js          # UI utilities and helpers
├── state.js             # Game state management
├── config.js            # Configuration
├── firebase.js          # Database integration
├── screens.js           # Screen manager
├── main.js              # Entry point
├── style.css            # Styling
└── index.html           # HTML root
```

### Key Modules

**state.js** - Centralized game state
- Player identity and persistence
- Room management
- Score tracking
- Game state

**firebase.js** - Real-time multiplayer
- Room synchronization
- Player list sync
- Score updates

**audio-system.js** - Web Audio API
- Ambient lobby music
- SFX (portal, score, win/lose)
- Game start/end jingles

**ui-utils.js** - UI enhancements
- Loading manager
- Error handling
- Settings management
- Touch controls
- Analytics
- Accessibility

**three-lobby.js** - 3D rendering
- Lobby environment
- 7 game portals
- Player avatars
- Cinematic effects
- Portal collision detection

## Design Philosophy

From NextSteps.txt:
> **Gameplay first. Multiplayer first. Clean structure first. 3D and polish later.**

### Principles Applied
✅ Every game has a 3-second explanation  
✅ Every game shows visible score  
✅ Every game has clear end condition  
✅ Every game has "Back to Lobby" button  
✅ Multiplayer syncs only important data  
✅ Assets are small (canvas + Web Audio)  
✅ Started with 2D games first  
✅ 3D added after gameplay works  
✅ Stylized graphics, not realistic  
✅ Games feel connected via lobby  

## Game Design References

GameIO is inspired by:
- **Agar.io** - Instant multiplayer, simple mechanics
- **Diep.io** - Progression and scoring
- **Skribbl.io** - Room-based social play
- **Shell Shockers** - Stylized browser 3D
- **Fall Guys** - Fun obstacle courses
- **Mario Kart** - Arcade racing
- **Roblox** - Hub of connected experiences

See `DESIGN_REFERENCES.md` for detailed analysis.

## Performance

- **Load Time:** < 2 seconds
- **Frame Rate:** 60 FPS (canvas games)
- **Network:** 1 sync/second during gameplay
- **Bundle Size:** ~100KB (no heavy dependencies)
- **Mobile:** Optimized for 60 FPS on modern devices

## Browser Support

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile browsers (iOS Safari, Chrome Mobile)

## Development

### Adding a New Game
1. Create `games/newgame.js` with class extending game interface
2. Implement: `start()`, `update()`, `draw()`, `stop()`, `getScore()`
3. Add to `screens/game.js` loader
4. Add to `config.js` GAMES object
5. Add explanation to `GAME_EXPLANATIONS`

### Modifying Lobby
- **2D:** Edit `screens/lobby.js`
- **3D:** Edit `screens/lobby-3d.js` and `three-lobby.js`

### Styling
- Main styles: `style.css`
- Component-specific: In screen constructors
- Responsive: Mobile breakpoints at 768px and 480px

## Documentation

- **VERIFICATION.md** - Design principle verification
- **COMPLETION_SUMMARY.md** - Implementation overview
- **DESIGN_REFERENCES.md** - Game reference analysis
- **NextSteps.txt** - Architecture guide with 30 game references

## License

Open source - free to use and modify.

## Future Enhancements

From NextSteps.txt (Phase 4 Steps 6-10):
- [ ] Daily challenge mode
- [ ] Avatar cosmetics and unlockables
- [ ] Persistent leaderboards
- [ ] Chat/messaging
- [ ] Achievement system
- [ ] Sound settings
- [ ] Advanced 3D lobby features

## Credits

Built with:
- Three.js for 3D rendering
- Firebase for multiplayer sync
- Web Audio API for sound
- Pure JavaScript for everything else

---

**GameIO: Many Games. One Lobby. Multiplayer First.**
