module LabyrinthMaze (
  input wire clk,
  input wire rst,
  output reg [3:0] red,
  output reg [3:0] green,
  output reg [3:0] blue,
  output reg hsync,
  output reg vsync
);

  reg [10:0] h_count;
  reg [10:0] v_count;
  reg [15:0] maze_reg [0:15][0:15];

  // VGA parameters
  parameter H_SYNC_START = 96;
  parameter H_SYNC_END = 800;
  parameter V_SYNC_START = 2;
  parameter V_SYNC_END = 525;

  // VGA signal generation
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      h_count <= 0;
      v_count <= 0;
    end else begin
      // Horizontal counter
      if (h_count == H_SYNC_END - 1) begin
        h_count <= 0;
      end else begin
        h_count <= h_count + 1;
      end

      // Vertical counter
      if (h_count == H_SYNC_END - 1) begin
        if (v_count == V_SYNC_END - 1) begin
          v_count <= 0;
        end else begin
          v_count <= v_count + 1;
        end
      end
    end
  end

  // VGA signal generation
  always @(posedge clk) begin
    hsync <= (h_count < H_SYNC_START) | (h_count >= H_SYNC_END);
    vsync <= (v_count < V_SYNC_START) | (v_count >= V_SYNC_END);
  end

  // Maze generation
  initial begin
    // Initialize maze with walls
    integer i, j;
    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        maze_reg[i][j] = 16'b1111111111111111; // All walls initially
      end
    end

    // Generate maze using recursive algorithm
    generate_maze(1, 1, 15, 15);
  end

  // Simple display logic for the generated maze
  always @(posedge clk) begin
    if (maze_reg[v_count][h_count]) begin
      red <= 4'b0000;
      green <= 4'b0000;
      blue <= 4'b0000; // Wall (black)
    end else begin
      red <= 4'b1111;
      green <= 4'b1111;
      blue <= 4'b1111; // Open path (white)
    end
  end

  // Recursive function to generate the maze using a recursive algorithm
  function void generate_maze(int start_row, int start_col, int end_row, int end_col);
    integer mid_row, mid_col;
    if (start_row >= end_row || start_col >= end_col) return;
    mid_row = (start_row + end_row) / 2;
    mid_col = (start_col + end_col) / 2;

    // Create a path in the middle of the current section
    maze_reg[mid_row][mid_col] = 16'b0000000000000000;

    // Recursively call for each quadrant
    generate_maze(start_row, start_col, mid_row - 1, mid_col - 1);
    generate_maze(start_row, mid_col + 1, mid_row - 1, end_col);
    generate_maze(mid_row + 1, start_col, end_row, mid_col - 1);
    generate_maze(mid_row + 1, mid_col + 1, end_row, end_col);
  endfunction
endmodule

module Player (
  input wire clk,
  input wire reset,
  input wire up,
  input wire down,
  input wire left,
  input wire right,
  input wire maze_wall,
  output wire hit_wall,
  output reg [10:0] player_x,
  output reg [10:0] player_y
);

  // Player starting position
  reg [10:0] player_start_x = 1;
  reg [10:0] player_start_y = 1;

  // Internal signals
  reg hit_wall;

  // Player position registers
  reg [10:0] player_next_x;
  reg [10:0] player_next_y;

  // Player movement logic
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      player_x <= player_start_x;
      player_y <= player_start_y;
    end else begin
      if (up && !maze_wall) begin
        player_next_y <= player_y - 1;
      end else if (down && !maze_wall) begin
        player_next_y <= player_y + 1;
      end else begin
        player_next_y <= player_y;
      end

      if (left && !maze_wall) begin
        player_next_x <= player_x - 1;
      end else if (right && !maze_wall) begin
        player_next_x <= player_x + 1;
      end else begin
        player_next_x <= player_x;
      end

      if (up || down || left || right) begin
        hit_wall <= maze_wall;
        player_x <= player_next_x;
        player_y <= player_next_y;
      end
    end
  end
endmodule

module CollisionDetection (
  input wire [10:0] player_x,
  input wire [10:0] player_y,
  input wire [15:0] maze_data,
  output wire collision
);

  wire hit_wall;

  // Extract the relevant maze cell based on player's position
  assign hit_wall = maze_data[player_y * 16 + player_x];

  // Collision detection logic
  assign collision = hit_wall;
endmodule

