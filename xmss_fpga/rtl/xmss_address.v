// =============================================================================
// xmss_address.v
// =============================================================================
// XMSS 256-bit address management module (RFC 8391 Section 2.5).
// Pure Verilog-2001 RTL.
//
// Address: 8 x 32-bit words = 256 bits
//   Word 0: Layer address
//   Word 1-2: Tree address (64 bits)
//   Word 3: Type (0=OTS, 1=L-tree, 2=Hash tree)
//   Word 4: OTS/L-tree/Padding address
//   Word 5: Chain address / tree height
//   Word 6: Hash address / tree index
//   Word 7: KeyAndMask
//
// IP Usage: None. Pure RTL.
// =============================================================================

`timescale 1ns / 1ps

module xmss_address (
  input         clk,
  input         rst_n,

  output [255:0] addr,

  input         clear,
  input         set_type,
  input  [31:0] type_val,
  input         set_ots_addr,
  input  [31:0] ots_addr,
  input         set_ltree_addr,
  input  [31:0] ltree_addr,
  input         set_chain_addr,
  input  [31:0] chain_addr,
  input         set_hash_addr,
  input  [31:0] hash_addr,
  input         set_tree_height,
  input  [31:0] tree_height,
  input         set_tree_index,
  input  [31:0] tree_index,
  input         set_key_and_mask,
  input  [31:0] key_and_mask
);

  reg [31:0] layer_addr;
  reg [31:0] tree_addr_hi;
  reg [31:0] tree_addr_lo;
  reg [31:0] type_field;
  reg [31:0] addr4;
  reg [31:0] addr5;
  reg [31:0] addr6;
  reg [31:0] addr7;

  assign addr = {layer_addr, tree_addr_hi, tree_addr_lo,
                type_field, addr4, addr5, addr6, addr7};

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      layer_addr   <= 32'd0;
      tree_addr_hi <= 32'd0;
      tree_addr_lo <= 32'd0;
      type_field   <= 32'd0;
      addr4 <= 32'd0;
      addr5 <= 32'd0;
      addr6 <= 32'd0;
      addr7 <= 32'd0;
    end else begin
      if (clear) begin
        layer_addr   <= 32'd0;
        tree_addr_hi <= 32'd0;
        tree_addr_lo <= 32'd0;
        type_field   <= 32'd0;
        addr4 <= 32'd0;
        addr5 <= 32'd0;
        addr6 <= 32'd0;
        addr7 <= 32'd0;
      end else begin
        if (set_type) begin
          type_field <= type_val;
          addr4 <= 32'd0;
          addr5 <= 32'd0;
          addr6 <= 32'd0;
          addr7 <= 32'd0;
        end
        if (set_ots_addr)      addr4 <= ots_addr;
        if (set_ltree_addr)    addr4 <= ltree_addr;
        if (set_chain_addr)    addr5 <= chain_addr;
        if (set_hash_addr)     addr6 <= hash_addr;
        if (set_tree_height)   addr5 <= tree_height;
        if (set_tree_index)    addr6 <= tree_index;
        if (set_key_and_mask)  addr7 <= key_and_mask;
      end
    end
  end

endmodule
