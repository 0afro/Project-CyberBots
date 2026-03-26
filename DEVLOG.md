# Development Log

## Phase 1: Core Systems Foundation

### 03/02/26 — Engine Learning Phase
- Began learning the fundamentals of the Godot engine interface
- Practiced creating scenes, nodes, and basic 3D objects
- Learned how StaticBody3D, MeshInstance3D, and CollisionShape3D interact
- Tested simple environments and collision behaviour

### 05/02/26 — Map Planning and Scaling
- Planned the full playable map scale (600m × 600m)
- Defined environmental layout: two city sides separated by a central river with bridges
- Established scale references for gameplay: robot height target 12–15 meters, road width and city block sizing

### 07/02/26 — Greyboxing Environment
- Began greyboxing the environment using low-poly primitives
- Created base seabed floor, river cutout, river banks, initial bridge blockouts
- Implemented snapping workflow for faster modular placement
- Created separate scenes for reusable elements (bridges, buildings, road modules)

### 09/02/26 — City Layout Refinement
- Built road layout using modular rectangular pieces
- Designed city blocks and placeholder building volumes
- Adjusted proportions to match cinematic Transformers scale
- Organised scene hierarchy by using nodes as folders

### 11/02/26 — Lighting and Atmosphere
- Implemented WorldEnvironment lighting setup
- Created daytime cinematic sky using blue-toned gradient
- Tuned Directional light energy, Ambient lighting, Sky brightness and curves
- Achieved bright daytime lighting while maintaining darker cinematic sky tone

### 13/02/26 — Third-Person Camera System
- Implemented third-person camera rig using CamRoot, Yaw/Pitch pivot system, SpringArm3D for collision-safe camera positioning
- Added mouse-controlled rotation, scroll-wheel zoom, RMB camera rotation control
- Adjusted camera smoothing and responsiveness

### 14/02/26 — Player Movement System
- Implemented CharacterBody3D movement controller with WASD directional movement relative to camera
- Added sprinting, jumping, gravity system
- Improved acceleration behaviour to reduce sliding
- Tuned movement speeds to better match large-scale robot gameplay

### 15/02/26 — Interaction and Gameplay Systems
- Created pickup item scene with rotating and bobbing animation
- Implemented configurable pickup types (Health, Shield, Damage Boost) with color-coded energem materials
- Built interaction detection using Area3D proximity detection with hold-to-interact mechanic
- Fixed collision layer setup to allow player to walk through pickups while still detecting them

### 18/02/26 — Default Char Modeling & Godot Integration
- Created low-poly protoform character model (14m tall, 6m wide) using box modeling techniques in Blender
- Used Mixamo Y-Bot T-pose as proportional guide for accurate scaling
- Exported to Mixamo for automatic rigging
- Imported rigged character back to original Blender project and exported as .glb file
- Imported rigged protoform.glb with proper skinning data into Godot
- Resolved scale (0.5) and rotation alignment issues
- Replaced placeholder capsule with final character T-pose model

### 20/02/26 — Player Stats & HUD System
- Implemented PlayerStats system tracking health (100), shield (50), and damage multiplier
- Created damage absorption logic (shield depletes first, then health)
- Connected pickup system to PlayerStats (health restores 30HP, shield adds 25, damage boost gives 1.5x for 10s)
- Implemented death/respawn system
- Designed HUD visual layout with health/shield bars positioned top-left
- Created HUD script connecting UI to PlayerStats signals for real-time updates
- Added dynamic color feedback (health: white→red when critical, shield: blue)
- Implemented boost timer countdown display

### 05/03/26 — Third-Person Weapon System
- Created third-person blaster weapon (1.0×0.8×3.0m) attached to robot's right hand via BoneAttachment3D
- Implemented raycast shooting from camera center with fire rate cooldown (0.15s)
- Integrated weapon with PlayerStats damage multiplier system
- Enhanced red energon power-up to provide both damage boost (1.5x) and speed boost (1.5x) for 10s
- Fixed BoneAttachment3D binding and scene instancing workflow

## Phase 2: Combat & Enemy AI (In Progress)

