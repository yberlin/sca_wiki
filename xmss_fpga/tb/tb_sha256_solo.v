`timescale 1ns / 1ps
module tb_sha256_solo;
  reg clk, rst_n, start;
  reg [511:0] msg_data;
  reg msg_valid, msg_last;
  wire msg_ready, done;
  wire [255:0] digest;

  sha256_core DUT(.clk(clk), .rst_n(rst_n),
    .msg_data(msg_data), .msg_valid(msg_valid), .msg_last(msg_last),
    .msg_ready(msg_ready), .start(start), .n_bytes(8'd32),
    .digest(digest), .done(done));

  initial clk = 0;
  always #5 clk = ~clk;

  integer c;
  reg [511:0] blk0, blk1;

  initial begin
    rst_n = 0; msg_data = 512'd0; msg_valid = 0; msg_last = 0; start = 0;
    repeat(5) @(posedge clk); rst_n = 1; repeat(3) @(posedge clk);

    // Test: SHA-256 of 96 bytes = prefix(32 zeros) + key(20..3f) + msg(40..5f)
    // Expected: 488a6a032311cda9011fb20ad30e5ce8dc1cb0e0f789920251d5c8f85d03794c
    // Block 0: bytes 0-63 = prefix(32) + key(32)
    blk0 = 512'h0000000000000000000000000000000000000000000000000000000000000000202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f;
    // Block 1: bytes 0-31 = msg(40..5f), byte 32 = 80, bytes 33-55 = 00, bytes 56-63 = length(768=0x300)
    blk1 = 512'h404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f8000000000000000000000000000000000000000000000000000000000000300;

    $display("Test: SHA-256 of 96 bytes (F prefix||key||msg)");
    @(posedge clk); start = 1;
    @(posedge clk); start = 0;

    // Send block 0
    msg_data = blk0; msg_valid = 1; msg_last = 0;
    c = 0;
    while (!(msg_valid && msg_ready) && c < 20) begin
      @(posedge clk);
      c = c + 1;
    end
    @(posedge clk);
    msg_valid = 0;
    // Wait for block done
    c = 0;
    while (!done && c < 200) begin
      @(posedge clk);
      c = c + 1;
    end
    $display("  Block 0 done: %b, state=%d", done, DUT.state);

    // Send block 1
    msg_data = blk1; msg_valid = 1; msg_last = 1;
    c = 0;
    while (!(msg_valid && msg_ready) && c < 20) begin
      @(posedge clk);
      c = c + 1;
    end
    @(posedge clk);
    msg_valid = 0;
    // Wait for done
    c = 0;
    while (!done && c < 200) begin
      @(posedge clk);
      c = c + 1;
    end

    if (c >= 200)
      $display("  TIMEOUT: state=%d, round=%d", DUT.state, DUT.round);
    else begin
      $display("  Result:   %h", digest);
      $display("  Expected: 488a6a032311cda9011fb20ad30e5ce8dc1cb0e0f789920251d5c8f85d03794c");
      $display("  H[0]=%h H[1]=%h H[2]=%h H[3]=%h", DUT.H[0], DUT.H[1], DUT.H[2], DUT.H[3]);
      $display("  H[4]=%h H[5]=%h H[6]=%h H[7]=%h", DUT.H[4], DUT.H[5], DUT.H[6], DUT.H[7]);
    end
    $finish;
  end
endmodule
