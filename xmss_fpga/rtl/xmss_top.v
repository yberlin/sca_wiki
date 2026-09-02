// =============================================================================
// xmss_top.v
// =============================================================================
// XMSS Top-Level Module - pure Verilog-2001 RTL.
//
// Configurable: KeyGen / Sign / Verify.
// Hash: SHA-256 (SHA2) or SHAKE128/SHAKE256 (SHA3).
// All RFC 8391 and NIST SP 800-208 parameter sets via OID.
//
// IP Usage Notes:
//   - Hash functions: Pure RTL (sha256_core.v, keccak_round.v, shake_core.v)
//   - BRAM: RTL-inferred (xmss_bram.v). Replace with vendor BRAM IP if needed.
//   - FIFO: RTL-inferred (xmss_fifo.v). Replace with vendor FIFO IP if needed.
// =============================================================================

`timescale 1ns / 1ps

`include "xmss_params.vh"

module xmss_top (
  input         clk,
  input         rst_n,
  input  [31:0] oid,
  input  [1:0]  mode,
  input         start,
  output        done,
  output        error,
  input  [7:0]  din_data,
  input         din_valid,
  output        din_ready,
  output [7:0]  dout_data,
  output        dout_valid,
  input         dout_ready,
  output        ext_mem_wr,
  output        ext_mem_rd,
  output [15:0] ext_mem_addr,
  output [511:0] ext_mem_wr_data,
  input  [511:0] ext_mem_rd_data
);

  // Parameter resolution
  reg  [1:0]  cfg_hash_type;
  reg  [7:0]  cfg_n, cfg_w, cfg_h;
  reg  [7:0]  cfg_wots_len1, cfg_wots_len2;
  reg  [15:0] cfg_wots_len;

  always @(*) begin
    cfg_hash_type = `HASH_SHA2;
    cfg_n = 8'd32; cfg_w = 8'd16; cfg_h = 8'd10;
    cfg_wots_len1 = 8'd64; cfg_wots_len2 = 8'd3; cfg_wots_len = 16'd67;
    case (oid)
      `OID_XMSS_SHA2_10_256, `OID_XMSS_SHA2_16_256, `OID_XMSS_SHA2_20_256: begin
        cfg_hash_type = `HASH_SHA2; cfg_n = 8'd32;
        cfg_wots_len1 = 8'd64; cfg_wots_len = 16'd67; end
      `OID_XMSS_SHA2_10_512, `OID_XMSS_SHA2_16_512, `OID_XMSS_SHA2_20_512: begin
        cfg_hash_type = `HASH_SHA2; cfg_n = 8'd64;
        cfg_wots_len1 = 8'd128; cfg_wots_len = 16'd131; end
      `OID_XMSS_SHA2_10_192, `OID_XMSS_SHA2_16_192, `OID_XMSS_SHA2_20_192: begin
        cfg_hash_type = `HASH_SHA2; cfg_n = 8'd24;
        cfg_wots_len1 = 8'd48; cfg_wots_len = 16'd51; end
      `OID_XMSS_SHAKE_10_256, `OID_XMSS_SHAKE_16_256, `OID_XMSS_SHAKE_20_256: begin
        cfg_hash_type = `HASH_SHAKE128; cfg_n = 8'd32;
        cfg_wots_len1 = 8'd64; cfg_wots_len = 16'd67; end
      `OID_XMSS_SHAKE_10_512, `OID_XMSS_SHAKE_16_512, `OID_XMSS_SHAKE_20_512: begin
        cfg_hash_type = `HASH_SHAKE256; cfg_n = 8'd64;
        cfg_wots_len1 = 8'd128; cfg_wots_len = 16'd131; end
      `OID_XMSS_SHAKE256_10_256, `OID_XMSS_SHAKE256_16_256, `OID_XMSS_SHAKE256_20_256: begin
        cfg_hash_type = `HASH_SHAKE256; cfg_n = 8'd32;
        cfg_wots_len1 = 8'd64; cfg_wots_len = 16'd67; end
      `OID_XMSS_SHAKE256_10_192, `OID_XMSS_SHAKE256_16_192, `OID_XMSS_SHAKE256_20_192: begin
        cfg_hash_type = `HASH_SHAKE256; cfg_n = 8'd24;
        cfg_wots_len1 = 8'd48; cfg_wots_len = 16'd51; end
      default: ;
    endcase
    case (oid)
      `OID_XMSS_SHA2_10_256, `OID_XMSS_SHA2_10_512, `OID_XMSS_SHA2_10_192,
      `OID_XMSS_SHAKE_10_256, `OID_XMSS_SHAKE_10_512,
      `OID_XMSS_SHAKE256_10_256, `OID_XMSS_SHAKE256_10_192: cfg_h = 8'd10;
      `OID_XMSS_SHA2_16_256, `OID_XMSS_SHA2_16_512, `OID_XMSS_SHA2_16_192,
      `OID_XMSS_SHAKE_16_256, `OID_XMSS_SHAKE_16_512,
      `OID_XMSS_SHAKE256_16_256, `OID_XMSS_SHAKE256_16_192: cfg_h = 8'd16;
      `OID_XMSS_SHA2_20_256, `OID_XMSS_SHA2_20_512, `OID_XMSS_SHA2_20_192,
      `OID_XMSS_SHAKE_20_256, `OID_XMSS_SHAKE_20_512,
      `OID_XMSS_SHAKE256_20_256, `OID_XMSS_SHAKE256_20_192: cfg_h = 8'd20;
      default: cfg_h = 8'd10;
    endcase
  end

  // Internal hash engine signals (wide-bus interface)
  reg  [1:0]  h_func_sel; reg  h_start;
  reg  [511:0] h_key; reg [1023:0] h_msg; reg [7:0] h_msg_len;
  wire [511:0] h_digest; wire h_done;

  // Address manager
  wire [255:0] addr;
  reg addr_clear, addr_set_type; reg [31:0] addr_type_val;
  reg addr_set_ots_addr; reg [31:0] ots_addr;
  reg addr_set_ltree_addr; reg [31:0] ltree_addr;
  reg addr_set_chain_addr; reg [31:0] chain_addr;
  reg addr_set_hash_addr; reg [31:0] hash_addr_val;
  reg addr_set_tree_height; reg [31:0] tree_height_val;
  reg addr_set_tree_index; reg [31:0] tree_index_val;
  reg addr_set_key_and_mask; reg [31:0] key_and_mask_val;

  // WOTS+ wires
  wire [1:0]  w_hash_func_sel; wire w_hash_start;
  wire [511:0] w_hash_key; wire [1023:0] w_hash_msg; wire [7:0] w_hash_msg_len;
  wire [511:0] w_hash_digest; wire w_hash_done;
  wire        w_addr_set_type; wire [31:0] w_addr_type_val;
  wire        w_addr_set_chain_addr; wire [31:0] w_addr_chain_addr;
  wire        w_addr_set_hash_addr; wire [31:0] w_addr_hash_addr;
  wire        w_addr_set_key_and_mask; wire [31:0] w_addr_key_and_mask;

  // Tree wires
  wire [1:0]  t_hash_func_sel; wire t_hash_start;
  wire [511:0] t_hash_key; wire [1023:0] t_hash_msg; wire [7:0] t_hash_msg_len;
  wire [511:0] t_hash_digest; wire t_hash_done;
  wire        t_addr_set_type; wire [31:0] t_addr_type_val;
  wire        t_addr_set_ltree_addr; wire [31:0] t_ltree_addr;
  wire        t_addr_set_tree_height; wire [31:0] t_tree_height;
  wire        t_addr_set_tree_index; wire [31:0] t_tree_index;
  wire        t_addr_set_key_and_mask; wire [31:0] t_key_and_mask;
  wire [511:0] t_root;

  // BRAM (driven by WOTS+ module outputs)
  wire bram_wr, bram_rd; wire [15:0] bram_addr;
  wire [511:0] bram_wr_data; wire [511:0] bram_rd_data;

  reg [511:0] seed, msg_digest;
  reg w_start; wire w_done; reg [1:0] w_mode;
  reg t_start; wire t_done; reg [1:0] t_mode;

  // FSM states
  localparam X_IDLE=4'd0, X_INIT=4'd1, X_KEYGEN_WOTS=4'd2, X_KEYGEN_TREE=4'd3;
  localparam X_KEYGEN_DONE=4'd4, X_SIGN_HASH_MSG=4'd5, X_SIGN_WOTS=4'd6;
  localparam X_SIGN_TREE=4'd7, X_SIGN_OUTPUT=4'd8, X_VERIFY_HASH=4'd9;
  localparam X_VERIFY_WOTS=4'd10, X_VERIFY_TREE=4'd11, X_VERIFY_CHECK=4'd12;
  localparam X_DONE=4'd13;

  reg [3:0] xstate; reg done_reg, error_reg, din_ready_reg;
  reg [7:0] dout_data_reg; reg dout_valid_reg;

  assign done = done_reg; assign error = error_reg;
  assign din_ready = din_ready_reg;
  assign dout_data = dout_data_reg; assign dout_valid = dout_valid_reg;
  assign ext_mem_wr = bram_wr; assign ext_mem_rd = bram_rd;
  assign ext_mem_addr = bram_addr; assign ext_mem_wr_data = bram_wr_data;
  assign ext_mem_rd_data = bram_rd_data;

  // Sub-module instances
  xmss_address u_addr (
    .clk(clk), .rst_n(rst_n), .addr(addr), .clear(addr_clear),
    .set_type(addr_set_type), .type_val(addr_type_val),
    .set_ots_addr(addr_set_ots_addr), .ots_addr(ots_addr),
    .set_ltree_addr(addr_set_ltree_addr), .ltree_addr(ltree_addr),
    .set_chain_addr(addr_set_chain_addr), .chain_addr(chain_addr),
    .set_hash_addr(addr_set_hash_addr), .hash_addr(hash_addr_val),
    .set_tree_height(addr_set_tree_height), .tree_height(tree_height_val),
    .set_tree_index(addr_set_tree_index), .tree_index(tree_index_val),
    .set_key_and_mask(addr_set_key_and_mask), .key_and_mask(key_and_mask_val)
  );

  hash_engine u_hash (
    .clk(clk), .rst_n(rst_n), .hash_type(cfg_hash_type), .n_bytes(cfg_n),
    .func_sel(h_func_sel), .key(h_key), .msg(h_msg), .msg_len(h_msg_len),
    .start(h_start), .digest(h_digest), .done(h_done)
  );

  wots_plus u_wots (
    .clk(clk), .rst_n(rst_n), .hash_type(cfg_hash_type), .n(cfg_n),
    .w(cfg_w), .h(cfg_h), .wots_len1(cfg_wots_len1),
    .wots_len2(cfg_wots_len2), .wots_len(cfg_wots_len),
    .mode(w_mode), .start(w_start), .done(w_done),
    .hash_func_sel(w_hash_func_sel), .hash_start(w_hash_start),
    .hash_key(w_hash_key), .hash_msg(w_hash_msg), .hash_msg_len(w_hash_msg_len),
    .hash_digest(w_hash_digest), .hash_done(w_hash_done),
    .addr_set_type(w_addr_set_type), .addr_type_val(w_addr_type_val),
    .addr_set_chain_addr(w_addr_set_chain_addr), .addr_chain_addr(w_addr_chain_addr),
    .addr_set_hash_addr(w_addr_set_hash_addr), .addr_hash_addr(w_addr_hash_addr),
    .addr_set_key_and_mask(w_addr_set_key_and_mask), .addr_key_and_mask(w_addr_key_and_mask),
    .addr_current(addr),
    .mem_wr(bram_wr), .mem_rd(bram_rd), .mem_addr(bram_addr),
    .mem_wr_data(bram_wr_data), .mem_rd_data(bram_rd_data),
    .seed(seed), .msg_digest(msg_digest)
  );

  xmss_tree u_tree (
    .clk(clk), .rst_n(rst_n), .hash_type(cfg_hash_type), .n(cfg_n),
    .w(cfg_w), .h(cfg_h), .wots_len1(cfg_wots_len1),
    .wots_len2(cfg_wots_len2), .wots_len(cfg_wots_len),
    .tree_mode(t_mode[0]), .leaf_idx(ots_addr[7:0]),
    .start(t_start), .done(t_done),
    .hash_func_sel(t_hash_func_sel), .hash_start(t_hash_start),
    .hash_key(t_hash_key), .hash_msg(t_hash_msg), .hash_msg_len(t_hash_msg_len),
    .hash_digest(t_hash_digest), .hash_done(t_hash_done),
    .addr_set_type(t_addr_set_type), .addr_type_val(t_addr_type_val),
    .addr_set_ltree_addr(t_addr_set_ltree_addr), .ltree_addr_out(t_ltree_addr),
    .addr_set_tree_height(t_addr_set_tree_height), .tree_height_out(t_tree_height),
    .addr_set_tree_index(t_addr_set_tree_index), .tree_index_out(t_tree_index),
    .addr_set_key_and_mask(t_addr_set_key_and_mask), .key_and_mask_out(t_key_and_mask),
    .addr_current(addr),
    .mem_wr(), .mem_rd(), .mem_addr(), .mem_wr_data(), .mem_rd_data(bram_rd_data),
    .seed(seed), .root(t_root)
  );

  // Hash/address arbitration: route to WOTS+ or Tree based on state
  always @(*) begin
    h_func_sel = 2'b00; h_start = 1'b0;
    h_key = 512'd0; h_msg = 512'd0; h_msg_len = 8'd0;
    addr_clear = 1'b0;
    addr_set_type = 1'b0; addr_type_val = 32'd0;
    addr_set_ots_addr = 1'b0; ots_addr = 32'd0;
    addr_set_ltree_addr = 1'b0; ltree_addr = 32'd0;
    addr_set_chain_addr = 1'b0; chain_addr = 32'd0;
    addr_set_hash_addr = 1'b0; hash_addr_val = 32'd0;
    addr_set_tree_height = 1'b0; tree_height_val = 32'd0;
    addr_set_tree_index = 1'b0; tree_index_val = 32'd0;
    addr_set_key_and_mask = 1'b0; key_and_mask_val = 32'd0;

    if (xstate == X_KEYGEN_WOTS || xstate == X_SIGN_WOTS || xstate == X_VERIFY_WOTS) begin
      h_func_sel = w_hash_func_sel; h_start = w_hash_start;
      h_key = w_hash_key; h_msg = w_hash_msg; h_msg_len = w_hash_msg_len;
      addr_set_type = w_addr_set_type; addr_type_val = w_addr_type_val;
      addr_set_chain_addr = w_addr_set_chain_addr; chain_addr = w_addr_chain_addr;
      addr_set_hash_addr = w_addr_set_hash_addr; hash_addr_val = w_addr_hash_addr;
      addr_set_key_and_mask = w_addr_set_key_and_mask; key_and_mask_val = w_addr_key_and_mask;
    end else if (xstate == X_KEYGEN_TREE || xstate == X_SIGN_TREE || xstate == X_VERIFY_TREE) begin
      h_func_sel = t_hash_func_sel; h_start = t_hash_start;
      h_key = t_hash_key; h_msg = t_hash_msg; h_msg_len = t_hash_msg_len;
      addr_set_type = t_addr_set_type; addr_type_val = t_addr_type_val;
      addr_set_ltree_addr = t_addr_set_ltree_addr; ltree_addr = t_ltree_addr;
      addr_set_tree_height = t_addr_set_tree_height; tree_height_val = t_tree_height;
      addr_set_tree_index = t_addr_set_tree_index; tree_index_val = t_tree_index;
      addr_set_key_and_mask = t_addr_set_key_and_mask; key_and_mask_val = t_key_and_mask;
    end
  end

  // Main FSM
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      xstate <= X_IDLE; done_reg <= 1'b0; error_reg <= 1'b0;
      din_ready_reg <= 1'b0; dout_valid_reg <= 1'b0;
      w_start <= 1'b0; t_start <= 1'b0; addr_clear <= 1'b0;
      seed <= 512'd0; msg_digest <= 512'd0;
    end else begin
      done_reg <= 1'b0; dout_valid_reg <= 1'b0;
      w_start <= 1'b0; t_start <= 1'b0; addr_clear <= 1'b0;
      case (xstate)
        X_IDLE: if (start) begin addr_clear <= 1'b1; error_reg <= 1'b0; xstate <= X_INIT; end
        X_INIT: case (mode)
          `MODE_KEYGEN: begin w_mode <= 2'b00; w_start <= 1'b1; xstate <= X_KEYGEN_WOTS; end
          `MODE_SIGN: begin h_func_sel <= `HASH_FUNC_HMSG; h_start <= 1'b1; xstate <= X_SIGN_HASH_MSG; end
          `MODE_VERIFY: begin h_func_sel <= `HASH_FUNC_HMSG; h_start <= 1'b1; xstate <= X_VERIFY_HASH; end
          default: ;
        endcase
        X_KEYGEN_WOTS: if (w_done) begin t_mode <= 2'b00; t_start <= 1'b1; xstate <= X_KEYGEN_TREE; end
        X_KEYGEN_TREE: if (t_done) xstate <= X_KEYGEN_DONE;
        X_KEYGEN_DONE: begin done_reg <= 1'b1; xstate <= X_DONE; end
        X_SIGN_HASH_MSG: if (h_done) begin msg_digest <= h_digest; w_mode <= 2'b01; w_start <= 1'b1; xstate <= X_SIGN_WOTS; end
        X_SIGN_WOTS: if (w_done) begin t_mode <= 2'b01; t_start <= 1'b1; xstate <= X_SIGN_TREE; end
        X_SIGN_TREE: if (t_done) xstate <= X_SIGN_OUTPUT;
        X_SIGN_OUTPUT: begin done_reg <= 1'b1; xstate <= X_DONE; end
        X_VERIFY_HASH: if (h_done) begin msg_digest <= h_digest; w_mode <= 2'b10; w_start <= 1'b1; xstate <= X_VERIFY_WOTS; end
        X_VERIFY_WOTS: if (w_done) begin t_mode <= 2'b10; t_start <= 1'b1; xstate <= X_VERIFY_TREE; end
        X_VERIFY_TREE: if (t_done) xstate <= X_VERIFY_CHECK;
        X_VERIFY_CHECK: begin done_reg <= 1'b1; xstate <= X_DONE; end
        X_DONE: xstate <= X_IDLE;
        default: xstate <= X_IDLE;
      endcase
    end
  end

endmodule
