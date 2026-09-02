// =============================================================================
// shake_core.v
// =============================================================================
// SHAKE128 / SHAKE256 sponge construction - pure Verilog-2001 RTL.
// Uses keccak_round.v for the permutation.
//
// Absorbs byte-stream input, applies SHAKE padding, squeezes output.
//
// IP Usage: None. Pure RTL.
// =============================================================================

`timescale 1ns / 1ps

module shake_core (
  input         clk,
  input         rst_n,

  // Data input (byte-stream)
  input  [7:0]  din_data,
  input         din_valid,
  output        din_ready,

  // Control
  input         start,
  input         absorb_done,
  input  [15:0] output_bits,
  input  [7:0]  n_bytes,

  // Output
  output [511:0] digest,
  output        done
);

  localparam RATE_SHAKE128 = 168;  // bytes
  localparam RATE_SHAKE256 = 136;  // bytes

  localparam SK_IDLE    = 3'd0;
  localparam SK_ABSORB  = 3'd1;
  localparam SK_PAD     = 3'd2;
  localparam SK_KSTART  = 3'd3;
  localparam SK_PERMUTE = 3'd4;
  localparam SK_SQUEEZE = 3'd5;
  localparam SK_DONE    = 3'd6;

  reg [2:0]   state;
  reg [1599:0] sponge_state;
  reg [1599:0] keccak_in;
  wire [1599:0] keccak_out;
  wire         keccak_done;
  reg          keccak_start;
  reg [8:0]    absorb_byte_cnt;
  reg [8:0]    rate_bytes;
  reg [511:0] digest_reg;
  reg         done_reg;
  reg         din_ready_reg;
  reg         last_byte_captured;
  reg [7:0]   last_byte_val;
  integer     sq_i;

  assign digest    = digest_reg;
  assign done      = done_reg;
  assign din_ready = din_ready_reg;

  keccak_round u_keccak (
    .clk       (clk),
    .rst_n     (rst_n),
    .start     (keccak_start),
    .done      (keccak_done),
    .state_in  (keccak_in),
    .state_out (keccak_out)
  );

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state           <= SK_IDLE;
      sponge_state    <= 1600'd0;
      keccak_in       <= 1600'd0;
      keccak_start    <= 1'b0;
      absorb_byte_cnt <= 9'd0;
      rate_bytes      <= 9'd136;
      digest_reg      <= 512'd0;
      done_reg        <= 1'b0;
      din_ready_reg   <= 1'b0;
      last_byte_captured <= 1'b0;
      last_byte_val   <= 8'd0;
    end else begin
      done_reg     <= 1'b0;
      keccak_start <= 1'b0;

      case (state)
        SK_IDLE: begin
          if (start) begin
            sponge_state    <= 1600'd0;
            absorb_byte_cnt <= 9'd0;
            if (output_bits > 16'd256)
              rate_bytes <= 9'd168;
            else
              rate_bytes <= 9'd136;
            din_ready_reg   <= 1'b1;
            last_byte_captured <= 1'b0;
            state           <= SK_ABSORB;
          end
        end

        SK_ABSORB: begin
          if (din_valid && din_ready_reg && !last_byte_captured) begin
            // XOR input byte into sponge state
            sponge_state[absorb_byte_cnt*8 +: 8] <=
              sponge_state[absorb_byte_cnt*8 +: 8] ^ din_data;
            absorb_byte_cnt <= absorb_byte_cnt + 1;

            // Check if we need to permute (rate boundary)
            if (absorb_byte_cnt == rate_bytes - 1) begin
              din_ready_reg <= 1'b0;
              state <= SK_PAD;
            end
          end

          if (absorb_done && !din_valid) begin
            // No more data coming
            din_ready_reg <= 1'b0;
            state         <= SK_PAD;
          end
        end

        SK_PAD: begin
          // Apply SHAKE padding: 0x1F at current byte position,
          // 0x80 at last byte of rate portion
          // Use blocking assignment so keccak_in sees the padded state
          sponge_state[absorb_byte_cnt*8 +: 8] =
            sponge_state[absorb_byte_cnt*8 +: 8] ^ 8'h1F;
          sponge_state[(rate_bytes-1)*8 +: 8] =
            sponge_state[(rate_bytes-1)*8 +: 8] ^ 8'h80;

          state        <= SK_KSTART;
        end

        SK_KSTART: begin
          // Now sponge_state has the padding applied — capture it
          keccak_in    <= sponge_state;
          keccak_start <= 1'b1;
          state        <= SK_PERMUTE;
        end

        SK_PERMUTE: begin
          if (keccak_done) begin
            sponge_state <= keccak_out;
            absorb_byte_cnt <= 9'd0;
            state <= SK_SQUEEZE;
          end
        end

        SK_SQUEEZE: begin
          // Keccak state is little-endian: byte 0 at sponge_state[7:0].
          // SHAKE output byte 0 = sponge_state[7:0], byte 1 = sponge_state[15:8], etc.
          // The digest bus is big-endian: output byte 0 goes to digest[n_bits-1 -: 8].
          // So we need to reverse the byte order.
          case (n_bytes)
            8'd24: begin
              for (sq_i = 0; sq_i < 24; sq_i = sq_i + 1)
                digest_reg[(23-sq_i)*8 +: 8] <= sponge_state[sq_i*8 +: 8];
              digest_reg[511:192] <= 320'd0;
            end
            8'd32: begin
              for (sq_i = 0; sq_i < 32; sq_i = sq_i + 1)
                digest_reg[(31-sq_i)*8 +: 8] <= sponge_state[sq_i*8 +: 8];
              digest_reg[511:256] <= 256'd0;
            end
            8'd64: begin
              for (sq_i = 0; sq_i < 64; sq_i = sq_i + 1)
                digest_reg[(63-sq_i)*8 +: 8] <= sponge_state[sq_i*8 +: 8];
            end
            default: begin
              for (sq_i = 0; sq_i < 32; sq_i = sq_i + 1)
                digest_reg[(31-sq_i)*8 +: 8] <= sponge_state[sq_i*8 +: 8];
              digest_reg[511:256] <= 256'd0;
            end
          endcase
          done_reg <= 1'b1;
          state    <= SK_DONE;
        end

        SK_DONE: begin
          state         <= SK_IDLE;
          din_ready_reg <= 1'b1;
        end

        default: state <= SK_IDLE;
      endcase
    end
  end

endmodule
