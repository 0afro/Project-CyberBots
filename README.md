# Project CyberBots: Battle for New York

A low-poly third-person shooter where players control giant robots defending Earth from an invasion force.

**Submission:** Final Year Project - Goldsmiths, University of London  
**Developer:** Muhammed Marong  
**Submission Date:** April 27, 2026

---

## What This Project Does

A third-person action game featuring robot combat, enemy AI, area-based progression, and Transformers-inspired health mechanics. Players navigate a cityscape, defeating enemies across 5 distinct combat zones.

---

## Core Features Implemented

### Player Systems
- **Third-person movement** - WASD camera-relative controls, sprint, jump
- **Mouse-cursor aiming** - Shoot exactly where cursor points with visible laser sight
- **Segmented health system** - 200 HP divided into 4 blocks (50 HP each)
  - Auto-regeneration: 5 HP/sec after 3s delay
  - Regeneration capped at current block maximum
  - Cyan HUD with visual block dividers (Transformers WFC-inspired)
- **Shield system** - 50 shield points, damage absorption priority
- **Power-ups** - Health (restores all blocks), Shield, Damage/Speed Boost

### Combat Systems
- **Blaster weapon** - Raycast shooting with fire rate cooldown, damage multiplier support
- **Visible laser sight** - Red beam shows aim direction whilst firing

### Enemy AI
- **Three-state AI** - Roaming (patrol spawn area), Chasing (pursue player), Shooting (ranged combat)
- **Territorial behaviour** - Enemies patrol within spawn radius, abandon chase if player escapes
- **Combat stats** - 50 HP, 15 units/sec chase speed, shoots every 2 seconds, 3 HP damage per shot *depends on location of bot*
- **Tactical positioning** - Stops at 50 units for ranged combat, inaccuracy for balance

### Progression System
- **5 combat areas** - Clear all enemies in each zone to progress
- **Objective tracking** - Large 3D beacon marks next area, HUD counter shows progress (Area X/5)
- **Victory condition** - Clear all 5 areas to win
- **Difficulty scaling** - Progressive damage scaling across areas (Area 1: 3 damage, Area 5: ~15 damage)

### Environment
- **600m × 600m cityscape** - Greyboxed urban environment with roads, buildings, bridges
- **Cinematic lighting** - Foggy sooty sky with atmospheric DirectionalLight setup

---

## Setup and Run Instructions

### Requirements
- **Godot Engine 4.3+** (Download: https://godotengine.org/)
- **Operating System:** Windows, macOS, or Linux
- **No external dependencies or plugins required**

### Installation Steps

1. **Download/Clone Repository**
   ```bash
   git clone (https://github.com/0afro/Project-CyberBots.git)
   ```

2. **Open in Godot**
   - Launch Godot Engine
   - Click "Import"
   - Navigate to project folder
   - Select `project.godot`
   - Click "Import & Edit"

3. **Run Game**
   - Press **F5** or click "Run Project" button
   - Game starts in first combat area

### Controls

| Action | Key/Input |
|--------|-----------|
| Move | WASD |
| Sprint | Left Shift (hold) |
| Jump | Spacebar |
| Look Around | Mouse Movement |
| Shoot | Left Mouse Button (hold) |
| Pick Up Power-Up | E (hold for 0.5s) |
| Test Damage | K (debug only) |

---

## Test Instructions for Markers

1. **Start game** (F5) - Player spawns in Area 1
2. **Move with WASD**, sprint with Shift
3. **Aim with mouse**, shoot enemies with LMB
4. **dark blue beacon** marks objective location
5. **HUD top-left** shows health (cyan), shield (blue), Area progress
6. **Clear Area 1** - Destroy all red enemies
7. **Beacon moves to Area 2** after 2-second delay
8. **Repeat** through all 5 areas
9. **Victory screen** appears after Area 5 cleared
10. **Power-ups** respawn after 15 seconds (health, shield, boost)

---

## Known Limitations

### Due to Development Setbacks
- **PC drive failure (March 2026)** - Lost work-in-progress assets and features
  - Code recovered via GitHub version control
  - Some visual polish and asset iterations lost

### Current State
- **Limited animations** - Character uses idle animation only (walk/run animations disabled due to root motion conflicts)
- **No main menu** - Game starts directly in gameplay
- **No pause menu** - Restart required to replay
- **Visual polish incomplete** - Basic materials, no particle effects
- **No audio** - Sound effects and music not implemented
- **Boss fight not implemented** - Planned but not completed

### Features Planned But Not Implemented
- Full character animation system (walk/run cycles)
- Vehicle transformation mode
- Muzzle flash and hit effects
- Main menu and pause screens
- Boss encounter
- Audio system

---

## Development Evidence

**See `/development-evidence/` folder for:**
- Early iteration videos (phone recordings)
- AI development progress
- Health system tests
- Recovery documentation after PC failure

**See `DEVLOG.md` for complete development timeline**

---

## Technical Highlights

- **Modular AI state machine** - Clean separation of roaming, chase, and combat states
- **Camera-relative movement** - Input transforms to camera basis for intuitive controls
- **Segmented health with regen cap** - Unique mechanic inspired by Transformers War for Cybertron game.
- **Area-based encounter manager** - Scalable progression system using node groups
- **Signal-driven HUD** - Real-time UI updates via PlayerStats signals
- **BoneAttachment weapon system** - Blaster attached to skeleton for animation-ready setup

---

## Project Lore

The Vanguard were peacekeepers of energem mines on Digitron. When the Ravagers attacked, survivors escaped to Earth, where vast energem reserves lie buried. The Ravagers followed, deploying forces to construct a transporter that will drain Earth's energem and destroy the planet.

Three Vanguard operatives defend the city: Wasp, Bulk, and Omni Prime, facing their former mentor Renaissance Prime who is now corrupted by dark energem.

---

---

## Assets & Attributions

### 3D Models
Due to the PC drive failure in March 2026, original custom-made building and road models created in Blender were lost. The following free assets were used as replacements:

- **Building models:** https://kenney.nl/assets/city-kit-commercial
- **Road models:** https://kenney.nl/assets/city-kit-roads
- **Vehicle models:** https://www.cgtrader.com/designers/jeremiahm?utm_source=credit&utm_source=credit_item_page

### UI & Menu
- **Menu background:** "Cybertron Planet" by jjasso on DeviantArt (https://www.deviantart.com/jjasso/art/Cybertron-planet-151644012) - Free to use
- **Custom font:** transformers-movie font from DaFont.com (Free for personal use (https://www.dafont.com/transformers-movie.font))

All other assets (character model, weapon, environment layout, textures) are original work.

### Character & Animations
- **Character rigging:** Mixamo auto-rigging service (https://www.mixamo.com/)
- **Animations:** Mixamo animation library (Rifle Idle - used in final build)
- **Character model:** Original low-poly protoform design created in Blender

### Tools Used
- **Game Engine:** Godot 4.3
- **3D Modelling:** Blender 3.6
- **Version Control:** Git/GitHub
- **Character Rigging:** Adobe Mixamo

---


## License & Submission

**Copyright © 2026 Muhammed Marong**

Submitted as coursework for Final Year Project  
Goldsmiths, University of London  
Computer Science BSc

All rights reserved. Educational use for assessment purposes only.



**Questions or Issues?**  
Contact: mmaro001@campus.goldsmiths.ac.uk
