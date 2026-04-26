# Development Log

## Phase 1: Core Systems Foundation

### 03/02/26 — Engine Learning Phase
- Began learning the fundamentals of the Godot engine interface
- Practised creating scenes, nodes, and basic 3D objects
- Learnt how StaticBody3D, MeshInstance3D, and CollisionShape3D interact
- Tested simple environments and collision behaviour

### 05/02/26 — Map Planning and Scaling
- Planned the full playable map scale (600m × 600m)
- Defined environmental layout: two city sides separated by a central river with bridges
- Established scale references for gameplay: robot height target 12–15 metres, road width and city block sizing

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
- Achieved bright daytime lighting whilst maintaining darker cinematic sky tone

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
- Implemented configurable pickup types (Health, Shield, Damage Boost) with colour-coded energem materials
- Built interaction detection using Area3D proximity detection with hold-to-interact mechanic
- Fixed collision layer setup to allow player to walk through pickups whilst still detecting them

### 18/02/26 — Default Character Modelling & Godot Integration
- Created low-poly protoform character model (14m tall, 6m wide) using box modelling techniques in Blender
- Used Mixamo Y-Bot T-pose as proportional guide for accurate scaling
- Exported to Mixamo for automatic rigging
- Imported rigged character back to original Blender project and exported as .glb file
- Imported rigged protoform.glb with proper skinning data into Godot
- Resolved scale (0.5) and rotation alignment issues
- Replaced placeholder capsule with final character T-pose model

### 20/02/26 — Player Stats & HUD System
- Implemented PlayerStats system tracking health (100), shield (50), and damage multiplier
- Created damage absorption logic (shield depletes first, then health)
- Connected pickup system to PlayerStats (health restores 30HP, shield adds 25, damage boost gives 1.5× for 10s)
- Implemented death/respawn system
- Designed HUD visual layout with health/shield bars positioned top-left
- Created HUD script connecting UI to PlayerStats signals for real-time updates
- Added dynamic colour feedback (health: white→red when critical, shield: blue)
- Implemented boost timer countdown display

### 05/03/26 — Third-Person Weapon System
- Created third-person blaster weapon (1.0×0.8×3.0m) attached to robot's right hand via BoneAttachment3D
- Implemented raycast shooting from camera centre with fire rate cooldown (0.15s)
- Integrated weapon with PlayerStats damage multiplier system
- Enhanced red energon power-up to provide both damage boost (1.5×) and speed boost (1.5×) for 10s
- Fixed BoneAttachment3D binding and scene instancing workflow

## Phase 2: Combat & Enemy AI (In Progress)

### 08/03/26 — GitHub Setup & Laser Sight Implementation
- Set up GitHub repository with proper .gitignore for Godot 4
- Created README.md with setup instructions and feature list
- Created DEVLOG.md for development tracking

### 09-10/03/26 — Laser Sight & Mouse-Cursor Aiming
- Implemented visible laser sight on blaster weapon using CylinderMesh
- Created red glowing emissive material for laser beam
- Laser appears only whilst holding shoot button for visual feedback
- Developed mouse-cursor based aiming system using viewport raycast projection
- Laser dynamically scales length and points from gun muzzle to mouse target
- Updated shooting mechanics to fire at 3D position under mouse cursor
- Configured laser thickness (radius 0.15) for optimal visibility
- Resolved camera-relative vs mouse-cursor aiming discrepancy

### 11/03/26 — Enemy Test Dummy
- Created enemy test dummy (CharacterBody3D) with health system (50 HP)
- Enemy displays HP label above head with colour feedback
- Enemies destroyed when health reaches zero
- Each enemy instance has unique material to prevent shared-state issues
- **Placed multiple enemies in level for combat testing**

### 12-13/03/26 — Enemy AI Chase & Combat System
- Implemented basic enemy AI with chase behaviour and tactical positioning
- Enemies track and move towards player (15 units/sec), stopping at distance (50 units) for ranged combat
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
- Regeneration capped at current block maximum - once a block is depleted, max regen capacity reduces e.g. losing Block 4 (going below 150 HP) means player can only regenerate up to 150 HP max
- Health pickups now restore all lost blocks and refill to maximum health (200 HP) but might get respawn rate nerf 
- Redesigned HUD to visually show segmented health bar with divider lines
- Health bar displays in bright cyan blue like in Transformers WFC
- Health bar turns red when critical (50 HP or below - Block 1 only)
- Added three skewed divider lines at 25%, 50%, 75% to mark health block boundaries
- Dividers match health bar slant angle (0.38 radians rotation)
- Enlarged HUD bars for better visibility (250×30 pixels)
- Console logging added for health block loss events and regeneration

### Reason for gap between last update was because I was sick for the past 2 weeks and then my PC corrupted so I had to get a new SSD and wipe everything. Luckily all project progress was pushed to git beforehand.