module VGADisplay (
  input wire clk,
  input wire rst,
  input wire [3:0] red,
  input wire [3:0] green,
  input wire [3:0] blue,
  input wire hsync,
  input wire vsync
);

  // VGA parameters
  parameter H_DISPLAY = 640;
  parameter V_DISPLAY = 480;

  // Internal counters
  reg [10:0] h_disp_count;
  reg [10:0] v_disp_count;

  // VGA output
  reg h_blank, v_blank;

  // VGA display logic
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      h_disp_count <= 0;
      v_disp_count <= 0;
      h_blank <= 1;
      v_blank <= 1;
    end else begin
      // Horizontal counter
      if (hsync) begin
        h_disp_count <= 0;
        h_blank <= 1;
      end else if (h_disp_count < H_DISPLAY - 1) begin
        h_disp_count <= h_disp_count + 1;
        h_blank <= 0;
      end else begin
        h_disp_count <= 0;
        h_blank <= 1;
      end

      // Vertical counter
      if (vsync) begin
        v_disp_count <= 0;
        v_blank <= 1;
      end else if (v_disp_count < V_DISPLAY - 1) begin
        v_disp_count <= v_disp_count + 1;
        v_blank <= 0;
      end else begin
        v_disp_count <= 0;
        v_blank <= 1;
      end
    end
  end

  // VGA color output logic
  assign {red, green, blue} = (h_blank | v_blank) ? 4'b0000 : {red, green, blue};
endmodule

module MazeGame (
  input wire clk,
  input wire rst,
  input wire start_game,
  input wire restart_game,
  output reg game_over,
  output reg [6:0] score
);

  reg maze_gen_done;
  reg [15:0] maze_data [0:15][0:15];
  reg [10:0] player_x;
  reg [10:0] player_y;
  reg [1:0] game_state; // 0: Start Screen, 1: Playing, 2: Game Over

  // Instantiate modules
  LabyrinthMaze maze (
    .clk(clk),
    .rst(rst),
    .red(maze_data[15'h0][15'h0][3:0]),
    .green(maze_data[15'h0][15'h0][7:4]),
    .blue(maze_data[15'h0][15'h0][11:8]),
    .hsync(maze_data[15'h0][15'h0][12]),
    .vsync(maze_data[15'h0][15'h0][13])
  );

  Player player (
    .clk(clk),
    .reset(rst || restart_game),
    .up(maze_data[player_y-1][player_x][15]),
    .down(maze_data[player_y+1][player_x][15]),
    .left(maze_data[player_y][player_x-1][15]),
    .right(maze_data[player_y][player_x+1][15]),
    .maze_wall(maze_data[player_y][player_x][15]),
    .hit_wall(maze_data[player_y][player_x][15]),
    .player_x(player_x),
    .player_y(player_y)
  );

  CollisionDetection collision (
    .player_x(player_x),
    .player_y(player_y),
    .maze_data(maze_data[player_y][player_x]),
    .collision(player.hit_wall)
  );

  VGADisplay vga_display (
    .clk(clk),
    .rst(rst),
    .red(maze_data[vga_display.v_disp_count][vga_display.h_disp_count][3:0]),
    .green(maze_data[vga_display.v_disp_count][vga_display.h_disp_count][7:4]),
    .blue(maze_data[vga_display.v_disp_count][vga_display.h_disp_count][11:8]),
    .hsync(vga_display.h_blank),
    .vsync(vga_display.v_blank)
  );

  // Game logic
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      game_state <= 0;
      game_over <= 0;
      score <= 0;
      maze_gen_done <= 0;
      player_x <= 1;
      player_y <= 1;
    end else begin
      case (game_state)
        0: begin // Start Screen
          if (start_game) begin
            game_state <= 1;
            maze_gen_done <= 0;
          end
        end
        1: begin // Playing
          if (!maze_gen_done) begin
            maze_gen_done <= 1;
            // Generate maze once at the start of the game
            // (You may need a mechanism to regenerate if needed)
            maze.generate_maze(1, 1, 15, 15);
          end
          if (collision.collision) begin
            game_state <= 2; // Game Over
          end else if (player_x == 15 && player_y == 15) begin
            game_state <= 2; // Reached the goal, Game Over
          end else begin
            score <= score + 1;
          end
        end
        2: begin // Game Over
          if (restart_game) begin
            game_state <= 0;
            game_over <= 0;
            score <= 0;
            maze_gen_done <= 0;
            player_x <= 1;
            player_y <= 1;
          end
        end
      endcase
    end
  end
endmodule
