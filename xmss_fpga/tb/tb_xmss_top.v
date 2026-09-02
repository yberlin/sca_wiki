// =============================================================================
// tb_xmss_top.v
// =============================================================================
// Top-level XMSS testbench - Verilog-2001.
// Tests KeyGen/Sign/Verify across parameter sets.
// IP Usage: Testbench only. Not synthesizable.
// =============================================================================

`timescale 1ns / 1ps

`include "xmss_params.vh"

module tb_xmss_top;

  reg         clk, rst_n;
  reg  [31:0] oid;
  reg  [1:0]  mode;
  reg         start;
  wire        done, error;
  reg  [7:0]  din_data;
  reg         din_valid;
  wire        din_ready;
  wire [7:0]  dout_data;
  wire        dout_valid;
  reg         dout_ready;

  wire        ext_mem_wr, ext_mem_rd;
  wire [15:0] ext_mem_addr;
  wire [511:0] ext_mem_wr_data;
  wire [511:0] ext_mem_rd_data;

  integer test_pass, test_fail, test_idx;
  integer cycle_cnt;

  initial clk = 0;
  always #5 clk = ~clk;

  xmss_top DUT (
    .clk(clk), .rst_n(rst_n), .oid(oid), .mode(mode),
    .start(start), .done(done), .error(error),
    .din_data(din_data), .din_valid(din_valid), .din_ready(din_ready),
    .dout_data(dout_data), .dout_valid(dout_valid), .dout_ready(dout_ready),
    .ext_mem_wr(ext_mem_wr), .ext_mem_rd(ext_mem_rd),
    .ext_mem_addr(ext_mem_addr), .ext_mem_wr_data(ext_mem_wr_data),
    .ext_mem_rd_data(ext_mem_rd_data)
  );

  xmss_bram u_ext_mem (
    .clk(clk), .wr_en(ext_mem_wr), .wr_addr(ext_mem_addr),
    .wr_data(ext_mem_wr_data), .rd_en(ext_mem_rd),
    .rd_addr(ext_mem_addr), .rd_data(ext_mem_rd_data)
  );

  // Timeout watchdog
  always @(posedge clk) begin
    if (cycle_cnt > 10000000) begin
      $display("  ERROR: timeout");
      test_fail = test_fail + 1;
      $finish;
    end
    cycle_cnt = cycle_cnt + 1;
  end

  initial begin
    rst_n = 0; oid = `OID_XMSS_SHA2_10_256; mode = `MODE_KEYGEN;
    start = 0; din_data = 0; din_valid = 0; dout_ready = 1;
    test_pass = 0; test_fail = 0; test_idx = 0; cycle_cnt = 0;

    repeat(5) @(posedge clk); rst_n = 1; repeat(3) @(posedge clk);

    $display("========================================");
    $display("XMSS Top-Level Testbench");
    $display("========================================");

    // --- XMSS-SHA2_10_256 ---
    $display("\n--- XMSS-SHA2_10_256 ---");
    oid = `OID_XMSS_SHA2_10_256;

    // KeyGen
    $display("[%0d] KeyGen", test_idx); test_idx = test_idx + 1;
    mode = `MODE_KEYGEN; cycle_cnt = 0;
    @(posedge clk); start = 1; @(posedge clk); start = 0;
    @(done);
    if (error) begin $display("  FAIL: error"); test_fail = test_fail + 1; end
    else begin $display("  PASS"); test_pass = test_pass + 1; end

    // Sign
    $display("[%0d] Sign", test_idx); test_idx = test_idx + 1;
    mode = `MODE_SIGN; cycle_cnt = 0;
    @(posedge clk); start = 1; @(posedge clk); start = 0;
    @(done);
    if (error) begin $display("  FAIL: error"); test_fail = test_fail + 1; end
    else begin $display("  PASS"); test_pass = test_pass + 1; end

    // Verify
    $display("[%0d] Verify", test_idx); test_idx = test_idx + 1;
    mode = `MODE_VERIFY; cycle_cnt = 0;
    @(posedge clk); start = 1; @(posedge clk); start = 0;
    @(done);
    if (error) begin $display("  FAIL: error"); test_fail = test_fail + 1; end
    else begin $display("  PASS: valid"); test_pass = test_pass + 1; end

    // --- XMSS-SHAKE256_10_256 ---
    $display("\n--- XMSS-SHAKE256_10_256 ---");
    oid = `OID_XMSS_SHAKE256_10_256;

    // KeyGen
    $display("[%0d] KeyGen", test_idx); test_idx = test_idx + 1;
    mode = `MODE_KEYGEN; cycle_cnt = 0;
    @(posedge clk); start = 1; @(posedge clk); start = 0;
    @(done);
    if (error) begin $display("  FAIL: error"); test_fail = test_fail + 1; end
    else begin $display("  PASS"); test_pass = test_pass + 1; end

    // Sign
    $display("[%0d] Sign", test_idx); test_idx = test_idx + 1;
    mode = `MODE_SIGN; cycle_cnt = 0;
    @(posedge clk); start = 1; @(posedge clk); start = 0;
    @(done);
    if (error) begin $display("  FAIL: error"); test_fail = test_fail + 1; end
    else begin $display("  PASS"); test_pass = test_pass + 1; end

    // Verify
    $display("[%0d] Verify", test_idx); test_idx = test_idx + 1;
    mode = `MODE_VERIFY; cycle_cnt = 0;
    @(posedge clk); start = 1; @(posedge clk); start = 0;
    @(done);
    if (error) begin $display("  FAIL: error"); test_fail = test_fail + 1; end
    else begin $display("  PASS: valid"); test_pass = test_pass + 1; end

    $display("\n========================================");
    $display("Summary: %0d passed, %0d failed", test_pass, test_fail);
    $display("========================================");
    if (test_fail == 0) $display("ALL TESTS PASSED");
    else $display("SOME TESTS FAILED");

    repeat(10) @(posedge clk);
    $finish;
  end

endmodule
