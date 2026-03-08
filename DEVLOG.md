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
- [TODO: Laser sight on weapon]
- [TODO: Enemy test dummy with health system]
