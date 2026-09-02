`timescale 1ns / 1ps
module tb_shake_solo;
  reg clk, rst_n, start;
  reg [7:0] din_data;
  reg din_valid, absorb_done;
  wire [511:0] digest;
  wire done;

  shake_core DUT(.clk(clk), .rst_n(rst_n),
    .din_data(din_data), .din_valid(din_valid), .din_ready(),
    .start(start), .absorb_done(absorb_done),
    .output_bits(16'd257),  // SHAKE128
    .n_bytes(8'd32),
    .digest(digest), .done(done));

  initial clk = 0;
  always #5 clk = ~clk;

  integer c;
  integer i;
  reg [7:0] test_data [0:95];

  initial begin
    rst_n = 0; din_data = 0; din_valid = 0; absorb_done = 0; start = 0;
    repeat(5) @(posedge clk); rst_n = 1; repeat(3) @(posedge clk);

    // Test: SHAKE128 of empty string
    // Expected: 7f9c2ba4e88f827d616045507605853ed73b8093f6efbc88eb1a6eacfa66ef26
    $display("Test: SHAKE128 empty string");
    @(posedge clk); start = 1;
    @(posedge clk); start = 0;

    // No data, just absorb_done
    absorb_done = 1;
    @(posedge clk);
    absorb_done = 0;

    // Wait for done
    c = 0;
    while (!done && c < 5000) begin
      @(posedge clk);
      c = c + 1;
    end
    if (c >= 5000) begin
      $display("  TIMEOUT: state=%d", DUT.state);
    end else begin
      $display("  Result:   %h", digest[255:0]);
      $display("  Expected: 7f9c2ba4e88f827d616045507605853ed73b8093f6efbc88eb1a6eacfa66ef26");
      // Dump keccak input/output
      $display("  keccak_in[63:0] (A[0])  = %h", DUT.u_keccak.state_in[63:0]);
      $display("  keccak_out[63:0] (A[0]) = %h", DUT.u_keccak.state_out[63:0]);
      $display("  sponge[63:0]  = %h", DUT.sponge_state[63:0]);
      $display("  sponge[127:64] = %h", DUT.sponge_state[127:64]);
    end
    $finish;
  end
endmodule
