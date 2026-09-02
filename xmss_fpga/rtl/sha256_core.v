// =============================================================================
// sha256_core.v
// =============================================================================
// SHA-256 hash function core - pure Verilog-2001 RTL (no vendor IP).
//
// Computes SHA-256 as defined in FIPS 180-4.
// Supports XMSS function prefixes: F, H, H_msg, PRF.
//
// The module accepts 512-bit message blocks one at a time.
// The caller constructs the full input (prefix || key || data),
// pads it into 512-bit blocks, and streams them in.
//
// msg_last=1 on the final block tells the core to output the digest.
//
// IP Usage: None. Pure RTL.
// =============================================================================

`timescale 1ns / 1ps

module sha256_core (
  input         clk,
  input         rst_n,

  // Message input (512-bit blocks)
  input  [511:0] msg_data,
  input         msg_valid,
  input         msg_last,    // 1 on the final block
  output        msg_ready,

  // Control
  input         start,
  input  [7:0]  n_bytes,

  // Output
  output [255:0] digest,
  output        done
);

  // SHA-256 round constants
  function [31:0] k_round;
    input [5:0] idx;
    begin
      case (idx)
        6'd0:  k_round = 32'h428a2f98;
        6'd1:  k_round = 32'h71374491;
        6'd2:  k_round = 32'hb5c0fbcf;
        6'd3:  k_round = 32'he9b5dba5;
        6'd4:  k_round = 32'h3956c25b;
        6'd5:  k_round = 32'h59f111f1;
        6'd6:  k_round = 32'h923f82a4;
        6'd7:  k_round = 32'hab1c5ed5;
        6'd8:  k_round = 32'hd807aa98;
        6'd9:  k_round = 32'h12835b01;
        6'd10: k_round = 32'h243185be;
        6'd11: k_round = 32'h550c7dc3;
        6'd12: k_round = 32'h72be5d74;
        6'd13: k_round = 32'h80deb1fe;
        6'd14: k_round = 32'h9bdc06a7;
        6'd15: k_round = 32'hc19bf174;
        6'd16: k_round = 32'he49b69c1;
        6'd17: k_round = 32'hefbe4786;
        6'd18: k_round = 32'h0fc19dc6;
        6'd19: k_round = 32'h240ca1cc;
        6'd20: k_round = 32'h2de92c6f;
        6'd21: k_round = 32'h4a7484aa;
        6'd22: k_round = 32'h5cb0a9dc;
        6'd23: k_round = 32'h76f988da;
        6'd24: k_round = 32'h983e5152;
        6'd25: k_round = 32'ha831c66d;
        6'd26: k_round = 32'hb00327c8;
        6'd27: k_round = 32'hbf597fc7;
        6'd28: k_round = 32'hc6e00bf3;
        6'd29: k_round = 32'hd5a79147;
        6'd30: k_round = 32'h06ca6351;
        6'd31: k_round = 32'h14292967;
        6'd32: k_round = 32'h27b70a85;
        6'd33: k_round = 32'h2e1b2138;
        6'd34: k_round = 32'h4d2c6dfc;
        6'd35: k_round = 32'h53380d13;
        6'd36: k_round = 32'h650a7354;
        6'd37: k_round = 32'h766a0abb;
        6'd38: k_round = 32'h81c2c92e;
        6'd39: k_round = 32'h92722c85;
        6'd40: k_round = 32'ha2bfe8a1;
        6'd41: k_round = 32'ha81a664b;
        6'd42: k_round = 32'hc24b8b70;
        6'd43: k_round = 32'hc76c51a3;
        6'd44: k_round = 32'hd192e819;
        6'd45: k_round = 32'hd6990624;
        6'd46: k_round = 32'hf40e3585;
        6'd47: k_round = 32'h106aa070;
        6'd48: k_round = 32'h19a4c116;
        6'd49: k_round = 32'h1e376c08;
        6'd50: k_round = 32'h2748774c;
        6'd51: k_round = 32'h34b0bcb5;
        6'd52: k_round = 32'h391c0cb3;
        6'd53: k_round = 32'h4ed8aa4a;
        6'd54: k_round = 32'h5b9cca4f;
        6'd55: k_round = 32'h682e6ff3;
        6'd56: k_round = 32'h748f82ee;
        6'd57: k_round = 32'h78a5636f;
        6'd58: k_round = 32'h84c87814;
        6'd59: k_round = 32'h8cc70208;
        6'd60: k_round = 32'h90befffa;
        6'd61: k_round = 32'ha4506ceb;
        6'd62: k_round = 32'hbef9a3f7;
        6'd63: k_round = 32'hc67178f2;
        default: k_round = 32'h00000000;
      endcase
    end
  endfunction

  // SHA-256 helper functions
  function [31:0] rotr;
    input [31:0] x;
    input [4:0]  n;
    begin
      rotr = (x >> n) | (x << (32 - n));
    end
  endfunction

  function [31:0] ch_func;
    input [31:0] x, y, z;
    begin
      ch_func = (x & y) ^ (~x & z);
    end
  endfunction

  function [31:0] maj_func;
    input [31:0] x, y, z;
    begin
      maj_func = (x & y) ^ (x & z) ^ (y & z);
    end
  endfunction

  function [31:0] big_sigma0;
    input [31:0] x;
    begin
      big_sigma0 = rotr(x, 5'd2) ^ rotr(x, 5'd13) ^ rotr(x, 5'd22);
    end
  endfunction

  function [31:0] big_sigma1;
    input [31:0] x;
    begin
      big_sigma1 = rotr(x, 5'd6) ^ rotr(x, 5'd11) ^ rotr(x, 5'd25);
    end
  endfunction

  function [31:0] small_sigma0;
    input [31:0] x;
    begin
      small_sigma0 = rotr(x, 5'd7) ^ rotr(x, 5'd18) ^ (x >> 3);
    end
  endfunction

  function [31:0] small_sigma1;
    input [31:0] x;
    begin
      small_sigma1 = rotr(x, 5'd17) ^ rotr(x, 5'd19) ^ (x >> 10);
    end
  endfunction

  // State machine
  localparam ST_IDLE       = 3'd0;
  localparam ST_PREPROCESS = 3'd1;
  localparam ST_COMPUTE    = 3'd2;
  localparam ST_FINALIZE   = 3'd3;
  localparam ST_DONE       = 3'd4;

  reg [2:0]  state;
  reg [31:0] H0 [0:7];
  reg [31:0] H  [0:7];
  reg [31:0] W  [0:63];
  reg [31:0] a, b, c, d, e, f, g, h;
  reg [6:0]  round;
  reg [511:0] msg_block_reg;
  reg [255:0] digest_reg;
  reg        done_reg;
  reg        msg_ready_reg;
  reg        last_block;

  // Initial hash values
  initial begin
    H0[0] = 32'h6a09e667; H0[1] = 32'hbb67ae85;
    H0[2] = 32'h3c6ef372; H0[3] = 32'ha54ff53a;
    H0[4] = 32'h510e527f; H0[5] = 32'h9b05688c;
    H0[6] = 32'h1f83d9ab; H0[7] = 32'h5be0cd19;
  end

  // Combinational outputs
  assign digest     = digest_reg;
  assign done       = done_reg;
  assign msg_ready  = msg_ready_reg;

  // SHA-256 compression - one round per cycle
  integer i;
  reg [31:0] t1, t2, w_new;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state          <= ST_IDLE;
      round          <= 7'd0;
      digest_reg     <= 256'd0;
      done_reg       <= 1'b0;
      msg_ready_reg  <= 1'b0;
      last_block     <= 1'b0;
      for (i = 0; i < 8; i = i + 1)
        H[i] <= H0[i];
    end else begin
      done_reg <= 1'b0;
      case (state)
        ST_IDLE: begin
          msg_ready_reg <= 1'b1;
          if (start) begin
            for (i = 0; i < 8; i = i + 1)
              H[i] <= H0[i];
            msg_ready_reg <= 1'b0;
            state <= ST_PREPROCESS;
          end
        end

        ST_PREPROCESS: begin
          if (msg_valid && msg_ready_reg) begin
            msg_block_reg <= msg_data;
            last_block    <= msg_last;
            msg_ready_reg  <= 1'b0;
            a <= H[0]; b <= H[1]; c <= H[2]; d <= H[3];
            e <= H[4]; f <= H[5]; g <= H[6]; h <= H[7];
            round <= 7'd0;
            state <= ST_COMPUTE;
          end else begin
            msg_ready_reg <= 1'b1;
          end
        end

        ST_COMPUTE: begin
          if (round < 64) begin
            // Message schedule
            if (round < 16) begin
              // Big-endian word extraction from 512-bit block
              // Word 0 = bytes[0..3] = msg_block[511:480]
              // Word i = msg_block >> (512 - (i+1)*32), truncated to 32 bits
              w_new = msg_block_reg >> (512 - (round + 1) * 32);
            end else begin
              w_new = W[round-16] + small_sigma0(W[round-15]) +
                      W[round-7] + small_sigma1(W[round-2]);
            end
            W[round] <= w_new;

            // Compression
            t1 = h + big_sigma1(e) + ch_func(e, f, g) + k_round(round[5:0]) + w_new;
            t2 = big_sigma0(a) + maj_func(a, b, c);
            h  <= g;
            g  <= f;
            f  <= e;
            e  <= d + t1;
            d  <= c;
            c  <= b;
            b  <= a;
            a  <= t1 + t2;

            round <= round + 1;
          end else begin
            H[0] <= H[0] + a;
            H[1] <= H[1] + b;
            H[2] <= H[2] + c;
            H[3] <= H[3] + d;
            H[4] <= H[4] + e;
            H[5] <= H[5] + f;
            H[6] <= H[6] + g;
            H[7] <= H[7] + h;
            state <= ST_FINALIZE;
          end
        end

        ST_FINALIZE: begin
          // Assert done for every block completion
          done_reg <= 1'b1;
          if (last_block) begin
            // No more blocks — output the digest
            digest_reg <= {H[0], H[1], H[2], H[3], H[4], H[5], H[6], H[7]};
            state <= ST_IDLE;
            msg_ready_reg <= 1'b1;
          end else begin
            // More blocks to come — accept next block
            msg_ready_reg <= 1'b1;
            state <= ST_PREPROCESS;
          end
        end

        default: state <= ST_IDLE;
      endcase
    end
  end

endmodule