### 25-26/03/26 — Enemy AI Roaming & Chase Behaviour
- Enemies now positioned and spread out to prevent swarming
- Implemented three-state AI system for enemies: Roaming, Chasing, and Shooting
- Added territorial roaming behaviour where enemies patrol within designated radius of spawn point
- Enemies now only chase player when within detection range
- Enemies abandon chase and return to patrol if player escapes beyond 70 units or if enemy strays too far from spawn
- Reduced roaming speed (8 units/sec) compared to chase speed (15 units/sec) 
- Enemies pause for 2 seconds at each patrol point before selecting new random destination
- Matched shoot_range to stop_distance (both 50 units) to stop awkward standing phase
- Shooting triggers enemy alert state - damaged enemies immediately enter chase mode (requires improvement)
- Console logging added for AI state changes and debugging
- Added state change cooldown (0.3-0.5 seconds) to prevent rapid state flickering and visual bugs
- State transitions include small buffer zones to prevent jittering between states
- Added spawn position boundaries to prevent enemies from falling off platforms or wandering too far

### Gap because new PC issue

### 01/04/26 — Area-Based Encounter System & Environment Updates
- Replaced wave spawning with area-based progression system
- Implemented 5 combat zones (area_1 through area_5)
- Created EncounterManager node to track area completion via enemy group monitoring
- Added 50-unit tall inverted yellow cone as objective beacon (positioned 50 units above area markers)
- Beacon automatically moves to next area when current zone is cleared
- Implemented HUD counter displaying "Area X/5" progress tracker
- Added 2-second transition delay between area completions
- Victory screen triggers after all 5 areas cleared
- Organised enemies into local groups for efficient area tracking

**Environment Polish:**
- Replaced greybox placeholder buildings with detailed modular building meshes
- Updated road tiles from basic primitives to textured road segments
- Added visual variety to cityscape with different building types
- Improved scene hierarchy organisation for better workflow

**Difficulty Scaling:**
- Implemented progressive damage scaling across 5 areas for increased challenge
- Area 1 (2 enemies): 3 damage per shot (tutorial difficulty)
- Damage increases per area to maintain challenge as player learns mechanics
- Area 5 (final area): ~15 damage per shot (exact value tuned during playtesting)
- Scaling creates natural difficulty curve matching player skill progression

**Character Animation System:**
- Re-imported custom protoform character from Godot to Blender
- Uploaded mesh to Mixamo for auto-rigging with standard skeleton
- Downloaded rigged character (FBX, T-pose, with skin)
- Downloaded three rifle animations from Mixamo (Idle, Walk, Run - FBX, without skin, 30fps)
- Imported all FBX files to Godot and set up AnimationTree with blend nodes
- Configured blend tree: idle/movement blend and walk/run blend
- Added character rotation code to face movement direction
- Issue encountered: Root motion in walk/run animations caused character position desync
- Solution: Removed AnimationTree, kept only idle animation playing
- Character displays in stationary idle pose whilst moving - no visual confusion or teleporting
- Rotation and movement work correctly with static idle animation

### 24/04/26 — Pre-Submission Polish
- Cleaned up code and added inline comments for clarity
- Finalised animation setup: idle animation only (no movement animations)
- Organised development evidence folder with iteration videos
- Updated README.md with complete feature list and setup instructions
- Documented known limitations and PC failure recovery process
- Prepared demo recording showing complete area progression gameplay
- Final GitHub push before April 27 submission deadline

### 26/04/26 — Final Menu Systems & Web Deployment

**Main Menu Implementation:**
- Created main menu scene with Cybertron planet background
- Implemented START GAME and QUIT buttons with custom styling
- Set main_menu.tscn as project main scene
- Added Transformers-style font and metallic UI elements
- Background image: "Cybertron Planet" by jjasso (DeviantArt - free use)

**Pause System:**
- Implemented ESC key pause functionality
- Created pause menu overlay with semi-transparent background
- Added RESUME, MAIN MENU, and QUIT options
- Configured Process Mode to "Always" for pause menu functionality
- Integrated pause system into player controller (bee.gd)

**Victory Screen Enhancement:**
- Enhanced existing victory screen with RESTART and MAIN MENU options
- Connected victory screen to menu navigation system
- Added proper scene transition handling

**Web Build & Deployment:**
- Exported HTML5 web build for browser play
- Deployed to itch.io: https://kidou-yuuto.itch.io/cyberbots-battle-for-new-york
- Configured viewport dimensions (1152×648) for consistent display
- Tested local build with Servez before deployment
- Added loading warnings for 10-20 second initial load time

**Enemy Visual Updates:**
- Updated enemy models to use protoform character mesh
- Scaled enemy models to match player scale (0.5)
- Repositioned enemy weapons and laser sight
- Maintained original AI functionality whilst improving visual consistency

**Documentation Finalisation:**
- Updated README.md with itch.io play link
- Added web build loading time notices
- Documented white building material issue in web build
- Credited background artist and custom fonts
- Prepared final submission package with all deliverables

### Final Submission — 27/04/26
- Complete game with main menu, pause, and victory screens
- Playable web build deployed to itch.io
- All source code pushed to GitHub
- Demo video prepared showing full gameplay loop
- Documentation complete: README, DEVLOG, development evidence
- Submitted via VLE before 12:00pm deadline


## Development Challenges

### PC Drive Failure Recovery (March 2026)
- Experienced complete drive corruption mid-development
- Lost work-in-progress assets and some visual iterations
- Successfully recovered all code via GitHub version control
- Rebuilt development environment on new SSD
- Demonstrates importance of version control for project continuity

### Time Management Decisions
- Prioritised core gameplay systems over visual polish
- Animation system partially implemented (idle animation functional, movement animations deferred)
- Focused on functional, demonstrable features for submission
- "Working software artefact" over polished but incomplete system
