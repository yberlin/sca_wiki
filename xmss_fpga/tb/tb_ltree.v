// =============================================================================
// tb_ltree.v
// =============================================================================
// L-tree testbench: compute L-tree from WOTS+ pk[0..66] and compare with
// Python golden vector leaf_0.
//
// IP Usage: Testbench only. Not synthesizable.
// =============================================================================

`timescale 1ns / 1ps

`include "xmss_params.vh"

module tb_ltree;

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

  // Memory interface
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

  // BRAM
  xmss_bram u_bram (
    .clk(clk),
    .wr_en(mem_wr), .wr_addr(mem_addr), .wr_data(mem_wr_data),
    .rd_en(mem_rd), .rd_addr(mem_addr), .rd_data(mem_rd_data)
  );

  // Expected leaf
  reg [255:0] expected_leaf;
  reg [255:0] pk_mem [0:70];

  initial begin
    // Load golden vectors
    $readmemh("sim/hex/tree_pk0.hex", pk_mem);

    rst_n = 0;
    hash_type = `HASH_SHA2;
    n = 8'd32; w = 8'd16; h = 8'd4;
    wots_len1 = 8'd64; wots_len2 = 8'd3; wots_len = 16'd67;
    tree_mode = 1'b0; // L-tree mode
    leaf_idx = 8'd0;
    start = 0; seed = 512'd0;
    addr_clear = 0;
    test_pass = 0; test_fail = 0;
    cnt = 0;

    repeat(5) @(posedge clk); rst_n = 1; repeat(3) @(posedge clk);

    $display("========================================");
    $display("L-Tree Testbench (SHA2 n=32)");
    $display("========================================");

    // Set pub_seed
    seed = {256'd0, 256'h202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f};

    // Preload pk[0..66] into BRAM
    for (i = 0; i < 67; i = i + 1) begin
      u_bram.mem[i] = {256'd0, pk_mem[i]};
    end

    $display("Loaded 67 pk values into BRAM");
    $display("  pk[0]  = %h", u_bram.mem[0][255:0]);
    $display("  pk[66] = %h", u_bram.mem[66][255:0]);

    // Read expected leaf
    expected_leaf = 256'h311a4d9262ba7230891dacdc13b6f84fd444ff1ca80f51f25978c8f2d6a78c43;
    $display("  expected leaf_0 = %h", expected_leaf);

    // Clear address
    addr_clear = 1;
    @(posedge clk);
    addr_clear = 0;
    @(posedge clk);

    // Start L-tree
    @(posedge clk); start = 1;
    @(posedge clk); start = 0;

    // Wait for done
    cnt = 0;
    while (!done && cnt < 500000) begin
      @(posedge clk);
      cnt = cnt + 1;
      // Debug: print key transitions
      if (cnt <= 700 || cnt % 50000 == 0) begin
        $display("  [%0d] s=%d le=%d lc=%d li=%d hd=%b hs=%b he=%d ss=%d r=%d mv=%b ml=%b lv=%h rv=%h hr=%h rhk=%h rhb0=%h rhb1=%h hm=%h hml=%d hfs=%d",
                 cnt, DUT.state, DUT.lt_level, DUT.lt_count, DUT.lt_elem_idx,
                 hash_done, hash_start, u_hash.he_state, u_hash.u_sha256.state, u_hash.u_sha256.round,
                 u_hash.sha2_msg_valid, u_hash.sha2_msg_ready,
                 DUT.left_val[255:0], DUT.right_val[255:0], DUT.hash_result[255:0],
                 DUT.rh_key[255:0], DUT.rh_bm0[255:0], DUT.rh_bm1[255:0],
                 hash_msg[1023:512], hash_msg[511:0], hash_msg_len, hash_func_sel);
      end
    end

    if (cnt >= 500000) begin
      $display("  TIMEOUT: state=%d", DUT.state);
      test_fail = test_fail + 1;
    end else begin
      $display("  Completed in %0d cycles", cnt);
      $display("  leaf result = %h", root[255:0]);
      $display("  leaf expect = %h", expected_leaf);
      if (root[255:0] === expected_leaf) begin
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
