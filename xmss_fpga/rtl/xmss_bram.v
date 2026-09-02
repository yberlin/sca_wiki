// =============================================================================
// xmss_bram.v
// =============================================================================
// Simple Dual-Port BRAM wrapper - pure Verilog-2001 RTL.
//
// IP Usage: RTL-inferred BRAM. Synthesis tool infers Block RAM.
// If vendor BRAM IP is needed, replace this module with the vendor IP
// having the same port interface.
// =============================================================================

`timescale 1ns / 1ps

module xmss_bram (
  input         clk,
  // Port A: Write
  input         wr_en,
  input  [15:0] wr_addr,
  input  [511:0] wr_data,
  // Port B: Read
  input         rd_en,
  input  [15:0] rd_addr,
  output [511:0] rd_data
);

  // Inferred Block RAM - 512-bit wide, 4096 deep
  reg [511:0] mem [0:4095];
  reg [511:0] rd_data_reg;

  assign rd_data = rd_data_reg;

  // Write port
  always @(posedge clk) begin
    if (wr_en) mem[wr_addr[11:0]] <= wr_data;
  end

  // Read port (registered)
  always @(posedge clk) begin
    if (rd_en) rd_data_reg <= mem[rd_addr[11:0]];
  end

endmodule
