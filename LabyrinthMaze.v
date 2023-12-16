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

    // Display maze on VGA
    display_maze();
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

  // Task to display the maze (for debugging purposes)
  task display_maze;
    integer i, j;
    $display("Maze:");
    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        $write("%b ", maze_reg[i][j]);
      end
      $write("\n");
    end
  endtask

endmodule
