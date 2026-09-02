// =============================================================================
// wots_plus.v
// =============================================================================
// WOTS+ core for XMSS - pure Verilog-2001 RTL.
//
// Implements: genPK, sign, pkFromSig.
//
// Hash engine interface: wide-bus (key[511:0], msg[511:0], msg_len[7:0]).
//
// IP Usage: None. Pure RTL.
// =============================================================================

`timescale 1ns / 1ps

module wots_plus (
  input         clk,
  input         rst_n,

  // Configuration (resolved from OID)
  input  [1:0]  hash_type,
  input  [7:0]  n,
  input  [7:0]  w,
  input  [7:0]  h,
  input  [7:0]  wots_len1,
  input  [7:0]  wots_len2,
  input  [15:0] wots_len,

  // Mode: 0=genPK, 1=sign, 2=pkFromSig
  input  [1:0]  mode,

  // Control
  input         start,
  output        done,

  // Hash engine interface (wide-bus)
  output [1:0]  hash_func_sel,
  output        hash_start,
  output [511:0] hash_key,
  output [1023:0] hash_msg,
  output [7:0]  hash_msg_len,
  input  [511:0] hash_digest,
  input         hash_done,

  // Address interface
  output        addr_set_type,
  output [31:0] addr_type_val,
  output        addr_set_chain_addr,
  output [31:0] addr_chain_addr,
  output        addr_set_hash_addr,
  output [31:0] addr_hash_addr,
  output        addr_set_key_and_mask,
  output [31:0] addr_key_and_mask,
  input  [255:0] addr_current,

  // Memory interface (BRAM)
  output        mem_wr,
  output        mem_rd,
  output [15:0] mem_addr,
  output [511:0] mem_wr_data,
  input  [511:0] mem_rd_data,

  // Inputs
  input  [511:0] seed,
  input  [511:0] msg_digest
);

  // States
  localparam W_IDLE           = 5'd0;
  localparam W_BASEW_INIT    = 5'd1;
  localparam W_BASEW_PROCESS = 5'd2;
  localparam W_CSUM_CALC     = 5'd3;
  localparam W_CHAIN_PREP    = 5'd4;
  localparam W_CHAIN_WAIT_RD = 5'd5;  // Wait 1 cycle for BRAM read data
  localparam W_CHAIN_LOAD    = 5'd6;  // Capture data, decide next
  localparam W_ADDR_SETUP    = 5'd7;  // Set addr signals (NBA, takes effect next cycle)
  localparam W_ADDR_WAIT     = 5'd13; // Wait 1 cycle for addr manager to update addr_current
  localparam W_HASH_START    = 5'd8;  // Now addr_current is valid; start hash
  localparam W_HASH_WAIT     = 5'd9;  // Wait for hash_done
  localparam W_STORE_RESULT  = 5'd10;
  localparam W_NEXT_CHAIN    = 5'd11;
  localparam W_FINISH        = 5'd12;

  // Sub-modes for W_ADDR_SETUP / W_HASH_START
  localparam SUB_PRF_KEY  = 2'd0;
  localparam SUB_PRF_MASK = 2'd1;
  localparam SUB_F        = 2'd2;

  reg [4:0]  state;
  reg        done_reg;
  reg [1:0]  hash_func_sel_reg;
  reg        hash_start_reg;
  reg [511:0] hash_key_reg;
  reg [1023:0] hash_msg_reg;
  reg [7:0]  hash_msg_len_reg;
  reg        mem_wr_reg;
  reg        mem_rd_reg;
  reg [15:0] mem_addr_reg;
  reg [511:0] mem_wr_data_reg;
  reg        addr_set_type_reg;
  reg [31:0] addr_type_val_reg;
  reg        addr_set_chain_addr_reg;
  reg [31:0] addr_chain_addr_reg;
  reg        addr_set_hash_addr_reg;
  reg [31:0] addr_hash_addr_reg;
  reg        addr_set_key_and_mask_reg;
  reg [31:0] addr_key_and_mask_reg;

  // Working storage
  reg [7:0]  basew_digits [0:130];
  reg [15:0] csum;
  reg [7:0]  chain_idx;
  reg [7:0]  chain_step;
  reg [7:0]  target_step;
  reg [511:0] chain_val;     // current chain value
  reg [511:0] prf_key;       // PRF output used as key
  reg [511:0] prf_mask;      // PRF output used as mask
  reg [7:0]  basew_byte_idx;
  reg [7:0]  basew_out_idx;
  reg [1:0]  hash_sub;       // which hash operation we're doing

  assign done                   = done_reg;
  assign hash_func_sel          = hash_func_sel_reg;
  assign hash_start             = hash_start_reg;
  assign hash_key               = hash_key_reg;
  assign hash_msg               = hash_msg_reg;
  assign hash_msg_len           = hash_msg_len_reg;
  assign mem_wr                 = mem_wr_reg;
  assign mem_rd                 = mem_rd_reg;
  assign mem_addr               = mem_addr_reg;
  assign mem_wr_data            = mem_wr_data_reg;
  assign addr_set_type          = addr_set_type_reg;
  assign addr_type_val          = addr_type_val_reg;
  assign addr_set_chain_addr    = addr_set_chain_addr_reg;
  assign addr_chain_addr        = addr_chain_addr_reg;
  assign addr_set_hash_addr     = addr_set_hash_addr_reg;
  assign addr_hash_addr         = addr_hash_addr_reg;
  assign addr_set_key_and_mask  = addr_set_key_and_mask_reg;
  assign addr_key_and_mask      = addr_key_and_mask_reg;

  integer i;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state                   <= W_IDLE;
      done_reg                <= 1'b0;
      hash_start_reg          <= 1'b0;
      hash_func_sel_reg       <= 2'b00;
      hash_key_reg            <= 512'd0;
      hash_msg_reg            <= 1024'd0;
      hash_msg_len_reg        <= 8'd0;
      mem_wr_reg              <= 1'b0;
      mem_rd_reg              <= 1'b0;
      chain_idx               <= 8'd0;
      chain_step              <= 8'd0;
      csum                    <= 16'd0;
      addr_set_type_reg       <= 1'b0;
      addr_set_chain_addr_reg <= 1'b0;
      addr_set_hash_addr_reg  <= 1'b0;
      addr_set_key_and_mask_reg <= 1'b0;
    end else begin
      done_reg               <= 1'b0;
      hash_start_reg         <= 1'b0;
      mem_wr_reg             <= 1'b0;
      mem_rd_reg             <= 1'b0;
      addr_set_type_reg      <= 1'b0;
      addr_set_chain_addr_reg <= 1'b0;
      addr_set_hash_addr_reg <= 1'b0;
      addr_set_key_and_mask_reg <= 1'b0;

      case (state)
        W_IDLE: begin
          if (start) begin
            chain_idx       <= 8'd0;
            csum            <= 16'd0;
            basew_byte_idx  <= 8'd0;
            basew_out_idx   <= 8'd0;
            state           <= W_BASEW_INIT;
          end
        end

        W_BASEW_INIT: begin
          state <= W_BASEW_PROCESS;
        end

        W_BASEW_PROCESS: begin
          if (basew_out_idx < wots_len1) begin
            basew_digits[basew_out_idx]   <= msg_digest[basew_byte_idx*8 +: 4];
            basew_digits[basew_out_idx+1] <= msg_digest[basew_byte_idx*8+4 +: 4];
            csum           <= csum + (16 - msg_digest[basew_byte_idx*8 +: 4]) +
                                    (16 - msg_digest[basew_byte_idx*8+4 +: 4]);
            basew_out_idx  <= basew_out_idx + 2;
            basew_byte_idx <= basew_byte_idx + 1;
          end else begin
            state <= W_CSUM_CALC;
          end
        end

        W_CSUM_CALC: begin
          basew_digits[wots_len1]   <= csum[15:12];
          basew_digits[wots_len1+1] <= csum[11:8];
          basew_digits[wots_len1+2] <= csum[7:4];
          chain_idx <= 8'd0;
          state     <= W_CHAIN_PREP;
        end

        W_CHAIN_PREP: begin
          if (chain_idx < wots_len[7:0]) begin
            addr_set_chain_addr_reg <= 1'b1;
            addr_chain_addr_reg     <= {24'd0, chain_idx};
            chain_step              <= 8'd0;

            case (mode)
              2'b00: target_step <= w - 1;
              2'b01: target_step <= basew_digits[chain_idx];
              2'b10: target_step <= (w - 1) - basew_digits[chain_idx];
              default: target_step <= w - 1;
            endcase

            mem_rd_reg  <= 1'b1;
            mem_addr_reg <= {8'd0, chain_idx};
            state       <= W_CHAIN_WAIT_RD;
          end else begin
            state <= W_FINISH;
          end
        end

        W_CHAIN_WAIT_RD: begin
          // BRAM read data is now valid
          state <= W_CHAIN_LOAD;
        end

        W_CHAIN_LOAD: begin
          chain_val <= mem_rd_data;
          if (target_step == 8'd0) begin
            state <= W_STORE_RESULT;
          end else begin
            hash_sub <= SUB_PRF_KEY;
            state <= W_ADDR_SETUP;
          end
        end

        // Set address signals (hash_addr, key_and_mask). These are NBAs,
        // so addr manager sees them at the NEXT clock edge, then updates
        // addr_current one cycle after that. We need W_ADDR_WAIT to let
        // addr_current settle before W_HASH_START captures it.
        W_ADDR_SETUP: begin
          addr_set_hash_addr_reg    <= 1'b1;
          addr_hash_addr_reg        <= {24'd0, chain_step};
          addr_set_key_and_mask_reg <= 1'b1;
          case (hash_sub)
            SUB_PRF_KEY:  addr_key_and_mask_reg <= 32'd0;
            SUB_PRF_MASK: addr_key_and_mask_reg <= 32'd1;
            default:      addr_key_and_mask_reg <= 32'd0;
          endcase
          state <= W_ADDR_WAIT;
        end

        W_ADDR_WAIT: begin
          // addr_current now reflects updated hash_addr and key_and_mask
          state <= W_HASH_START;
        end
        W_HASH_START: begin
          case (hash_sub)
            SUB_PRF_KEY, SUB_PRF_MASK: begin
              hash_func_sel_reg <= 2'b11; // PRF
              hash_key_reg      <= seed;
              hash_msg_reg      <= {768'd0, addr_current};
              hash_msg_len_reg  <= 8'd32;
            end
            SUB_F: begin
              hash_func_sel_reg <= 2'b00; // F
              hash_key_reg      <= prf_key;
              hash_msg_reg      <= chain_val ^ prf_mask;
              hash_msg_len_reg  <= n;
            end
            default: ;
          endcase
          hash_start_reg <= 1'b1;
          state          <= W_HASH_WAIT;
        end

        W_HASH_WAIT: begin
          if (hash_done) begin
            case (hash_sub)
              SUB_PRF_KEY: begin
                prf_key  <= hash_digest;
                hash_sub <= SUB_PRF_MASK;
                state    <= W_ADDR_SETUP;
              end
              SUB_PRF_MASK: begin
                prf_mask <= hash_digest;
                hash_sub <= SUB_F;
                state    <= W_HASH_START; // F doesn't need new addr — skip W_ADDR_SETUP
              end
              SUB_F: begin
                chain_val <= hash_digest;
                // chain does `target_step` iterations (0..target_step-1).
                // After processing step chain_step, if chain_step+1 < target_step,
                // continue; otherwise stop. This matches Python's range(0, steps).
                if (chain_step + 8'd1 < target_step) begin
                  chain_step <= chain_step + 1;
                  hash_sub   <= SUB_PRF_KEY;
                  state      <= W_ADDR_SETUP;
                end else begin
                  state <= W_STORE_RESULT;
                end
              end
              default: ;
            endcase
          end
        end

        W_STORE_RESULT: begin
          mem_wr_reg    <= 1'b1;
          mem_addr_reg  <= {8'd0, chain_idx};
          mem_wr_data_reg <= chain_val;
          state <= W_NEXT_CHAIN;
        end

        W_NEXT_CHAIN: begin
          chain_idx <= chain_idx + 1;
          state     <= W_CHAIN_PREP;
        end

        W_FINISH: begin
          done_reg <= 1'b1;
          state    <= W_IDLE;
        end

        default: state <= W_IDLE;
      endcase
    end
  end

endmodule
