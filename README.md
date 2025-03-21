# Rat Desktop Pet (Godot 4.3)

This is a simple Godot 4.3 project demonstrating how to spawn multiple autonomous pet "rats" using instancing and shared scripts. Each pet behaves independently with randomized names, movement speeds, and behavior states.

## Features

- Spawns multiple pets using a shared scene
- Randomized names and speeds per instance
- Independent behavior logic per pet
- Separation of movement and state logic
- Built in Godot 4.3 using GDScript

## Project Structure

### `main.gd`

The main scene script. It is responsible for:

- Instancing pet scenes (`res://pet.tscn`)
- Setting random starting offsets and movement speeds
- Assigning names to each pet
- Adding pets to the scene tree

### `pet.gd`

Script attached to the main pet scene. Handles:

- Setting up pet components (`PetMovement`, `PetState`)
- Initializing the starting state
- Centering the pet based on a random offset
- Receiving and applying randomized speed

### `pet_movement.gd`

Handles pet movement logic, including:

- Centering logic
- Maximum speed (`max_speed`) control
- Position interpolation or targeting (if used)

### `pet_state.gd`

Manages the finite state machine (FSM) for the pet:

- Defines pet states using an enum (e.g., `IDLE`, `WALK`, etc.)
- Handles state transitions
- Provides access to state definitions

### `pet_behaviour.gd`

Controls high-level pet behavior:

- Responds to state changes
- Updates animations or logic based on current state

### `window.gd`

Handles global or window-level logic:

- Retrieves the current window instance
- May be used for screen bounds, input, or view handling

## How It Works

- When the project runs, `main.gd` spawns three pets.
- Each pet receives:
  - A unique horizontal start offset
  - A randomly chosen speed
  - A randomly chosen name from the list `["Panko", "Ksenia", "Mochi"]`
- Each pet initializes independently and updates its movement and state logic via its own script references.

## Requirements

- Godot Engine 4.3 or newer

## License

This project is free to use and modify. Add your license information here if needed.

## Screenshots or Demo

(Add a screenshot or short description of how it looks in action.)
