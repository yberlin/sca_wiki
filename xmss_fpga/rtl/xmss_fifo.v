// =============================================================================
// xmss_fifo.v
// =============================================================================
// Simple FIFO for message buffering - pure Verilog-2001 RTL.
//
// IP Usage: RTL-inferred FIFO using inferred BRAM.
// If vendor FIFO IP is needed, replace with same interface.
// =============================================================================

`timescale 1ns / 1ps

module xmss_fifo (
  input         clk,
  input         rst_n,
  // Write port
  input         wr_en,
  input  [7:0]  wr_data,
  // Read port
  input         rd_en,
  output [7:0]  rd_data,
  // Status
  output        empty,
  output        full,
  output [10:0] count
);

  // 2048-entry FIFO, 8-bit data
  reg [7:0]  mem [0:2047];
  reg [10:0] wr_ptr;
  reg [10:0] rd_ptr;

  assign empty = (wr_ptr == rd_ptr);
  assign full  = (wr_ptr[10] != rd_ptr[10]) &&
                 (wr_ptr[9:0] == rd_ptr[9:0]);
  assign count = wr_ptr - rd_ptr;
  assign rd_data = mem[rd_ptr[9:0]];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= 11'd0;
      rd_ptr <= 11'd0;
    end else begin
      if (wr_en && !full) begin
        mem[wr_ptr[9:0]] <= wr_data;
        wr_ptr <= wr_ptr + 1;
      end
      if (rd_en && !empty) begin
        rd_ptr <= rd_ptr + 1;
      end
    end
  end

endmodule
