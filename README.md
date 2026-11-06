# Bound to Survive

Ninety seconds. One room. One ghost that teleports. Tag it with the flashlight to bank score at a cooldown cost — and don't get caught: every stun makes the ghost faster.

## How it plays

- WASD to move, mouse to look and aim; mouse is captured while playing
- Flashlight on the `flashlight_toggle` action; battery drains, runs low, and hits push distress feedback through the HUD shader
- The ghost teleports between marked spots, escalates with each hit, and strikes up close
- Score, hearts, and timer live on the HUD; intro, run, and result screen complete the loop

## Run it

Open [`bt-s/project.godot`](bt-s/project.godot) in Godot 4.5 and run the project. Full controls and mechanics notes: [`bt-s/PLAYER_GUIDE.md`](bt-s/PLAYER_GUIDE.md).

## Layout

- `bt-s/` — the Godot 4.5 project (the live one)
- `BTS/`, `BTS.7z` — earlier snapshots kept for history

## Status

Playable 90-second survival loop: intro, round, win/lose, restart.

Godot 4.5 · GDScript
