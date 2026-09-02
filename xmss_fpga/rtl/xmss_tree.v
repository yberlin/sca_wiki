// =============================================================================
// xmss_tree.v
// =============================================================================
// XMSS Merkle Tree Engine - pure Verilog-2001 RTL.
//
// Implements: L-tree, RAND_HASH, Merkle tree hash.
//
// tree_mode: 0=L-tree (compute one leaf), 1=Merkle tree (compute root)
//
// Hash engine interface: wide-bus (key[511:0], msg[511:0], msg_len[7:0]).
//
// IP Usage: None. Pure RTL.
// =============================================================================

`timescale 1ns / 1ps

module xmss_tree (
  input         clk,
  input         rst_n,

  // Configuration
  input  [1:0]  hash_type,
  input  [7:0]  n,
  input  [7:0]  w,
  input  [7:0]  h,
  input  [7:0]  wots_len1,
  input  [7:0]  wots_len2,
  input  [15:0] wots_len,

  // Tree mode: 0=L-tree, 1=Merkle tree
  input         tree_mode,
  input  [7:0]  leaf_idx,

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
  output        addr_set_ltree_addr,
  output [31:0] ltree_addr_out,
  output        addr_set_tree_height,
  output [31:0] tree_height_out,
  output        addr_set_tree_index,
  output [31:0] tree_index_out,
  output        addr_set_key_and_mask,
  output [31:0] key_and_mask_out,
  input  [255:0] addr_current,

  // Memory interface
  output        mem_wr,
  output        mem_rd,
  output [15:0] mem_addr,
  output [511:0] mem_wr_data,
  input  [511:0] mem_rd_data,

  // Inputs
  input  [511:0] seed,
  output [511:0] root
);

  // States (6-bit for up to 64 states)
  localparam T_IDLE             = 6'd0;
  localparam T_LT_INIT          = 6'd1;
  localparam T_LT_RD_L          = 6'd2;
  localparam T_LT_RD_L_WAIT     = 6'd3;
  localparam T_LT_RD_L_CAP      = 6'd4;
  localparam T_LT_CHECK_R       = 6'd5;
  localparam T_LT_RD_R          = 6'd6;
  localparam T_LT_RD_R_WAIT     = 6'd7;
  localparam T_LT_RD_R_CAP      = 6'd8;
  // Shared rand_hash states
  localparam T_RH_ADDR          = 6'd9;
  localparam T_RH_ADDR_WAIT     = 6'd10;
  localparam T_RH_PRF_KEY       = 6'd11;
  localparam T_RH_ADDR_BM0      = 6'd12;
  localparam T_RH_ADDR_BM0_WAIT = 6'd13;
  localparam T_RH_PRF_BM0       = 6'd14;
  localparam T_RH_ADDR_BM1      = 6'd15;
  localparam T_RH_ADDR_BM1_WAIT = 6'd16;
  localparam T_RH_PRF_BM1       = 6'd17;
  localparam T_RH_DO_H          = 6'd18;
  localparam T_RH_H_WAIT        = 6'd19;
  // L-tree store
  localparam T_LT_STORE         = 6'd20;
  localparam T_LT_NEXT          = 6'd21;
  localparam T_LT_NEXT_ODD      = 6'd30;
  localparam T_LT_LEAF_STORE    = 6'd22;
  // Merkle tree
  localparam T_MT_INIT          = 6'd23;
  localparam T_MT_PREP          = 6'd24;
  localparam T_MT_PREP_WAIT     = 6'd28;
  localparam T_MT_STORE         = 6'd25;
  localparam T_MT_STORE_WAIT    = 6'd29;
  localparam T_MT_NEXT          = 6'd26;
  localparam T_FINISH           = 6'd27;

  reg [5:0]  state;
  reg [5:0]  return_state;  // Where to go after T_RH_H_WAIT
  reg        done_reg;
  reg [1:0]  hash_func_sel_reg;
  reg        hash_start_reg;
  reg [511:0] hash_key_reg;
  reg [1023:0] hash_msg_reg;
  reg [7:0]  hash_msg_len_reg;
  reg        addr_set_type_reg;
  reg [31:0] addr_type_val_reg;
  reg        addr_set_ltree_addr_reg;
  reg [31:0] ltree_addr_reg;
  reg        addr_set_tree_height_reg;
  reg [31:0] tree_height_reg;
  reg        addr_set_tree_index_reg;
  reg [31:0] tree_index_reg;
  reg        addr_set_key_and_mask_reg;
  reg [31:0] key_and_mask_reg;
  reg [511:0] root_reg;

  // BRAM interface registers
  reg        mem_wr_reg;
  reg        mem_rd_reg;
  reg [15:0] mem_addr_reg;
  reg [511:0] mem_wr_data_reg;

  // L-tree variables
  reg [7:0]  lt_level;
  reg [7:0]  lt_count;
  reg [7:0]  lt_elem_idx;

  // Merkle tree variables
  reg [7:0]  mt_level;
  reg [7:0]  mt_node_idx;
  reg [7:0]  mt_count;
  reg [11:0] mt_rd_addr;   // Read address for tree_nodes
  reg [11:0] mt_wr_addr;   // Write address for tree_nodes
  reg [11:0] mt_base;      // Base address for current level (level * 2^h)

  // Tree node storage (for Merkle tree)
  // Layout: each level L starts at base L*2^h, with 2^(h-L) nodes.
  // L0: [0 .. 2^h-1], L1: [2^h .. 2^h+2^(h-1)-1], etc.
  // For h=10: L0=[0..1023], L1=[1024..1535], ..., L10=[2048..2048] — fits in 2048.
  // For h=4:  L0=[0..15], L1=[16..23], L2=[24..27], L3=[28..29], L4=[30].
  reg [511:0] tree_nodes [0:2047];

  // rand_hash working storage
  reg [511:0] rh_key;
  reg [511:0] rh_bm0;
  reg [511:0] rh_bm1;
  reg [511:0] left_val;
  reg [511:0] right_val;
  reg [511:0] hash_result;

  assign done                  = done_reg;
  assign hash_func_sel         = hash_func_sel_reg;
  assign hash_start            = hash_start_reg;
  assign hash_key               = hash_key_reg;
  assign hash_msg               = hash_msg_reg;
  assign hash_msg_len           = hash_msg_len_reg;
  assign addr_set_type         = addr_set_type_reg;
  assign addr_type_val         = addr_type_val_reg;
  assign addr_set_ltree_addr   = addr_set_ltree_addr_reg;
  assign ltree_addr_out        = ltree_addr_reg;
  assign addr_set_tree_height  = addr_set_tree_height_reg;
  assign tree_height_out       = tree_height_reg;
  assign addr_set_tree_index   = addr_set_tree_index_reg;
  assign tree_index_out        = tree_index_reg;
  assign addr_set_key_and_mask = addr_set_key_and_mask_reg;
  assign key_and_mask_out      = key_and_mask_reg;
  assign root                  = root_reg;
  assign mem_wr                = mem_wr_reg;
  assign mem_rd                = mem_rd_reg;
  assign mem_addr              = mem_addr_reg;
  assign mem_wr_data            = mem_wr_data_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state                   <= T_IDLE;
      done_reg                <= 1'b0;
      hash_start_reg          <= 1'b0;
      hash_func_sel_reg       <= 2'b00;
      hash_key_reg            <= 512'd0;
      hash_msg_reg            <= 1024'd0;
      hash_msg_len_reg        <= 8'd0;
      root_reg                <= 512'd0;
      mem_wr_reg              <= 1'b0;
      mem_rd_reg              <= 1'b0;
      addr_set_type_reg       <= 1'b0;
      addr_set_ltree_addr_reg <= 1'b0;
      addr_set_tree_height_reg <= 1'b0;
      addr_set_tree_index_reg <= 1'b0;
      addr_set_key_and_mask_reg <= 1'b0;
      mt_rd_addr               <= 12'd0;
      mt_wr_addr               <= 12'd0;
      mt_base                  <= 12'd0;
    end else begin
      // Default: clear pulse signals
      done_reg               <= 1'b0;
      hash_start_reg         <= 1'b0;
      mem_wr_reg             <= 1'b0;
      mem_rd_reg             <= 1'b0;
      addr_set_type_reg      <= 1'b0;
      addr_set_ltree_addr_reg <= 1'b0;
      addr_set_tree_height_reg <= 1'b0;
      addr_set_tree_index_reg <= 1'b0;
      addr_set_key_and_mask_reg <= 1'b0;

      case (state)
        T_IDLE: begin
          if (start) begin
            if (tree_mode) begin
              // Merkle tree mode
              mt_level    <= 8'd0;
              mt_node_idx <= 8'd0;
              mt_count    <= 8'd1 << h; // 2^h
              mt_base     <= 12'd0;     // Level 0 starts at address 0
              addr_set_type_reg  <= 1'b1;
              addr_type_val_reg  <= 32'd2; // Hash tree type
              state <= T_MT_INIT;
            end else begin
              // L-tree mode
              lt_level    <= 8'd0;
              lt_count    <= wots_len[7:0];
              lt_elem_idx <= 8'd0;
              addr_set_type_reg  <= 1'b1;
              addr_type_val_reg  <= 32'd1; // L-tree type
              addr_set_ltree_addr_reg <= 1'b1;
              ltree_addr_reg  <= {24'd0, leaf_idx};
              state <= T_LT_INIT;
            end
          end
        end

        // ---- L-tree phase ----
        T_LT_INIT: begin
          lt_elem_idx <= 8'd0;
          state <= T_LT_RD_L;
        end

        // Read left value from BRAM
        T_LT_RD_L: begin
          mem_rd_reg  <= 1'b1;
          mem_addr_reg <= {8'd0, lt_elem_idx};
          state <= T_LT_RD_L_WAIT;
        end

        T_LT_RD_L_WAIT: begin
          state <= T_LT_RD_L_CAP;
        end

        T_LT_RD_L_CAP: begin
          left_val <= mem_rd_data;
          state <= T_LT_CHECK_R;
        end

        // Check if right element exists
        T_LT_CHECK_R: begin
          if (lt_elem_idx + 8'd1 < lt_count) begin
            state <= T_LT_RD_R;
          end else begin
            // Odd node: C reference pulls it up to next layer without hashing.
            // Copy left_val to position lt_elem_idx/2 directly.
            mem_wr_reg    <= 1'b1;
            mem_addr_reg  <= {8'd0, lt_elem_idx[7:1]};
            mem_wr_data_reg <= left_val;
            state <= T_LT_NEXT_ODD;
          end
        end

        // Read right value from BRAM
        T_LT_RD_R: begin
          mem_rd_reg  <= 1'b1;
          mem_addr_reg <= {8'd0, lt_elem_idx + 8'd1};
          state <= T_LT_RD_R_WAIT;
        end

        T_LT_RD_R_WAIT: begin
          state <= T_LT_RD_R_CAP;
        end

        T_LT_RD_R_CAP: begin
          right_val <= mem_rd_data;
          return_state <= T_LT_STORE;
          state <= T_RH_ADDR;
        end

        // ---- Shared rand_hash states ----
        T_RH_ADDR: begin
          if (tree_mode) begin
            // Merkle tree
            addr_set_tree_height_reg <= 1'b1;
            tree_height_reg  <= {24'd0, mt_level};
            addr_set_tree_index_reg  <= 1'b1;
            tree_index_reg   <= {24'd0, mt_node_idx[7:1]};
          end else begin
            // L-tree
            addr_set_tree_height_reg <= 1'b1;
            tree_height_reg  <= {24'd0, lt_level};
            addr_set_tree_index_reg  <= 1'b1;
            tree_index_reg   <= {24'd0, lt_elem_idx[7:1]};
          end
          addr_set_key_and_mask_reg <= 1'b1;
          key_and_mask_reg <= 32'd0;
          state <= T_RH_ADDR_WAIT;
        end

        T_RH_ADDR_WAIT: begin
          state <= T_RH_PRF_KEY;
        end

        // PRF for key (key_and_mask=0)
        T_RH_PRF_KEY: begin
          hash_func_sel_reg <= 2'b11; // PRF
          hash_key_reg      <= seed;
          hash_msg_reg      <= {768'd0, addr_current};
          hash_msg_len_reg  <= 8'd32;
          hash_start_reg    <= 1'b1;
          state             <= T_RH_ADDR_BM0;
        end

        // PRF key done, set key_and_mask=1 for bm0
        T_RH_ADDR_BM0: begin
          if (hash_done) begin
            rh_key <= hash_digest;
            addr_set_key_and_mask_reg <= 1'b1;
            key_and_mask_reg <= 32'd1;
            state <= T_RH_ADDR_BM0_WAIT;
          end
        end

        T_RH_ADDR_BM0_WAIT: begin
          state <= T_RH_PRF_BM0;
        end

        // PRF for bm0 (key_and_mask=1)
        T_RH_PRF_BM0: begin
          hash_func_sel_reg <= 2'b11; // PRF
          hash_key_reg      <= seed;
          hash_msg_reg      <= {768'd0, addr_current};
          hash_msg_len_reg  <= 8'd32;
          hash_start_reg    <= 1'b1;
          state             <= T_RH_ADDR_BM1;
        end

        // PRF bm0 done, set key_and_mask=2 for bm1
        T_RH_ADDR_BM1: begin
          if (hash_done) begin
            rh_bm0 <= hash_digest;
            addr_set_key_and_mask_reg <= 1'b1;
            key_and_mask_reg <= 32'd2;
            state <= T_RH_ADDR_BM1_WAIT;
          end
        end

        T_RH_ADDR_BM1_WAIT: begin
          state <= T_RH_PRF_BM1;
        end

        // PRF for bm1 (key_and_mask=2)
        T_RH_PRF_BM1: begin
          hash_func_sel_reg <= 2'b11; // PRF
          hash_key_reg      <= seed;
          hash_msg_reg      <= {768'd0, addr_current};
          hash_msg_len_reg  <= 8'd32;
          hash_start_reg    <= 1'b1;
          state             <= T_RH_DO_H;
        end

        // PRF bm1 done, XOR and start H
        T_RH_DO_H: begin
          if (hash_done) begin
            rh_bm1 <= hash_digest;
            hash_key_reg <= rh_key;
            // hash_engine extracts: msg_buf[2n+k] = msg[(msg_len-1-k)*8 +: 8]
            // For msg_len=2*n=64, k=0..63 reads msg[511:0] (low 512 bits only).
            // After two reversal stages (extract then build_block), block1 = msg[511:0].
            // Python: H(key, lx + rx) => block1 must be lx(big-endian) || rx(big-endian).
            // So msg[511:256] = lx, msg[255:0] = rx.
            // Registers hold n=32B data in [255:0]; XOR on part-selects first.
            hash_msg_reg <= {512'd0,
                             left_val[255:0] ^ rh_bm0[255:0],
                             right_val[255:0] ^ hash_digest[255:0]};
            hash_msg_len_reg <= {n[6:0], 1'b0}; // 2*n bytes
            hash_func_sel_reg <= 2'b01; // H
            hash_start_reg    <= 1'b1;
            state             <= T_RH_H_WAIT;
          end
        end

        T_RH_H_WAIT: begin
          if (hash_done) begin
            hash_result <= hash_digest;
            state <= return_state;
          end
        end

        // ---- L-tree store ----
        T_LT_STORE: begin
          mem_wr_reg    <= 1'b1;
          mem_addr_reg  <= {8'd0, lt_elem_idx[7:1]};
          mem_wr_data_reg <= hash_result;
          state <= T_LT_NEXT;
        end

        T_LT_NEXT: begin
          lt_elem_idx <= lt_elem_idx + 8'd2;
          if (lt_elem_idx + 8'd2 < lt_count) begin
            // More pairs in this level
            state <= T_LT_RD_L;
          end else begin
            // Level done
            lt_count <= (lt_count + 8'd1) >> 1; // ceil(count/2)
            lt_level <= lt_level + 8'd1;
            if ((lt_count + 8'd1) >> 1 > 8'd1) begin
              state <= T_LT_INIT;
            end else begin
              // L-tree done, leaf = hash_result
              state <= T_LT_LEAF_STORE;
            end
          end
        end

        // Handle odd node: we already copied it, now check level transition
        T_LT_NEXT_ODD: begin
          lt_count <= (lt_count + 8'd1) >> 1; // ceil(count/2)
          lt_level <= lt_level + 8'd1;
          if ((lt_count + 8'd1) >> 1 > 8'd1) begin
            state <= T_LT_INIT;
          end else begin
            // L-tree done, leaf = left_val (the pulled-up node)
            hash_result <= left_val;
            state <= T_LT_LEAF_STORE;
          end
        end

        T_LT_LEAF_STORE: begin
          tree_nodes[leaf_idx[9:0]] <= hash_result;
          root_reg <= hash_result; // Also output as root (for standalone L-tree test)
          done_reg <= 1'b1;
          state <= T_IDLE;
        end

        // ---- Merkle tree phase ----
        T_MT_INIT: begin
          if (mt_level < h) begin
            mt_node_idx <= 8'd0;
            // Update base for this level: prev_base + prev_count
            // On first entry (level=0), mt_base is already 0.
            // On subsequent entries, mt_base was updated in T_MT_NEXT.
            state <= T_MT_PREP;
          end else begin
            // Root is at mt_wr_addr (set during last T_MT_STORE)
            root_reg <= tree_nodes[mt_wr_addr];
            done_reg <= 1'b1;
            state <= T_IDLE;
          end
        end

        T_MT_PREP: begin
          // Read address = mt_base + mt_node_idx (current level's base + index)
          mt_rd_addr <= mt_base + {4'b0000, mt_node_idx};
          state <= T_MT_PREP_WAIT;
        end

        T_MT_PREP_WAIT: begin
          // Now mt_rd_addr is valid; read left and right from tree_nodes
          left_val  <= tree_nodes[mt_rd_addr];
          right_val <= tree_nodes[mt_rd_addr + 1];
          return_state <= T_MT_STORE;
          state <= T_RH_ADDR;
        end

        T_MT_STORE: begin
          // Write address = mt_base + mt_count + mt_node_idx/2
          // (next level's base = mt_base + mt_count, then offset by node_idx/2)
          mt_wr_addr <= mt_base + {4'b0000, mt_count} + {4'b0000, mt_node_idx[7:1]};
          state <= T_MT_STORE_WAIT;
        end

        T_MT_STORE_WAIT: begin
          // Now mt_wr_addr is valid; write hash_result to tree_nodes
          tree_nodes[mt_wr_addr] <= hash_result;
          state <= T_MT_NEXT;
        end

        T_MT_NEXT: begin
          if (mt_node_idx + 8'd2 < mt_count) begin
            mt_node_idx <= mt_node_idx + 8'd2;
            state <= T_MT_PREP;
          end else begin
            // Level done: advance base to next level's start
            mt_base  <= mt_base + {4'b0000, mt_count};
            mt_count <= mt_count >> 1;
            mt_level <= mt_level + 8'd1;
            state <= T_MT_INIT;
          end
        end

        T_FINISH: begin
          done_reg <= 1'b1;
          state    <= T_IDLE;
        end

        default: state <= T_IDLE;
      endcase
    end
  end

endmodule
