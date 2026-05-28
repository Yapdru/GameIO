# GameIO - Quick Reference Card

## 🚀 Start Playing (30 seconds)

```bash
cd /home/user/GameIO
python3 -m http.server 8000
# Open: http://localhost:8000/
```

## 📂 File Guide

| File | Purpose | Size |
|------|---------|------|
| `index.html` | Entry point | 0.4 KB |
| `new-app.js` | Main controller | 13 KB |
| `new-style.css` | Styling | 7.6 KB |
| `new-game-data.js` | Config | 3.2 KB |
| `new-avatars.js` | Avatar builder | 4.7 KB |
| `new-firebase.js` | Multiplayer | 2.4 KB |
| `games/fishana.js` | Game #1 | 5.0 KB |
| `games/cars.js` | Game #2 | 3.9 KB |
| `games/badaam.js` | Game #3 | 5.4 KB |
| `games/space.js` | Game #4 | 4.9 KB |
| `games/obby.js` | Game #5 | 5.3 KB |
| `games/quiz.js` | Game #6 | 3.5 KB |
| `games/mathdash.js` | Game #7 | 5.4 KB |

**Total: ~2,000 lines of code, 48 KB**

## 🎮 The 7 Games

1. **Fishana** - Collect pearls, dodge sharks
2. **Cars** - Drive through checkpoints
3. **Badaam** - Play valid cards strategically
4. **Space** - Avoid asteroids, collect stars
5. **Obby** - Jump platforms
6. **Quiz** - Answer 5 questions
7. **Math** - Solve 10 math problems

## 🎯 User Flow

```
Start → Avatar Builder → Lobby → Games (7×) → Results
```

## 🎨 Colors to Know

- **Primary:** `#0099FF` (bright blue)
- **Accent:** `#FFD700` (golden yellow)
- **Text:** `#1a1a2e` (dark)
- **Background:** Light gradient

## ⚡ Quick Customizations

**Change a color:**
```css
/* new-style.css */
#0099FF → your color
#FFD700 → your color
```

**Change game time:**
```javascript
// In games/fishana.js
this.maxTime = 30000;  // 30 seconds
```

**Add a game:**
1. Create `games/mynewgame.js`
2. Add to `new-game-data.js`
3. Import in `new-app.js`

## 📱 Responsive Breakpoints

- **Desktop:** Full width, multi-column grids
- **Tablet:** 768px and below, adjusted columns
- **Mobile:** 480px and below, single column

## 🌐 Deployment

### GitHub Pages (2 minutes)
1. Settings → Pages
2. Source: Main branch (root)
3. Save
4. Visit: `https://yapdru.github.io/GameIO/`

### Local Server
```bash
python3 -m http.server 8000
# or
npx http-server .
```

## 🔧 Game Architecture

Each game has:
```javascript
class Game {
  constructor(canvas, onScore) { }
  update(dt) { return continue; }
  draw() { }
  getResult() { return { score: 0 }; }
}
```

Canvas games: Fishana, Cars, Space, Obby
DOM games: Badaam, Quiz, Math

## 📊 Scoring System

| Game | Time | Max Score | Per Action |
|------|------|-----------|-----------|
| Fishana | 30s | 300 | +10/pearl |
| Cars | 30s | 300 | +100/lap |
| Badaam | 45s | 450 | +50/play |
| Space | 40s | 400 | +25/star |
| Obby | 45s | 450 | +10/level |
| Quiz | 30s | 500 | +100/correct |
| Math | 45s | 500 | +50/correct |

**Total possible: ~2,900 points**

## 🎓 Code Snippets

**Update player position:**
```javascript
this.player.x += this.player.vx;
this.player.y += this.player.vy;
```

**Draw circle:**
```javascript
ctx.beginPath();
ctx.arc(x, y, radius, 0, Math.PI * 2);
ctx.fill();
```

**Handle keyboard:**
```javascript
this.keys['ArrowUp'] // true if pressed
```

**Update score:**
```javascript
this.score += 50;
this.onScore(this.score); // Update UI
```

## 🐛 Debug Tips

- Check browser console (F12)
- Look for import errors first
- Verify canvas exists in HTML
- Check game loop is running (requestAnimationFrame)
- Verify `onScore` callback is called

## 📚 Documentation

- **REBUILD_SUMMARY.md** - Architecture & design
- **GAMEIO_QUICKSTART.md** - Full user/dev guide
- **QUICK_REFERENCE.md** - This file

## ✅ Checklist: Before Launch

- [ ] Test locally (python3 -m http.server)
- [ ] Try all 7 games
- [ ] Test Quick Play
- [ ] Check mobile responsiveness
- [ ] Enable GitHub Pages
- [ ] Share the URL
- [ ] Celebrate! 🎉

## 🎮 Controls Cheat Sheet

| Game | Control | Action |
|------|---------|--------|
| Fishana | Mouse | Move fish |
| Cars | Arrow keys | Steer/speed |
| Badaam | Click | Play card |
| Space | Mouse L/R | Dodge |
| Obby | Arrow + Up | Move/jump |
| Quiz | Click | Select answer |
| Math | Click | Select answer |

## 📞 Support

- Check `GAMEIO_QUICKSTART.md` for troubleshooting
- Check game files for code examples
- Check `new-style.css` for styling examples
- Check `new-app.js` for architecture patterns

---

**You're ready!** 🚀 Start with: `python3 -m http.server 8000`