### 08/03/26 — GitHub Setup & Laser Sight Implementation
- Set up GitHub repository with proper .gitignore for Godot 4
- Created README.md with setup instructions and feature list
- Created DEVLOG.md for development tracking

### 09-10/03/26 — Laser Sight & Mouse-Cursor Aiming
- Implemented visible laser sight on blaster weapon using CylinderMesh
- Created red glowing emissive material for laser beam
- Laser appears only while holding shoot button for visual feedback
- Developed mouse-cursor based aiming system using viewport raycast projection
- Laser dynamically scales length and points from gun muzzle to mouse target
- Updated shooting mechanics to fire at 3D position under mouse cursor
- Configured laser thickness (radius 0.15) for optimal visibility
- Resolved camera-relative vs mouse-cursor aiming discrepancy

### 11/03/26 — Enemy Test Dummy
- Created enemy test dummy (CharacterBody3D) with health system (50 HP)
- Enemy displays HP label above head with color feedback
- Enemies destroyed when health reaches zero
- Each enemy instance has unique material to prevent shared-state issues
- **Placed multiple enemies in level for combat testing**

### 12-13/03/26 — Enemy AI Chase & Combat System
- Implemented basic enemy AI with chase behaviour and tactical positioning
- Enemies track and move toward player (15 units/sec), stopping at distance (50 units) for ranged combat
- Enemies continuously face player and apply gravity to stay grounded
- Added shooting system: enemies fire at player within range (55 units) every 1.2 seconds
- Equipped enemies with visual gun mesh and orange laser sight (shoots from MuzzlePoint)
- Enemies deal 3 HP damage per shot, reduced for balanced difficulty
- Made sure obstacles block enemy shots
- Increased player speeds (walk: 35, sprint: 50) for better combat mobility and kiting
- Implemented shooting inaccuracy and staggered firing with random delays to balance combat

### 17/03/26 — Health rework/overhaul
- Implemented Transformers: War for Cybertron inspired segmented health system
- Increased player max health from 100 HP to 200 HP for better balance
- Health divided into 4 blocks of 50 HP each
- Added automatic health regeneration: 5 HP/sec after 3-second delay from last damage
- Regeneration capped at current block maximum - once a block is depleted, max regen capacity reduces e.g losing Block 4 (going below 150 HP) means player can only regenerate up to 150 HP max
- Health pickups now restore all lost blocks and refill to maximum health (200 HP) but might get respawn rate nerf 
- Redesigned HUD to visually show segmented health bar with divider lines
- Health bar displays in bright cyan blue like in Transformers WFC
- Health bar turns red when critical (50 HP or below - Block 1 only)
- Added three skewed divider lines at 25%, 50%, 75% to mark health block boundaries
- Dividers match health bar slant angle (0.38 radians rotation)
- Enlarged HUD bars for better visibility (250x30 pixels)
- Console logging added for health block loss events and regeneration

### Reason for gap between last update was becasue I was sick for the apst 2 weeks and then my pc corrupted so I had to get a new ssd and wipe everything. Luckily all project progress was pushed to git beforehand.

### 25-26/03/26 — Enemy AI Roaming & Chase Behaviour
- Enemies now positioned and spread out to prevent swarming
- Implemented three-state AI system for enemies: Roaming, Chasing, and Shooting
- Added territorial roaming behaviour where enemies patrol within designated radius of spawn point
- Enemies now only chase player when within detection range
- Enemies abandon chase and return to patrol if player escapes beyond 70 units or if enemy strays too far from spawn
- Reduced roaming speed (8 units/sec) compared to chase speed (15 units/sec) 
- Enemies pause for 2 seconds at each patrol point before selecting new random destination
- Matched shoot_range to stop_distance (both 50 units) to stop awkward standing phase
- Shooting triggers enemy alert state - damaged enemies immediately enter chase mode (requires improvment)
- Console logging added for AI state changes and debugging
- Added state change cooldown (0.3-0.5 seconds) to prevent rapid state flickering and visual bugs
- State transitions include small buffer zones to prevent jittering between states
- Added spawn position boundaries to prevent enemies from falling off platforms or wandering too far


