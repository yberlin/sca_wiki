// =============================================================================
// keccak_round.v
// =============================================================================
// Keccak-f[1600] permutation - pure Verilog-2001 RTL (no vendor IP).
//
// 24-round sponge permutation for SHAKE128/SHAKE256.
// State: 5x5 array of 64-bit lanes = 1600 bits.
//
// IP Usage: None. Pure RTL.
// =============================================================================

`timescale 1ns / 1ps

module keccak_round (
  input         clk,
  input         rst_n,
  input         start,
  output        done,
  input  [1599:0] state_in,
  output [1599:0] state_out
);

  // Round constants (24 rounds)
  function [63:0] rc_const;
    input [4:0] idx;
    begin
      case (idx)
        5'd0:  rc_const = 64'h0000000000000001;
        5'd1:  rc_const = 64'h0000000000008082;
        5'd2:  rc_const = 64'h800000000000808A;
        5'd3:  rc_const = 64'h8000000080008000;
        5'd4:  rc_const = 64'h000000000000808B;
        5'd5:  rc_const = 64'h0000000080000001;
        5'd6:  rc_const = 64'h8000000080008081;
        5'd7:  rc_const = 64'h8000000000008009;
        5'd8:  rc_const = 64'h000000000000008A;
        5'd9:  rc_const = 64'h0000000000000088;
        5'd10: rc_const = 64'h0000000080008009;
        5'd11: rc_const = 64'h000000008000000A;
        5'd12: rc_const = 64'h000000008000808B;
        5'd13: rc_const = 64'h800000000000008B;
        5'd14: rc_const = 64'h8000000000008089;
        5'd15: rc_const = 64'h8000000000008003;
        5'd16: rc_const = 64'h8000000000008002;
        5'd17: rc_const = 64'h8000000000000080;
        5'd18: rc_const = 64'h000000000000800A;
        5'd19: rc_const = 64'h800000008000000A;
        5'd20: rc_const = 64'h8000000080008081;
        5'd21: rc_const = 64'h8000000000008080;
        5'd22: rc_const = 64'h0000000080000001;
        5'd23: rc_const = 64'h8000000080008008;
        default: rc_const = 64'h0;
      endcase
    end
  endfunction

  // Rotate left 64-bit
  function [63:0] rotl64;
    input [63:0] x;
    input [5:0]  n;
    begin
      if (n == 6'd0)
        rotl64 = x;
      else
        rotl64 = (x << n) | (x >> (64 - n));
    end
  endfunction

  // State
  reg [63:0] A [0:24];   // 25 lanes
  reg [63:0] B [0:24];   // rho+pi working copy
  reg [63:0] C [0:4];    // theta column parity
  reg [63:0] D [0:4];    // theta D values
  reg [4:0]  round_idx;
  reg        active;
  reg        done_reg;
  reg [1599:0] state_out_reg;

  assign done      = done_reg;
  assign state_out = state_out_reg;

  integer x, y, idx;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      active         <= 1'b0;
      done_reg       <= 1'b0;
      round_idx      <= 5'd0;
      state_out_reg  <= 1600'd0;
    end else begin
      done_reg <= 1'b0;
      if (!active) begin
        if (start) begin
          for (idx = 0; idx < 25; idx = idx + 1)
            A[idx] <= state_in[idx*64 +: 64];
          round_idx <= 5'd0;
          active    <= 1'b1;
        end
      end else begin
        if (round_idx < 24) begin
          // ---- Theta ----
          // C[x] = A[x] ^ A[x+5] ^ A[x+10] ^ A[x+15] ^ A[x+20]
          for (x = 0; x < 5; x = x + 1)
            C[x] = A[x] ^ A[x+5] ^ A[x+10] ^ A[x+15] ^ A[x+20];
          // D[x] = C[x-1] ^ rotl(C[x+1], 1)
          for (x = 0; x < 5; x = x + 1)
            D[x] = C[(x+4)%5] ^ rotl64(C[(x+1)%5], 6'd1);
          // A[x][y] ^= D[x]  (blocking so rho+pi sees updated A)
          for (x = 0; x < 5; x = x + 1)
            for (y = 0; y < 5; y = y + 1)
              A[x + 5*y] = A[x + 5*y] ^ D[x];

          // ---- Rho + Pi (combined) ----
          // B[y + 5*((2*x+3*y)%5)] = rotl(A[x + 5*y], rho_offset[x + 5*y])
          // All 25 lanes with CORRECT target indices:
          B[0]  = rotl64(A[0],  6'd0);   // (x=0,y=0)
          B[10] = rotl64(A[1],  6'd1);   // (x=1,y=0)
          B[20] = rotl64(A[2],  6'd62);  // (x=2,y=0)
          B[5]  = rotl64(A[3],  6'd28);  // (x=3,y=0)
          B[15] = rotl64(A[4],  6'd27);  // (x=4,y=0)
          B[16] = rotl64(A[5],  6'd36);  // (x=0,y=1)
          B[1]  = rotl64(A[6],  6'd44);  // (x=1,y=1)
          B[11] = rotl64(A[7],  6'd6);   // (x=2,y=1)
          B[21] = rotl64(A[8],  6'd55);  // (x=3,y=1)
          B[6]  = rotl64(A[9],  6'd20);  // (x=4,y=1)
          B[7]  = rotl64(A[10], 6'd3);   // (x=0,y=2)
          B[17] = rotl64(A[11], 6'd10);  // (x=1,y=2)
          B[2]  = rotl64(A[12], 6'd43);  // (x=2,y=2)
          B[12] = rotl64(A[13], 6'd25);  // (x=3,y=2)
          B[22] = rotl64(A[14], 6'd39);  // (x=4,y=2)
          B[23] = rotl64(A[15], 6'd41);  // (x=0,y=3)
          B[8]  = rotl64(A[16], 6'd45);  // (x=1,y=3)
          B[18] = rotl64(A[17], 6'd15);  // (x=2,y=3)
          B[3]  = rotl64(A[18], 6'd21);  // (x=3,y=3)
          B[13] = rotl64(A[19], 6'd8);   // (x=4,y=3)
          B[14] = rotl64(A[20], 6'd18);  // (x=0,y=4)
          B[24] = rotl64(A[21], 6'd2);   // (x=1,y=4)
          B[9]  = rotl64(A[22], 6'd61);  // (x=2,y=4)
          B[19] = rotl64(A[23], 6'd56);  // (x=3,y=4)
          B[4]  = rotl64(A[24], 6'd14);  // (x=4,y=4)

          // ---- Chi ----
          // A[x][y] = B[x][y] ^ ((~B[(x+1)%5][y]) & B[(x+2)%5][y])
          for (x = 0; x < 5; x = x + 1)
            for (y = 0; y < 5; y = y + 1)
              A[x + 5*y] = B[x + 5*y] ^ ((~B[(x+1)%5 + 5*y]) & B[(x+2)%5 + 5*y]);

          // ---- Iota ----
          A[0] = A[0] ^ rc_const(round_idx);

          round_idx <= round_idx + 1;
        end else begin
          for (idx = 0; idx < 25; idx = idx + 1)
            state_out_reg[idx*64 +: 64] <= A[idx];
          done_reg <= 1'b1;
          active   <= 1'b0;
        end
      end
    end
  end

endmodule
