# 🌙 Midnight Runner - Godot Prototype

> "How deep does the midnight go?"

## Quick Start

### 1. Install Godot 4.2+

**macOS:**
```bash
brew install --cask godot
```

Or download from: https://godotengine.org/download

### 2. Open the Project

1. Launch Godot
2. Click "Import"
3. Navigate to this folder and select `project.godot`
4. Click "Import & Edit"

### 3. Run It

Press `F5` or click the Play button (▶️)

## Controls

| Input | Action |
|-------|--------|
| Swipe Left/Right | Change lane |
| Swipe Up | Jump |
| Swipe Down | Slide |
| Tap | Attack |
| ← → ↑ ↓ | Arrow keys (desktop testing) |
| Space/Enter | Attack (desktop testing) |

## Project Structure

```
godot-prototype/
├── project.godot        # Project config
├── scenes/
│   ├── main.tscn       # Main game scene
│   ├── runner.tscn     # Player character
│   └── monster.tscn    # Enemy template
├── scripts/
│   ├── game_manager.gd # Global state (autoload)
│   ├── main.gd         # Game loop, spawning
│   ├── runner.gd       # Player controls, combat
│   └── monster.gd      # Enemy behavior
└── assets/             # Art, sounds (add later)
```

## What's Implemented

- [x] Three-lane movement
- [x] Swipe controls (touch + mouse)
- [x] Jump and slide
- [x] Basic attack
- [x] Monster spawning
- [x] Depth system
- [x] Fragment collection
- [x] Counter mechanic
- [x] Death/Extract flow
- [x] Upgrade system (data only)
- [x] Save/Load

## What's Next

- [ ] Visual polish (sprites, particles)
- [ ] Sound effects
- [ ] Upgrade shop UI
- [ ] Menu screens
- [ ] More monster variety
- [ ] Background parallax

## Testing on Mobile

1. **iOS:** Export to Xcode project, run on device
2. **Android:** Export APK, install on device
3. **Quick test:** Use Godot's remote debug feature

## AI-Assisted Development

This prototype was created with AI assistance. To continue developing:

1. **Cursor/Copilot:** Open the project in Cursor for AI code completion
2. **Claude:** Ask me to modify any script or add features
3. **ChatGPT:** Works well for GDScript questions

Just describe what you want changed, and I'll write the code!

---

*The midnight waits.*
