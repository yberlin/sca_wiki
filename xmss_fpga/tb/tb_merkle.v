// =============================================================================
// tb_merkle.v
// =============================================================================
// Merkle tree testbench: load 16 pre-computed leaves into tree_nodes[0..15],
// run xmss_tree in Merkle mode (tree_mode=1), compare root with Python golden.
//
// IP Usage: Testbench only. Not synthesizable.
// =============================================================================

`timescale 1ns / 1ps

`include "xmss_params.vh"

module tb_merkle;

  reg         clk;
  reg         rst_n;
  reg  [1:0]  hash_type;
  reg  [7:0]  n;
  reg  [7:0]  w;
  reg  [7:0]  h;
  reg  [7:0]  wots_len1;
  reg  [7:0]  wots_len2;
  reg  [15:0] wots_len;
  reg         tree_mode;
  reg  [7:0]  leaf_idx;
  reg         start;
  wire        done;

  // Hash engine interface
  wire [1:0]  hash_func_sel;
  wire        hash_start;
  wire [511:0] hash_key;
  wire [1023:0] hash_msg;
  wire [7:0]  hash_msg_len;
  wire [511:0] hash_digest;
  wire        hash_done;

  // Address interface
  wire        addr_set_type;
  wire [31:0] addr_type_val;
  wire        addr_set_ltree_addr;
  wire [31:0] ltree_addr_out;
  wire        addr_set_tree_height;
  wire [31:0] tree_height_out;
  wire        addr_set_tree_index;
  wire [31:0] tree_index_out;
  wire        addr_set_key_and_mask;
  wire [31:0] key_and_mask_out;
  wire [255:0] addr;

  reg         addr_clear;

  // Memory interface (unused in Merkle mode, but required by port)
  wire        mem_wr;
  wire        mem_rd;
  wire [15:0] mem_addr;
  wire [511:0] mem_wr_data;
  wire [511:0] mem_rd_data;

  reg  [511:0] seed;
  wire [511:0] root;

  integer test_pass, test_fail;
  integer cnt;
  integer i;

  initial clk = 0;
  always #5 clk = ~clk;

  // DUT
  xmss_tree DUT (
    .clk(clk), .rst_n(rst_n),
    .hash_type(hash_type), .n(n), .w(w), .h(h),
    .wots_len1(wots_len1), .wots_len2(wots_len2), .wots_len(wots_len),
    .tree_mode(tree_mode), .leaf_idx(leaf_idx),
    .start(start), .done(done),
    .hash_func_sel(hash_func_sel), .hash_start(hash_start),
    .hash_key(hash_key), .hash_msg(hash_msg), .hash_msg_len(hash_msg_len),
    .hash_digest(hash_digest), .hash_done(hash_done),
    .addr_set_type(addr_set_type), .addr_type_val(addr_type_val),
    .addr_set_ltree_addr(addr_set_ltree_addr), .ltree_addr_out(ltree_addr_out),
    .addr_set_tree_height(addr_set_tree_height), .tree_height_out(tree_height_out),
    .addr_set_tree_index(addr_set_tree_index), .tree_index_out(tree_index_out),
    .addr_set_key_and_mask(addr_set_key_and_mask), .key_and_mask_out(key_and_mask_out),
    .addr_current(addr),
    .mem_wr(mem_wr), .mem_rd(mem_rd), .mem_addr(mem_addr),
    .mem_wr_data(mem_wr_data), .mem_rd_data(mem_rd_data),
    .seed(seed), .root(root)
  );

  // Address manager
  xmss_address u_addr (
    .clk(clk), .rst_n(rst_n), .addr(addr), .clear(addr_clear),
    .set_type(addr_set_type), .type_val(addr_type_val),
    .set_ots_addr(1'b0), .ots_addr(32'd0),
    .set_ltree_addr(addr_set_ltree_addr), .ltree_addr(ltree_addr_out),
    .set_chain_addr(1'b0), .chain_addr(32'd0),
    .set_hash_addr(1'b0), .hash_addr(32'd0),
    .set_tree_height(addr_set_tree_height), .tree_height(tree_height_out),
    .set_tree_index(addr_set_tree_index), .tree_index(tree_index_out),
    .set_key_and_mask(addr_set_key_and_mask), .key_and_mask(key_and_mask_out)
  );

  // Hash engine
  hash_engine u_hash (
    .clk(clk), .rst_n(rst_n), .hash_type(hash_type), .n_bytes(n),
    .func_sel(hash_func_sel), .key(hash_key), .msg(hash_msg), .msg_len(hash_msg_len),
    .start(hash_start), .digest(hash_digest), .done(hash_done)
  );

  // BRAM (unused in Merkle mode, but instantiated for completeness)
  xmss_bram u_bram (
    .clk(clk),
    .wr_en(mem_wr), .wr_addr(mem_addr), .wr_data(mem_wr_data),
    .rd_en(mem_rd), .rd_addr(mem_addr), .rd_data(mem_rd_data)
  );

  // Load golden leaves
  reg [255:0] golden_leaves [0:15];
  reg [255:0] expected_root;

  initial begin
    $readmemh("sim/hex/tree_SHA2_n32_leaves.hex", golden_leaves);

    rst_n = 0;
    hash_type = `HASH_SHA2;
    n = 8'd32; w = 8'd16; h = 8'd4;
    wots_len1 = 8'd64; wots_len2 = 8'd3; wots_len = 16'd67;
    tree_mode = 1'b1; // Merkle tree mode
    leaf_idx = 8'd0;
    start = 0; seed = 512'd0;
    addr_clear = 0;
    test_pass = 0; test_fail = 0;
    cnt = 0;

    repeat(5) @(posedge clk); rst_n = 1; repeat(3) @(posedge clk);

    $display("========================================");
    $display("Merkle Tree Testbench (SHA2 n=32 h=4)");
    $display("========================================");

    // Set pub_seed
    seed = {256'd0, 256'h202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f};

    // Preload 16 leaves into tree_nodes[0..15] (Merkle tree level 0)
    for (i = 0; i < 16; i = i + 1) begin
      DUT.tree_nodes[i] = {256'd0, golden_leaves[i]};
    end

    $display("Loaded 16 leaves into tree_nodes");
    $display("  leaf[0]  = %h", DUT.tree_nodes[0][255:0]);
    $display("  leaf[15] = %h", DUT.tree_nodes[15][255:0]);

    // Expected root
    expected_root = 256'he87dd61b5891253fa39c45a55786787a9ea117f8432ebbb2cf5f9bfc84336c89;
    $display("  expected root = %h", expected_root);

    // Clear address
    addr_clear = 1;
    @(posedge clk);
    addr_clear = 0;
    @(posedge clk);

    // Start Merkle tree
    @(posedge clk); start = 1;
    @(posedge clk); start = 0;

    // Wait for done
    cnt = 0;
    while (!done && cnt < 500000) begin
      @(posedge clk);
      cnt = cnt + 1;
      // Print tree_nodes at each T_MT_INIT (level transition)
      if (DUT.state == 6'd23 && cnt > 1) begin
        $display("  [%0d] T_MT_INIT: ml=%d mc=%d wra=%d", cnt, DUT.mt_level, DUT.mt_count, DUT.mt_wr_addr);
        case (DUT.mt_level)
          8'd1: $display("    tn[0]=%h tn[1]=%h tn[2]=%h tn[3]=%h tn[4]=%h tn[5]=%h tn[6]=%h tn[7]=%h tn[8]=%h",
                     DUT.tree_nodes[0][255:0], DUT.tree_nodes[1][255:0], DUT.tree_nodes[2][255:0],
                     DUT.tree_nodes[3][255:0], DUT.tree_nodes[4][255:0], DUT.tree_nodes[5][255:0],
                     DUT.tree_nodes[6][255:0], DUT.tree_nodes[7][255:0], DUT.tree_nodes[8][255:0]);
          8'd2: $display("    tn[1]=%h tn[2]=%h tn[3]=%h tn[4]=%h tn[5]=%h tn[6]=%h tn[7]=%h tn[8]=%h",
                     DUT.tree_nodes[1][255:0], DUT.tree_nodes[2][255:0], DUT.tree_nodes[3][255:0],
                     DUT.tree_nodes[4][255:0], DUT.tree_nodes[5][255:0], DUT.tree_nodes[6][255:0],
                     DUT.tree_nodes[7][255:0], DUT.tree_nodes[8][255:0]);
          8'd3: $display("    tn[3]=%h tn[4]=%h tn[5]=%h tn[6]=%h tn[7]=%h tn[8]=%h",
                     DUT.tree_nodes[3][255:0], DUT.tree_nodes[4][255:0], DUT.tree_nodes[5][255:0],
                     DUT.tree_nodes[6][255:0], DUT.tree_nodes[7][255:0], DUT.tree_nodes[8][255:0]);
        endcase
      end
      if (DUT.state == 6'd29) begin
        $display("  [%0d] STORE: ml=%d mi=%d wra=%d hr=%h", cnt, DUT.mt_level, DUT.mt_node_idx, DUT.mt_wr_addr, DUT.hash_result[255:0]);
      end
    end

    if (cnt >= 500000) begin
      $display("  TIMEOUT: state=%d", DUT.state);
      test_fail = test_fail + 1;
    end else begin
      $display("  Completed in %0d cycles", cnt);
      $display("  root result = %h", root[255:0]);
      $display("  root expect = %h", expected_root);
      if (root[255:0] === expected_root) begin
        $display("  PASS");
        test_pass = test_pass + 1;
      end else begin
        $display("  FAIL");
        test_fail = test_fail + 1;
      end
    end

    $display("========================================");
    $display("Summary: %0d passed, %0d failed", test_pass, test_fail);
    $display("========================================");
    if (test_fail == 0) $display("ALL TESTS PASSED");
    else $display("SOME TESTS FAILED");

    repeat(10) @(posedge clk);
    $finish;
  end

  initial begin
    #10000000;
    $display("ERROR: Global timeout");
    $finish;
  end

endmodule
