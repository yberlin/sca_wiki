// =============================================================================
// tb_xmss_hash.v
// =============================================================================
// Testbench for hash engine verification - Verilog-2001.
// IP Usage: Testbench only. Not synthesizable.
// =============================================================================

`timescale 1ns / 1ps

`include "xmss_params.vh"

module tb_xmss_hash;

  reg         clk;
  reg         rst_n;
  reg  [1:0]  hash_type;
  reg  [7:0]  n_bytes;
  reg  [1:0]  func_sel;
  reg  [511:0] key;
  reg  [1023:0] msg;
  reg  [7:0]  msg_len;
  reg         start;
  wire [511:0] digest;
  wire        done;

  reg [255:0] expected_F_sha2_n32;
  reg [255:0] expected_PRF_sha2_n32;
  reg [255:0] expected_F_shake128_n32;
  reg [255:0] expected_PRF_shake128_n32;
  reg [255:0] expected_F_shake256_n32;
  reg [255:0] expected_PRF_shake256_n32;

  integer test_pass, test_fail, test_idx;

  initial clk = 0;
  always #5 clk = ~clk;

  hash_engine DUT (
    .clk(clk), .rst_n(rst_n), .hash_type(hash_type), .n_bytes(n_bytes),
    .func_sel(func_sel), .key(key), .msg(msg), .msg_len(msg_len),
    .start(start), .digest(digest), .done(done)
  );

  initial begin
    expected_F_sha2_n32       = 256'h488a6a032311cda9011fb20ad30e5ce8dc1cb0e0f789920251d5c8f85d03794c;
    expected_PRF_sha2_n32     = 256'h13124f9758e8e55df3dcf520cb3bad8cbda36a6b60063ba276eca11c48bdf89a;
    expected_F_shake128_n32   = 256'hbfff3a54bb4a2c5d3c782b09fbb9fd70e4ef85c59c26905c72cffb2d9ebc2c24;
    expected_PRF_shake128_n32 = 256'ha0fd347fb952863fafcfa274af93270375870b9f6137158d433e65bdbe467a81;
    expected_F_shake256_n32   = 256'h6e7737e65d8b81e4919a3f46ed3553fab9ce3387e202d21fc31f9b3b7aebbee9;
    expected_PRF_shake256_n32 = 256'h8d5fd0ab886f032fe441849f28cab655c160c43eb8d137a0f19e2d0dcacb2d27;
  end

  // Task: run a hash test and check result
  task run_hash_test;
    input [1:0]  t_hash_type;
    input [7:0]  t_n_bytes;
    input [1:0]  t_func_sel;
    input [511:0] t_key;
    input [1023:0] t_msg;
    input [7:0]  t_msg_len;
    input [255:0] t_expected;
    input [127:0] t_name;
    integer cnt;
    begin
      hash_type = t_hash_type;
      n_bytes = t_n_bytes;
      func_sel = t_func_sel;
      key = t_key;
      msg = t_msg;
      msg_len = t_msg_len;
      @(posedge clk); start = 1;
      @(posedge clk); start = 0;
      cnt = 0;
      while (!done && cnt < 5000) begin
        @(posedge clk);
        cnt = cnt + 1;
      end
      if (cnt >= 5000) begin
        $display("  TIMEOUT: he_state=%d", DUT.he_state);
        test_fail = test_fail + 1;
      end else begin
        @(posedge clk);
        if (digest[255:0] === t_expected) begin
          $display("  PASS"); test_pass = test_pass + 1;
        end else begin
          $display("  FAIL: expected %h", t_expected);
          $display("         got      %h", digest[255:0]);
          test_fail = test_fail + 1;
        end
      end
    end
  endtask

  initial begin
    rst_n = 0; hash_type = `HASH_SHA2; n_bytes = 32;
    func_sel = 0; key = 512'd0; msg = 512'd0; msg_len = 0;
    start = 0;
    test_pass = 0; test_fail = 0; test_idx = 0;

    repeat(5) @(posedge clk); rst_n = 1; repeat(3) @(posedge clk);

    $display("========================================");
    $display("XMSS Hash Engine Testbench");
    $display("========================================");

    // Test 1: SHA-256 F(KEY, M)
    $display("[%0d] Test 1: SHA-256 F(KEY, M)", test_idx);
    test_idx = test_idx + 1;
    run_hash_test(
      `HASH_SHA2, 8'd32, 2'b00,
      {256'd0, 256'h202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f},
      {256'd0, 256'h404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f},
      8'd32, expected_F_sha2_n32, "SHA-256 F");

    // Test 2: SHA-256 PRF(SEED, ADRS)
    $display("[%0d] Test 2: SHA-256 PRF(SEED, ADRS)", test_idx);
    test_idx = test_idx + 1;
    run_hash_test(
      `HASH_SHA2, 8'd32, 2'b11,
      {256'd0, 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f},
      512'd0, 8'd32, expected_PRF_sha2_n32, "SHA-256 PRF");

    // Test 3: SHAKE128 F(KEY, M)
    $display("[%0d] Test 3: SHAKE128 F(KEY, M)", test_idx);
    test_idx = test_idx + 1;
    run_hash_test(
      `HASH_SHAKE128, 8'd32, 2'b00,
      {256'd0, 256'h202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f},
      {256'd0, 256'h404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f},
      8'd32, expected_F_shake128_n32, "SHAKE128 F");

    // Test 4: SHAKE256 PRF(SEED, ADRS)
    $display("[%0d] Test 4: SHAKE256 PRF(SEED, ADRS)", test_idx);
    test_idx = test_idx + 1;
    run_hash_test(
      `HASH_SHAKE256, 8'd32, 2'b11,
      {256'd0, 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f},
      512'd0, 8'd32, expected_PRF_shake256_n32, "SHAKE256 PRF");

    $display("========================================");
    $display("Summary: %0d passed, %0d failed", test_pass, test_fail);
    $display("========================================");
    if (test_fail == 0) $display("ALL TESTS PASSED");
    else $display("SOME TESTS FAILED");

    repeat(10) @(posedge clk);
    $finish;
  end

  initial begin
    #5000000;
    $display("ERROR: Global timeout");
    $finish;
  end

endmodule
