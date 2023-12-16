1. LabyrinthMaze Module
This module is responsible for generating and displaying the maze on a VGA screen.

Inputs:
clk: Clock signal.
rst: Reset signal.
Outputs:
red, green, blue: Color signals for VGA display.
hsync, vsync: Horizontal and vertical synchronization signals for VGA.
Internal Signals:
h_count, v_count: Counters for horizontal and vertical synchronization.
maze_reg: 16x16 array representing the maze.
Parameters:
VGA timing parameters (H_SYNC_START, H_SYNC_END, V_SYNC_START, V_SYNC_END).
Description:
Generates VGA timing signals for horizontal and vertical synchronization.
Uses a recursive algorithm to generate a 16x16 maze with walls and open paths.
Displays the maze on the VGA screen, with walls in black and open paths in white.
2. Player Module
This module represents the player in the maze and handles player movement.

Inputs:
clk: Clock signal.
reset: Reset signal.
up, down, left, right: Movement direction signals.
maze_wall: Signal indicating whether there's a wall in the current direction.
Outputs:
hit_wall: Signal indicating if the player has hit a wall.
player_x, player_y: Current player coordinates.
Internal Signals:
hit_wall: Internal signal to track collisions.
player_next_x, player_next_y: Next player coordinates based on movement.
Description:
Initializes the player at a starting position.
Handles player movement based on input signals and collision detection.
Updates player coordinates accordingly.
3. CollisionDetection Module
This module checks for collisions between the player and maze walls.

Inputs:
player_x, player_y: Current player coordinates.
maze_data: Maze data from LabyrinthMaze module.
Outputs:
collision: Signal indicating a collision.
Internal Signals:
hit_wall: Internal signal to extract maze cell based on player's position.
Description:
Extracts the maze cell based on the player's current position.
Detects collisions by checking if the extracted cell represents a wall.
4. VGADisplay Module
This module handles VGA display logic.

Inputs:
clk: Clock signal.
rst: Reset signal.
red, green, blue: Color signals for VGA display.
hsync, vsync: Horizontal and vertical synchronization signals.
Outputs:
VGA color signals (red, green, blue).
Internal Signals:
h_disp_count, v_disp_count: Counters for horizontal and vertical display.
h_blank, v_blank: Signals indicating blanking periods.
Parameters:
VGA display parameters (H_DISPLAY, V_DISPLAY).
Description:
Generates VGA timing signals for horizontal and vertical display.
Controls the color output based on the VGA blanking periods.
5. MazeGame Module
This module integrates the previous modules to create a maze game.

Inputs:
clk: Clock signal.
rst: Reset signal.
start_game: Signal to start the game.
restart_game: Signal to restart the game.
Outputs:
game_over: Signal indicating the game over state.
score: Player's score.
Internal Signals:
maze_gen_done: Signal indicating if maze generation is complete.
player_x, player_y: Current player coordinates.
game_state: Game state machine (0: Start Screen, 1: Playing, 2: Game Over).
Description:
Manages the game state machine with different states.
Integrates maze generation, player movement, collision detection, and VGA display.
Handles start screen, playing, and game over states.
