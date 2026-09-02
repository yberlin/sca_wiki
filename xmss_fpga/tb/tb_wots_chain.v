// =============================================================================
// tb_wots_chain.v
// =============================================================================
// Testbench for WOTS+ chain function verification.
// Tests: chain(sk[0], 0, w-1, seed, ADRS) should equal pk[0].
//
// IP Usage: Testbench only. Not synthesizable.
// =============================================================================

`timescale 1ns / 1ps

`include "xmss_params.vh"

module tb_wots_chain;

  reg         clk;
  reg         rst_n;
  reg  [1:0]  hash_type;
  reg  [7:0]  n;
  reg  [7:0]  w;
  reg  [7:0]  h;
  reg  [7:0]  wots_len1;
  reg  [7:0]  wots_len2;
  reg  [15:0] wots_len;
  reg  [1:0]  mode;
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

  // Address interface (driven by WOTS+)
  wire        addr_set_type;
  wire [31:0] addr_type_val;
  wire        addr_set_chain_addr;
  wire [31:0] addr_chain_addr;
  wire        addr_set_hash_addr;
  wire [31:0] addr_hash_addr;
  wire        addr_set_key_and_mask;
  wire [31:0] addr_key_and_mask;
  wire [255:0] addr;

  reg         addr_clear;

  // Memory interface
  wire        mem_wr;
  wire        mem_rd;
  wire [15:0] mem_addr;
  wire [511:0] mem_wr_data;
  wire [511:0] mem_rd_data;

  reg  [511:0] seed;
  reg  [511:0] msg_digest;

  integer test_pass, test_fail;
  integer cnt;

  initial clk = 0;
  always #5 clk = ~clk;

  // DUT
  wots_plus DUT (
    .clk(clk), .rst_n(rst_n),
    .hash_type(hash_type), .n(n), .w(w), .h(h),
    .wots_len1(wots_len1), .wots_len2(wots_len2), .wots_len(wots_len),
    .mode(mode), .start(start), .done(done),
    .hash_func_sel(hash_func_sel), .hash_start(hash_start),
    .hash_key(hash_key), .hash_msg(hash_msg), .hash_msg_len(hash_msg_len),
    .hash_digest(hash_digest), .hash_done(hash_done),
    .addr_set_type(addr_set_type), .addr_type_val(addr_type_val),
    .addr_set_chain_addr(addr_set_chain_addr), .addr_chain_addr(addr_chain_addr),
    .addr_set_hash_addr(addr_set_hash_addr), .addr_hash_addr(addr_hash_addr),
    .addr_set_key_and_mask(addr_set_key_and_mask), .addr_key_and_mask(addr_key_and_mask),
    .addr_current(addr),
    .mem_wr(mem_wr), .mem_rd(mem_rd), .mem_addr(mem_addr),
    .mem_wr_data(mem_wr_data), .mem_rd_data(mem_rd_data),
    .seed(seed), .msg_digest(msg_digest)
  );

  // Address manager (driven solely by WOTS+ outputs)
  xmss_address u_addr (
    .clk(clk), .rst_n(rst_n), .addr(addr), .clear(addr_clear),
    .set_type(addr_set_type), .type_val(addr_type_val),
    .set_ots_addr(1'b0), .ots_addr(32'd0),
    .set_ltree_addr(1'b0), .ltree_addr(32'd0),
    .set_chain_addr(addr_set_chain_addr), .chain_addr(addr_chain_addr),
    .set_hash_addr(addr_set_hash_addr), .hash_addr(addr_hash_addr),
    .set_tree_height(1'b0), .tree_height(32'd0),
    .set_tree_index(1'b0), .tree_index(32'd0),
    .set_key_and_mask(addr_set_key_and_mask), .key_and_mask(addr_key_and_mask)
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

  // Test data
  reg [511:0] sk0;
  reg [511:0] expected_pk0;

  initial begin
    rst_n = 0;
    hash_type = `HASH_SHA2;
    n = 8'd32; w = 8'd16; h = 8'd10;
    wots_len1 = 8'd64; wots_len2 = 8'd3; wots_len = 16'd1;  // Only test chain 0
    mode = 2'b00; start = 0; seed = 512'd0; msg_digest = 512'd0;
    addr_clear = 0;
    test_pass = 0; test_fail = 0;

    sk0 = {256'd0, 256'ha07cbc1c8a54bea1c10680776c031c66be99650c0994b7a4360288c1bfc4b5f8};
    expected_pk0 = {256'd0, 256'h16e47a3d8efab46b39a6fcfa6c017cfd1bb377a7e29b37fff09c1335eaf1a141};

    repeat(5) @(posedge clk); rst_n = 1; repeat(3) @(posedge clk);

    $display("========================================");
    $display("WOTS+ Chain Testbench");
    $display("========================================");

    // Set seed
    seed = {256'd0, 256'h202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f};

    // Set address type to OTS via a manual address operation
    addr_clear = 1;
    @(posedge clk);
    addr_clear = 0;
    // We need to set type to OTS (0) — but WOTS+ module sets type itself
    // Actually, looking at the WOTS+ code, it doesn't set type. It only sets
    // chain_addr, hash_addr, key_and_mask. So we need to set type externally.
    // Let's use the u_addr module directly:
    // Can't do that from here easily. Let's add a workaround: use force.

    // Preload sk[0] into BRAM at address 0
    u_bram.mem[0] = sk0;
    $display("Preloaded sk[0] = %h", u_bram.mem[0][255:0]);
    // Also check it persists after a clock
    @(posedge clk);
    $display("After 1 clk: mem[0] = %h", u_bram.mem[0][255:0]);

    // Force address type to OTS (0)
    // Actually, the address starts at all-zeros after clear, and type=0 is OTS.
    // So we don't need to set anything! Type is already 0.

    // Start WOTS+ in genPK mode (mode=0, chain 0 to w-1=15)
    mode = 2'b00;
    @(posedge clk); start = 1;
    @(posedge clk); start = 0;

    // Wait for done with debug
    cnt = 0;
    while (!done && cnt < 500000) begin
      @(posedge clk);
      cnt = cnt + 1;
      if (cnt <= 300 || cnt % 5000 == 0) begin
        $display("  [%0d] ws=%d ci=%d cs=%d tgt=%d hd=%b hs=%b he=%d ss=%d r=%d d=%b cv=%h pk=%h pm=%h",
                 cnt, DUT.state, DUT.chain_idx, DUT.chain_step, DUT.target_step, hash_done, hash_start, u_hash.he_state, u_hash.u_sha256.state, u_hash.u_sha256.round, done, DUT.chain_val[255:0], DUT.prf_key[255:0], DUT.prf_mask[255:0]);
      end
    end

    if (cnt >= 500000) begin
      $display("  TIMEOUT: wots state=%d", DUT.state);
      $display("  chain_idx=%d chain_step=%d", DUT.chain_idx, DUT.chain_step);
      test_fail = test_fail + 1;
    end else begin
      // Read result from BRAM
      @(posedge clk);
      $display("  pk[0] result  = %h", u_bram.mem[0][255:0]);
      $display("  pk[0] expected= %h", expected_pk0[255:0]);
      if (u_bram.mem[0][255:0] === expected_pk0[255:0]) begin
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
    #50000000;
    $display("ERROR: Global timeout");
    $finish;
  end

endmodule
