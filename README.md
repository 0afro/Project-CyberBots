# Transformers-Style Third-Person Shooter

A low-poly third-person shooter where players control giant robots (Vanguard) defending Earth from the Ravagers invasion force.

## Core Features Implemented

- **Third-person movement system** - WASD movement, camera-relative controls, sprint, jump
- **Health & Shield system** - 100 HP + 50 shield with damage absorption
- **Weapon system** - Blaster with raycast shooting from camera center
- **Power-up system** - 3 pickup types:
  - Health (white) - restores 30 HP
  - Shield (blue) - adds 25 shield
  - Damage boost (red) - 1.5x damage + 2x speed for 10s
- **HUD** - Real-time health/shield bars with Cybertronian styling, boost timer
- **Character model** - Rigged 14m tall protoform robot with weapon attachment
- **Respawning pickups** - Power-ups respawn after 15 seconds

## How to Run

### Requirements
- **Godot Engine 4.2+** (Download from https://godotengine.org/)

### Setup Instructions
1. Download/clone this repository
2. Open Godot Engine
3. Click "Import"
4. Navigate to the project folder and select `project.godot`
5. Click "Import & Edit"
6. Press **F5** to run the game

### Controls
- **WASD** - Move
- **Shift** - Sprint
- **Space** - Jump
- **Mouse** - Look around / Aim camera
- **Left Mouse Button** - Shoot
- **E (hold)** - Pick up power-ups
- **K** - Test damage (debug only)

## Dependencies
- Godot Engine 4.2 or later
- No external plugins or assets required

## Known Limitations / Not Yet Implemented
- No enemy AI (static test dummies only)
- No wave spawning system
- No boss fight
- Character stays in T-pose (no animations)
- No vehicle transformation mode
- No audio/sound effects
- No visual effects (muzzle flash, particles, hit effects)
- No main menu or game over screens

## Project Status
Core systems functional, ready for enemy AI and combat loop implementation.

## Development Process
See [DEVLOG.md](DEVLOG.md) for detailed development diary.

## Lore
The Vanguard were peacekeepers of the energem mines on Digitron, their homeworld. When the Ravagers attacked, most were killed or captured—but some escaped to Earth, where vast reserves of energem lie buried beneath the surface.

The Ravagers discovered their refuge and deployed an invasion force to construct a transporter device. If activated, it will drain Earth's energem and destroy the planet in the process.

Only three Vanguard operatives are currently in the city while reinforcements mobilize across the globe: Wasp, Bulk, and Omni Prime. Now they must face the Ravager commander—Renaissance Prime, Omni's former mentor, corrupted by stolen energem and bent on conquest.

## License
Copyright © 2026 Muhammed Marong

This project is submitted as coursework for my final year project at Godlsmiths University of London
All rights reserved. Educational use for assessment purposes only.
