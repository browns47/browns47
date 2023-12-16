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
