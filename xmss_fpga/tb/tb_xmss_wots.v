// =============================================================================
// tb_xmss_wots.v
// =============================================================================
// Testbench for WOTS+ core - Verilog-2001.
// IP Usage: Testbench only. Not synthesizable.
// =============================================================================

`timescale 1ns / 1ps

`include "xmss_params.vh"

module tb_xmss_wots;

  reg         clk, rst_n;
  reg  [1:0]  hash_type, mode;
  reg  [7:0]  n, w, h, wots_len1, wots_len2;
  reg  [15:0] wots_len;
  reg         start;
  wire        done;

  wire [1:0]  hash_func_sel; wire hash_start; wire [7:0] hash_n_bytes;
  wire [7:0]  hash_din; wire hash_din_valid; wire hash_din_ready;
  wire        hash_data_done; wire [511:0] hash_digest; wire hash_done;

  wire        addr_set_type; wire [31:0] addr_type_val;
  wire        addr_set_chain_addr; wire [31:0] addr_chain_addr;
  wire        addr_set_hash_addr; wire [31:0] addr_hash_addr;
  wire        addr_set_key_and_mask; wire [31:0] addr_key_and_mask;
  wire [255:0] addr_current;

  wire        mem_wr, mem_rd; wire [15:0] mem_addr;
  wire [511:0] mem_wr_data; wire [511:0] mem_rd_data;

  reg [511:0] seed, msg_digest;

  integer test_pass, test_fail, i;
  integer cycle_cnt;

  initial clk = 0;
  always #5 clk = ~clk;

  wots_plus DUT (
    .clk(clk), .rst_n(rst_n), .hash_type(hash_type), .n(n),
    .w(w), .h(h), .wots_len1(wots_len1), .wots_len2(wots_len2),
    .wots_len(wots_len), .mode(mode), .start(start), .done(done),
    .hash_func_sel(hash_func_sel), .hash_start(hash_start),
    .hash_n_bytes(hash_n_bytes), .hash_din(hash_din),
    .hash_din_valid(hash_din_valid), .hash_din_ready(hash_din_ready),
    .hash_data_done(hash_data_done), .hash_digest(hash_digest),
    .hash_done(hash_done),
    .addr_set_type(addr_set_type), .addr_type_val(addr_type_val),
    .addr_set_chain_addr(addr_set_chain_addr), .addr_chain_addr(addr_chain_addr),
    .addr_set_hash_addr(addr_set_hash_addr), .addr_hash_addr(addr_hash_addr),
    .addr_set_key_and_mask(addr_set_key_and_mask), .addr_key_and_mask(addr_key_and_mask),
    .addr_current(addr_current),
    .mem_wr(mem_wr), .mem_rd(mem_rd), .mem_addr(mem_addr),
    .mem_wr_data(mem_wr_data), .mem_rd_data(mem_rd_data),
    .seed(seed), .msg_digest(msg_digest)
  );

  xmss_address u_addr_tb (
    .clk(clk), .rst_n(rst_n), .addr(addr_current), .clear(1'b0),
    .set_type(addr_set_type), .type_val(addr_type_val),
    .set_ots_addr(1'b0), .ots_addr(32'd0),
    .set_ltree_addr(1'b0), .ltree_addr(32'd0),
    .set_chain_addr(addr_set_chain_addr), .chain_addr(addr_chain_addr),
    .set_hash_addr(addr_set_hash_addr), .hash_addr(addr_hash_addr),
    .set_tree_height(1'b0), .tree_height(32'd0),
    .set_tree_index(1'b0), .tree_index(32'd0),
    .set_key_and_mask(addr_set_key_and_mask), .key_and_mask(addr_key_and_mask)
  );

  xmss_bram u_bram_tb (
    .clk(clk), .wr_en(mem_wr), .wr_addr(mem_addr),
    .wr_data(mem_wr_data), .rd_en(mem_rd), .rd_addr(mem_addr),
    .rd_data(mem_rd_data)
  );

  // Timeout watchdog
  always @(posedge clk) begin
    if (cycle_cnt > 200000) begin
      $display("  ERROR: timeout");
      test_fail = test_fail + 1;
      $finish;
    end
    cycle_cnt = cycle_cnt + 1;
  end

  initial begin
    rst_n = 0;
    hash_type = `HASH_SHA2; n = 8'd32; w = 8'd16; h = 8'd10;
    wots_len1 = 8'd64; wots_len2 = 8'd3; wots_len = 16'd67;
    mode = 2'b00; start = 0; seed = 512'd0; msg_digest = 512'd0;
    test_pass = 0; test_fail = 0; cycle_cnt = 0;

    for (i = 0; i < 32; i = i + 1) seed[i*8 +: 8] = i;
    for (i = 0; i < 32; i = i + 1) msg_digest[i*8 +: 8] = i + 32;

    repeat(5) @(posedge clk); rst_n = 1; repeat(3) @(posedge clk);

    $display("========================================");
    $display("XMSS WOTS+ Testbench");
    $display("========================================");

    // Test 1: genPK
    $display("Test 1: WOTS+ genPK (SHA2, n=32)");
    mode = 2'b00; cycle_cnt = 0;
    @(posedge clk); start = 1; @(posedge clk); start = 0;
    @(done);
    $display("  genPK completed"); test_pass = test_pass + 1;

    // Test 2: sign
    $display("Test 2: WOTS+ sign (SHA2, n=32)");
    mode = 2'b01; cycle_cnt = 0;
    @(posedge clk); start = 1; @(posedge clk); start = 0;
    @(done);
    $display("  sign completed"); test_pass = test_pass + 1;

    // Test 3: pkFromSig
    $display("Test 3: WOTS+ pkFromSig (SHA2, n=32)");
    mode = 2'b10; cycle_cnt = 0;
    @(posedge clk); start = 1; @(posedge clk); start = 0;
    @(done);
    $display("  pkFromSig completed"); test_pass = test_pass + 1;

    $display("========================================");
    $display("Summary: %0d passed, %0d failed", test_pass, test_fail);
    $display("========================================");

    repeat(10) @(posedge clk);
    $finish;
  end

endmodule
