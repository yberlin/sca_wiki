// =============================================================================
// xmss_params.vh
// =============================================================================
// XMSS parameter definitions as Verilog-2001 `define macros.
//
// Supports all RFC 8391 and NIST SP 800-208 parameter sets.
// No SystemVerilog constructs used.
// =============================================================================

`timescale 1ns / 1ps

// -------------------------------------------------------------------------
// Hash function type codes (2-bit)
// -------------------------------------------------------------------------
`define HASH_SHA2     2'b00
`define HASH_SHAKE128 2'b01
`define HASH_SHAKE256 2'b10

// -------------------------------------------------------------------------
// Operation mode codes (2-bit)
// -------------------------------------------------------------------------
`define MODE_KEYGEN 2'b00
`define MODE_SIGN   2'b01
`define MODE_VERIFY 2'b10

// -------------------------------------------------------------------------
// Address type codes (32-bit)
// -------------------------------------------------------------------------
`define ADDR_TYPE_OTS   32'd0
`define ADDR_TYPE_LTREE 32'd1
`define ADDR_TYPE_HTREE 32'd2

// -------------------------------------------------------------------------
// Hash function select codes (2-bit)
// -------------------------------------------------------------------------
`define HASH_FUNC_F     2'b00
`define HASH_FUNC_H     2'b01
`define HASH_FUNC_HMSG  2'b10
`define HASH_FUNC_PRF   2'b11

// -------------------------------------------------------------------------
// Maximum parameter bounds
// -------------------------------------------------------------------------
`define MAX_N         64    // Max hash output bytes
`define MAX_N_BITS    512   // MAX_N * 8
`define MAX_W         16
`define MAX_H         20
`define WOTS_LOG_W    4
`define MAX_WOTS_LEN  131
`define ADDR_WORDS    8
`define ADDR_BITS     256

// -------------------------------------------------------------------------
// WOTS+ length constants for each n value
// -------------------------------------------------------------------------
`define WOTS_LEN1_N24  48
`define WOTS_LEN2_N24  3
`define WOTS_LEN_N24   51

`define WOTS_LEN1_N32  64
`define WOTS_LEN2_N32  3
`define WOTS_LEN_N32   67

`define WOTS_LEN1_N64  128
`define WOTS_LEN2_N64  3
`define WOTS_LEN_N64   131

// -------------------------------------------------------------------------
// Parameter set OIDs
// -------------------------------------------------------------------------
`define OID_XMSS_SHA2_10_256     32'h00000001
`define OID_XMSS_SHA2_16_256     32'h00000002
`define OID_XMSS_SHA2_20_256     32'h00000003
`define OID_XMSS_SHA2_10_512     32'h00000004
`define OID_XMSS_SHA2_16_512     32'h00000005
`define OID_XMSS_SHA2_20_512     32'h00000006
`define OID_XMSS_SHAKE_10_256    32'h00000007
`define OID_XMSS_SHAKE_16_256    32'h00000008
`define OID_XMSS_SHAKE_20_256    32'h00000009
`define OID_XMSS_SHAKE_10_512    32'h0000000a
`define OID_XMSS_SHAKE_16_512    32'h0000000b
`define OID_XMSS_SHAKE_20_512    32'h0000000c
// NIST SP 800-208
`define OID_XMSS_SHA2_10_192     32'h0000000d
`define OID_XMSS_SHA2_16_192     32'h0000000e
`define OID_XMSS_SHA2_20_192     32'h0000000f
`define OID_XMSS_SHAKE256_10_256 32'h00000010
`define OID_XMSS_SHAKE256_16_256 32'h00000011
`define OID_XMSS_SHAKE256_20_256 32'h00000012
`define OID_XMSS_SHAKE256_10_192 32'h00000013
`define OID_XMSS_SHAKE256_16_192 32'h00000014
`define OID_XMSS_SHAKE256_20_192 32'h00000015
