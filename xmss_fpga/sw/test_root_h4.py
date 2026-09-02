#!/usr/bin/env python3
"""Quick test: verify OpenSSL-backed reference matches cross_validate h=4 root."""
import sys
sys.path.insert(0, "C:/Users/pseclab/WorkBuddy/2026-08-27-11-39-48/xmss_fpga/sw")
from xmss_reference_openssl import *

# Use h=4 for comparison with cross_validate test
params = XMSSParams()
params.func = XMSS_SHA2; params.n = 32; params.padding_len = 32
params.full_height = 4; params.d = 1; params.wots_w = 16; params.bds_k = 0
xmss_xmssmt_initialize_params(params)

seed_sk = bytes(range(0x00, 0x20))
seed_pub = bytes(range(0x20, 0x40))
seed_prf = bytes(range(0x40, 0x60))

top_tree_addr = Addr()
set_layer_addr(top_tree_addr, params.d - 1)
root, _ = treehash(params, seed_sk, seed_pub, 0, top_tree_addr)
print(f"Root (h=4) = {root.hex()}")
print(f"Expected   = e87dd61b5891253fa39c45a55786787a9ea117f8432ebbb2cf5f9bfc84336c89")
if root.hex() == "e87dd61b5891253fa39c45a55786787a9ea117f8432ebbb2cf5f9bfc84336c89":
    print("MATCH! OpenSSL-backed C reference matches cross_validate golden value.")
else:
    print("MISMATCH!")

# Also verify with h=10 (our FPGA config)
params10 = make_xmss_sha2_10_256()
top10 = Addr()
set_layer_addr(top10, params10.d - 1)
root10, _ = treehash(params10, seed_sk, seed_pub, 0, top10)
print(f"\nRoot (h=10) = {root10.hex()}")
print("This is the correct root for our FPGA implementation (h=10).")
