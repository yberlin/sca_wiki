// =============================================================================
// hash_engine.v
// =============================================================================
// Hash Engine Abstraction Layer for XMSS - pure Verilog-2001 RTL.
//
// Provides F, H, H_msg, PRF via SHA-256 or SHAKE128/256.
//
// Interface: key and msg are provided as wide buses. On `start`, the engine
// constructs prefix(n) || key(n) || msg(msg_len), pads for SHA-256 or feeds
// raw to SHAKE, and produces the digest.
//
// IP Usage: None. Pure RTL (instantiates sha256_core.v and shake_core.v).
// =============================================================================

`timescale 1ns / 1ps

module hash_engine (
  input         clk,
  input         rst_n,

  // Configuration
  input  [1:0]  hash_type,    // 0=SHA2, 1=SHAKE128, 2=SHAKE256
  input  [7:0]  n_bytes,
  input  [1:0]  func_sel,     // 0=F, 1=H, 2=H_msg, 3=PRF

  // Key and message (wide buses, LSB-aligned)
  // key: up to n bytes (32 or 64)
  // msg: up to 2*n bytes (64 or 128) for H function
  input  [511:0] key,
  input  [1023:0] msg,
  input  [7:0]  msg_len,      // number of msg bytes

  // Control
  input         start,

  // Output
  output [511:0] digest,
  output        done
);

  // SHA-256 instance
  reg         sha2_start;
  reg         sha2_msg_valid;
  reg  [511:0] sha2_msg_data;
  reg         sha2_msg_last;
  wire        sha2_msg_ready;
  wire [255:0] sha2_digest;
  wire        sha2_done;

  sha256_core u_sha256 (
    .clk(clk), .rst_n(rst_n),
    .msg_data(sha2_msg_data), .msg_valid(sha2_msg_valid),
    .msg_last(sha2_msg_last), .msg_ready(sha2_msg_ready),
    .start(sha2_start), .n_bytes(n_bytes),
    .digest(sha2_digest), .done(sha2_done)
  );

  // SHAKE instance
  reg         shake_start;
  reg         shake_absorb_done;
  reg  [7:0]  shake_din_data;
  reg         shake_din_valid;
  wire [511:0] shake_digest;
  wire        shake_done;

  shake_core u_shake (
    .clk(clk), .rst_n(rst_n),
    .din_data(shake_din_data), .din_valid(shake_din_valid),
    .din_ready(), .start(shake_start), .absorb_done(shake_absorb_done),
    .output_bits(hash_type == 2'b01 ? 16'd257 : 16'd256), .n_bytes(n_bytes),
    .digest(shake_digest), .done(shake_done)
  );

  // Output
  reg [511:0] digest_reg;
  reg        done_reg;
  assign digest = digest_reg;
  assign done   = done_reg;

  // Message byte buffer: prefix || key || msg (up to 256 bytes)
  reg [7:0] msg_buf [0:255];

  // FSM states
  localparam HE_IDLE   = 4'd0;
  localparam HE_SETUP  = 4'd1;
  localparam HE_SHA2_S = 4'd2;  // SHA2 send block (hold valid until accepted)
  localparam HE_SHA2_W = 4'd3;  // SHA2 wait for block done
  localparam HE_SHA2_N = 4'd4;  // SHA2 next block or finish
  localparam HE_SK_ABS = 4'd5;  // SHAKE absorb
  localparam HE_SK_WT  = 4'd6;  // SHAKE wait for done
  localparam HE_DONE   = 4'd7;

  reg [3:0]  he_state;
  reg [15:0] data_len;       // total data bytes (prefix+key+msg)
  reg [15:0] bit_len;        // data_len * 8
  reg [1:0]  blk_idx;        // current block index
  reg [1:0]  num_blks;       // total number of blocks
  reg [15:0] shake_idx;      // byte index for SHAKE feeding

  integer k;
  reg [7:0] prefix_val;

  always @(*) begin
    case (func_sel)
      2'b00: prefix_val = 8'h00;
      2'b01: prefix_val = 8'h01;
      2'b10: prefix_val = 8'h02;
      2'b11: prefix_val = 8'h03;
      default: prefix_val = 8'h00;
    endcase
  end

  // Build a single 512-bit block from msg_buf
  function [511:0] build_block;
    input [1:0] blk;
    input [15:0] dbytes;
    input [15:0] blen;
    input       is_last;
    reg [7:0] b;
    integer j;
    reg [15:0] abs_idx;
    reg [63:0] blen64;
    begin
      blen64 = {48'd0, blen};  // zero-extend to 64 bits
      build_block = 512'd0;
      for (j = 0; j < 64; j = j + 1) begin
        abs_idx = blk * 64 + j;
        if (abs_idx < dbytes) begin
          b = msg_buf[abs_idx[7:0]];
        end else if (abs_idx == dbytes) begin
          b = 8'h80;
        end else if (is_last && j >= 56) begin
          case (j - 56)
            0:  b = blen64[63:56];
            1:  b = blen64[55:48];
            2:  b = blen64[47:40];
            3:  b = blen64[39:32];
            4:  b = blen64[31:24];
            5:  b = blen64[23:16];
            6:  b = blen64[15:8];
            7:  b = blen64[7:0];
            default: b = 8'h00;
          endcase
        end else begin
          b = 8'h00;
        end
        build_block[511 - j*8 -: 8] = b;
      end
    end
  endfunction

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      he_state        <= HE_IDLE;
      sha2_start      <= 1'b0;
      sha2_msg_valid  <= 1'b0;
      sha2_msg_last   <= 1'b0;
      sha2_msg_data   <= 512'd0;
      shake_start     <= 1'b0;
      shake_absorb_done <= 1'b0;
      shake_din_data  <= 8'd0;
      shake_din_valid <= 1'b0;
      digest_reg      <= 512'd0;
      done_reg        <= 1'b0;
      blk_idx         <= 2'd0;
      num_blks        <= 2'd0;
      data_len        <= 16'd0;
      bit_len         <= 16'd0;
      shake_idx       <= 16'd0;
    end else begin
      // Default: clear pulse signals (but NOT sha2_msg_valid — handled per-state)
      done_reg       <= 1'b0;
      sha2_start     <= 1'b0;
      shake_start    <= 1'b0;
      shake_absorb_done <= 1'b0;
      shake_din_valid <= 1'b0;

      case (he_state)
        HE_IDLE: begin
          sha2_msg_valid <= 1'b0;
          if (start) begin
            he_state <= HE_SETUP;
          end
        end

        HE_SETUP: begin
          // Calculate data length and bit length
          data_len <= n_bytes + n_bytes + msg_len;
          bit_len  <= (n_bytes + n_bytes + msg_len) * 8;

          // Fill msg_buf: prefix || key || msg (blocking assignment for immediate effect)
          // prefix = toByte(prefix_val, n_bytes) = big-endian, value in last byte
          for (k = 0; k < 64; k = k + 1) begin
            if (k < n_bytes) begin
              if (k == n_bytes - 1)
                msg_buf[k] = prefix_val;  // last byte of prefix = value
              else
                msg_buf[k] = 8'h00;
            end
          end
          for (k = 0; k < 64; k = k + 1) begin
            if (k < n_bytes)
              msg_buf[n_bytes + k] = key[(n_bytes - 1 - k)*8 +: 8];
          end
          // msg can be up to 128 bytes (2*n for H function)
          for (k = 0; k < 128; k = k + 1) begin
            if (k < msg_len)
              msg_buf[2*n_bytes + k] = msg[(msg_len - 1 - k)*8 +: 8];
          end

          blk_idx <= 2'd0;
          num_blks <= (n_bytes + n_bytes + msg_len + 16'd72) >> 6;

          if (hash_type == 2'b00) begin
            sha2_start <= 1'b1;
            he_state   <= HE_SHA2_S;
          end else begin
            shake_start <= 1'b1;
            shake_idx   <= 16'd0;
            he_state    <= HE_SK_ABS;
          end
        end

        // ---- SHA-256 path: hold msg_valid until accepted ----
        HE_SHA2_S: begin
          // Keep sha2_msg_valid high; set data on first entry
          if (!sha2_msg_valid) begin
            // First cycle in this state: build and present the block
            sha2_msg_data  <= build_block(blk_idx, data_len, bit_len,
                                         (blk_idx == num_blks - 1));
            sha2_msg_valid <= 1'b1;
            sha2_msg_last  <= (blk_idx == num_blks - 1);
          end

          // Wait until sha256_core accepts the block
          if (sha2_msg_valid && sha2_msg_ready) begin
            // Block accepted — deassert valid and wait for processing
            sha2_msg_valid <= 1'b0;
            he_state       <= HE_SHA2_W;
          end
        end

        HE_SHA2_W: begin
          // Wait for sha256_core to finish processing this block
          if (sha2_done) begin
            if (blk_idx == num_blks - 1) begin
              // Last block done — output result
              digest_reg <= {256'd0, sha2_digest};
              done_reg   <= 1'b1;
              he_state   <= HE_DONE;
            end else begin
              // More blocks to send
              blk_idx  <= blk_idx + 1;
              he_state <= HE_SHA2_S;
            end
          end
        end

        // ---- SHAKE path ----
        HE_SK_ABS: begin
          if (shake_idx < data_len) begin
            shake_din_data  <= msg_buf[shake_idx[7:0]];
            shake_din_valid <= 1'b1;
            shake_idx       <= shake_idx + 1;
          end else begin
            shake_absorb_done <= 1'b1;
            he_state          <= HE_SK_WT;
          end
        end

        HE_SK_WT: begin
          if (shake_done) begin
            digest_reg <= shake_digest;
            done_reg   <= 1'b1;
            he_state   <= HE_DONE;
          end
        end

        HE_DONE: begin
          he_state <= HE_IDLE;
        end

        default: he_state <= HE_IDLE;
      endcase
    end
  end

endmodule
