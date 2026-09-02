#!/usr/bin/env python3
"""
xmss_reference_openssl.py
========================
Faithful Python port of the official xmss-reference C implementation
(RFC 8391, by Andreas Huelsing & Joost Rijneveld).

CRITICAL: Hash functions (SHA256, SHA512) are called via ctypes directly
into the OpenSSL libcrypto-3-x64.dll bundled with Python 3.13.
This is NOT a Python reimplementation of SHA-256 - it calls the exact
same C function the original C code calls: SHA256() from <openssl/sha.h>.

Supported: XMSS-SHA2_10_256 (n=32, h=10, w=16, SHA-256)
"""

import ctypes
import os
import sys

# ============================================================================
# OpenSSL libcrypto loading
# ============================================================================

_libcrypto = None

def _load_libcrypto():
    global _libcrypto
    if _libcrypto is not None:
        return _libcrypto
    dll_dir = os.path.join(sys.prefix, "DLLs")
    dll_path = os.path.join(dll_dir, "libcrypto-3-x64.dll")
    if not os.path.exists(dll_path):
        raise FileNotFoundError(f"OpenSSL libcrypto not found at {dll_path}")
    _libcrypto = ctypes.CDLL(dll_path)
    _libcrypto.SHA256.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p]
    _libcrypto.SHA256.restype = ctypes.c_char_p
    _libcrypto.SHA512.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p]
    _libcrypto.SHA512.restype = ctypes.c_char_p
    return _libcrypto

def openssl_sha256(data: bytes) -> bytes:
    lib = _load_libcrypto()
    out = ctypes.create_string_buffer(32)
    lib.SHA256(data, len(data), out)
    return out.raw

def openssl_sha512(data: bytes) -> bytes:
    lib = _load_libcrypto()
    out = ctypes.create_string_buffer(64)
    lib.SHA512(data, len(data), out)
    return out.raw

# ============================================================================
# Utility - port of utils.c
# ============================================================================

def ull_to_bytes(value, outlen):
    out = bytearray(outlen)
    for i in range(outlen - 1, -1, -1):
        out[i] = value & 0xFF
        value >>= 8
    return bytes(out)

def bytes_to_ull(data, inlen):
    retval = 0
    for i in range(inlen):
        retval |= data[i] << (8 * (inlen - 1 - i))
    return retval

# ============================================================================
# Address - port of hash_address.c
# ============================================================================

XMSS_ADDR_TYPE_OTS = 0
XMSS_ADDR_TYPE_LTREE = 1
XMSS_ADDR_TYPE_HASHTREE = 2

class Addr:
    def __init__(self):
        self.a = [0] * 8
    def copy(self):
        x = Addr()
        x.a = list(self.a)
        return x
    def to_bytes(self):
        r = bytearray()
        for i in range(8):
            r.extend(ull_to_bytes(self.a[i], 4))
        return bytes(r)

def set_layer_addr(addr, layer): addr.a[0] = layer
def set_tree_addr(addr, tree):
    addr.a[1] = (tree >> 32) & 0xFFFFFFFF
    addr.a[2] = tree & 0xFFFFFFFF
def set_type(addr, t): addr.a[3] = t
def set_key_and_mask(addr, v): addr.a[7] = v
def copy_subtree_addr(out, inp):
    out.a[0] = inp.a[0]; out.a[1] = inp.a[1]; out.a[2] = inp.a[2]
def set_ots_addr(addr, v): addr.a[4] = v
def set_chain_addr(addr, v): addr.a[5] = v
def set_hash_addr(addr, v): addr.a[6] = v
def set_ltree_addr(addr, v): addr.a[4] = v
def set_tree_height(addr, v): addr.a[5] = v
def set_tree_index(addr, v): addr.a[6] = v

# ============================================================================
# Parameters - port of params.c
# ============================================================================

XMSS_SHA2 = 0

class XMSSParams:
    def __init__(self):
        self.func = 0; self.n = 0; self.padding_len = 0
        self.wots_w = 0; self.wots_log_w = 0
        self.wots_len1 = 0; self.wots_len2 = 0; self.wots_len = 0
        self.wots_sig_bytes = 0
        self.full_height = 0; self.tree_height = 0; self.d = 0
        self.index_bytes = 0; self.sig_bytes = 0
        self.pk_bytes = 0; self.sk_bytes = 0; self.bds_k = 0

def xmss_xmssmt_initialize_params(p):
    p.tree_height = p.full_height // p.d
    if p.wots_w == 16:
        p.wots_log_w = 4
        p.wots_len1 = 8 * p.n // 4
        p.wots_len2 = 3
    else:
        raise ValueError("Only w=16 supported")
    p.wots_len = p.wots_len1 + p.wots_len2
    p.wots_sig_bytes = p.wots_len * p.n
    p.index_bytes = 4 if p.d == 1 else (p.full_height + 7) // 8
    p.sig_bytes = p.index_bytes + p.n + p.d * p.wots_sig_bytes + p.full_height * p.n
    p.pk_bytes = 2 * p.n
    p.sk_bytes = p.index_bytes + 4 * p.n
    return 0

def make_xmss_sha2_10_256():
    p = XMSSParams()
    p.func = XMSS_SHA2; p.n = 32; p.padding_len = 32
    p.full_height = 10; p.d = 1; p.wots_w = 16; p.bds_k = 0
    xmss_xmssmt_initialize_params(p)
    return p

# ============================================================================
# Core hash - port of hash.c
# ============================================================================

PAD_F = 0; PAD_H = 1; PAD_HASH = 2; PAD_PRF = 3; PAD_PRF_KEYGEN = 4

def core_hash(params, in_data):
    if params.func != XMSS_SHA2:
        raise NotImplementedError("Only SHA2 supported")
    if params.n == 32:
        return openssl_sha256(in_data)
    elif params.n == 64:
        return openssl_sha512(in_data)
    elif params.n == 24:
        return openssl_sha256(in_data)[:24]
    raise ValueError(f"Unsupported n={params.n}")

def prf(params, in_32, key):
    buf = ull_to_bytes(PAD_PRF, params.padding_len)
    buf += key[:params.n]
    buf += in_32[:32]
    return core_hash(params, buf)

def prf_keygen(params, in_data, key):
    buf = ull_to_bytes(PAD_PRF_KEYGEN, params.padding_len)
    buf += key[:params.n]
    buf += in_data[:params.n + 32]
    return core_hash(params, buf)

def thash_f(params, in_n, pub_seed, addr):
    n = params.n
    buf = ull_to_bytes(PAD_F, params.padding_len)
    set_key_and_mask(addr, 0)
    key = prf(params, addr.to_bytes(), pub_seed)
    buf += key
    set_key_and_mask(addr, 1)
    bitmask = prf(params, addr.to_bytes(), pub_seed)
    masked = bytes(in_n[i] ^ bitmask[i] for i in range(n))
    buf += masked
    return core_hash(params, buf)

def thash_h(params, in_2n, pub_seed, addr):
    n = params.n
    buf = ull_to_bytes(PAD_H, params.padding_len)
    set_key_and_mask(addr, 0)
    key = prf(params, addr.to_bytes(), pub_seed)
    buf += key
    set_key_and_mask(addr, 1)
    bm1 = prf(params, addr.to_bytes(), pub_seed)
    set_key_and_mask(addr, 2)
    bm2 = prf(params, addr.to_bytes(), pub_seed)
    bitmask = bm1 + bm2
    masked = bytes(in_2n[i] ^ bitmask[i] for i in range(2 * n))
    buf += masked
    return core_hash(params, buf)

# ============================================================================
# WOTS+ - port of wots.c
# ============================================================================

def expand_seed(params, inseed, pub_seed, addr):
    """Port of expand_seed() from wots.c."""
    n = params.n
    set_hash_addr(addr, 0)
    set_key_and_mask(addr, 0)
    buf_pre = pub_seed[:n]
    outseeds = []
    for i in range(params.wots_len):
        set_chain_addr(addr, i)
        addr_bytes = addr.to_bytes()
        out = prf_keygen(params, buf_pre + addr_bytes, inseed)
        outseeds.append(out)
    return outseeds

def gen_chain(params, in_val, start, steps, pub_seed, addr):
    """Port of gen_chain() from wots.c."""
    out = in_val[:params.n]
    for i in range(start, min(start + steps, params.wots_w)):
        set_hash_addr(addr, i)
        out = thash_f(params, out, pub_seed, addr)
    return out

def base_w(params, input_data, out_len):
    """Port of base_w() from wots.c."""
    output = []
    in_idx = 0
    bits = 0
    total = 0
    for _ in range(out_len):
        if bits == 0:
            total = input_data[in_idx]
            in_idx += 1
            bits += 8
        bits -= params.wots_log_w
        output.append((total >> bits) & (params.wots_w - 1))
    return output

def wots_checksum(params, msg_base_w):
    """Port of wots_checksum() from wots.c."""
    csum = 0
    for i in range(params.wots_len1):
        csum += params.wots_w - 1 - msg_base_w[i]
    csum_shifted = csum << (8 - ((params.wots_len2 * params.wots_log_w) % 8))
    csum_bytes_len = (params.wots_len2 * params.wots_log_w + 7) // 8
    csum_bytes = ull_to_bytes(csum_shifted, csum_bytes_len)
    return base_w(params, csum_bytes, params.wots_len2)

def chain_lengths(params, msg):
    """Port of chain_lengths() from wots.c."""
    lengths = base_w(params, msg, params.wots_len1)
    lengths += wots_checksum(params, lengths)
    return lengths

def wots_pkgen(params, seed, pub_seed, addr):
    """Port of wots_pkgen() from wots.c. Returns list of n-byte pk chunks."""
    pk = expand_seed(params, seed, pub_seed, addr)
    for i in range(params.wots_len):
        set_chain_addr(addr, i)
        pk[i] = gen_chain(params, pk[i], 0, params.wots_w - 1, pub_seed, addr)
    return pk

def wots_sign(params, msg, seed, pub_seed, addr):
    """Port of wots_sign() from wots.c."""
    lengths = chain_lengths(params, msg)
    sig = expand_seed(params, seed, pub_seed, addr)
    for i in range(params.wots_len):
        set_chain_addr(addr, i)
        sig[i] = gen_chain(params, sig[i], 0, lengths[i], pub_seed, addr)
    return sig

def wots_pk_from_sig(params, sig, msg, pub_seed, addr):
    """Port of wots_pk_from_sig() from wots.c."""
    lengths = chain_lengths(params, msg)
    pk = []
    for i in range(params.wots_len):
        set_chain_addr(addr, i)
        pk.append(gen_chain(params, sig[i], lengths[i], params.wots_w - 1 - lengths[i], pub_seed, addr))
    return pk

# ============================================================================
# L-tree - port of l_tree() from xmss_commons.c
# ============================================================================

def l_tree(params, wots_pk, pub_seed, addr):
    """Port of l_tree() from xmss_commons.c. Destroys wots_pk, returns leaf."""
    n = params.n
    l = params.wots_len
    height = 0
    set_tree_height(addr, height)
    while l > 1:
        parent_nodes = l >> 1
        for i in range(parent_nodes):
            set_tree_index(addr, i)
            wots_pk[i] = thash_h(params, wots_pk[i*2] + wots_pk[i*2+1], pub_seed, addr)
        if l & 1:
            wots_pk[l >> 1] = wots_pk[l - 1]
            l = (l >> 1) + 1
        else:
            l = l >> 1
        height += 1
        set_tree_height(addr, height)
    return wots_pk[0]

def gen_leaf_wots(params, sk_seed, pub_seed, ltree_addr, ots_addr):
    """Port of gen_leaf_wots() from xmss_commons.c."""
    pk = wots_pkgen(params, sk_seed, pub_seed, ots_addr)
    return l_tree(params, pk, pub_seed, ltree_addr)

# ============================================================================
# Treehash - port of treehash() from xmss_core.c
# ============================================================================

def treehash(params, sk_seed, pub_seed, leaf_idx, subtree_addr):
    """Port of treehash() from xmss_core.c. Returns (root, auth_path)."""
    n = params.n
    h = params.tree_height
    stack = []
    stack_heights = []
    auth_path = [None] * h

    ots_addr = Addr()
    ltree_addr = Addr()
    node_addr = Addr()
    copy_subtree_addr(ots_addr, subtree_addr)
    copy_subtree_addr(ltree_addr, subtree_addr)
    copy_subtree_addr(node_addr, subtree_addr)
    set_type(ots_addr, XMSS_ADDR_TYPE_OTS)
    set_type(ltree_addr, XMSS_ADDR_TYPE_LTREE)
    set_type(node_addr, XMSS_ADDR_TYPE_HASHTREE)

    for idx in range(1 << h):
        set_ltree_addr(ltree_addr, idx)
        set_ots_addr(ots_addr, idx)
        leaf = gen_leaf_wots(params, sk_seed, pub_seed, ltree_addr, ots_addr)
        stack.append(leaf)
        stack_heights.append(0)

        if (leaf_idx ^ 1) == idx:
            auth_path[0] = leaf

        while len(stack) >= 2 and stack_heights[-1] == stack_heights[-2]:
            tree_idx = idx >> (stack_heights[-1] + 1)
            set_tree_height(node_addr, stack_heights[-1])
            set_tree_index(node_addr, tree_idx)
            left = stack[-2]
            right = stack[-1]
            new_node = thash_h(params, left + right, pub_seed, node_addr.copy())
            stack.pop()
            stack.pop()
            stack.append(new_node)
            new_height = stack_heights[-1] + 1
            stack_heights.pop()
            stack_heights.pop()
            stack_heights.append(new_height)

            if ((leaf_idx >> new_height) ^ 1) == tree_idx:
                auth_path[new_height] = new_node

    root = stack[0]
    return root, auth_path

# ============================================================================
# Key generation - port of xmssmt_core_seed_keypair() from xmss_core.c
# ============================================================================

def xmss_keygen(params, seed):
    """
    Port of xmssmt_core_seed_keypair() from xmss_core.c.
    seed = 3*n bytes: [SK_SEED || SK_PRF || PUB_SEED]
    Returns (pk, sk) where pk=[root || pub_seed], sk=[index=0 || SK_SEED || SK_PRF || root || PUB_SEED]
    """
    n = params.n
    auth_path_dummy = None  # not needed, treehash computes it anyway

    top_tree_addr = Addr()
    set_layer_addr(top_tree_addr, params.d - 1)

    # sk layout: index(4 bytes) || SK_SEED(n) || SK_PRF(n) || root(n) || PUB_SEED(n)
    sk_seed = seed[:n]
    sk_prf = seed[n:2*n]
    pub_seed = seed[2*n:3*n]

    # Compute root
    root, _ = treehash(params, sk_seed, pub_seed, 0, top_tree_addr)

    pk = root + pub_seed
    sk_index = ull_to_bytes(0, params.index_bytes)
    sk = sk_index + sk_seed + sk_prf + root + pub_seed
    return pk, sk

# ============================================================================
# Self-test
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("XMSS Reference Implementation (OpenSSL-backed)")
    print("Faithful port of RFC 8391 xmss-reference C code")
    print("Hash: OpenSSL 3.x libcrypto DLL (authoritative, not self-written)")
    print("=" * 70)

    params = make_xmss_sha2_10_256()
    print(f"\nParameter set: XMSS-SHA2_10_256")
    print(f"  n={params.n}, h={params.full_height}, w={params.wots_w}")
    print(f"  wots_len={params.wots_len} (len1={params.wots_len1}, len2={params.wots_len2})")
    print(f"  wots_sig_bytes={params.wots_sig_bytes}")
    print(f"  tree_height={params.tree_height}, d={params.d}")

    # Test with same seeds as our golden vectors
    seed_sk = bytes(range(0x00, 0x20))   # 000102...1f
    seed_pub = bytes(range(0x20, 0x40))  # 202122...3f
    seed_prf = bytes(range(0x40, 0x60))  # 404142...5f
    seed = seed_sk + seed_pub + seed_prf  # 3*n = 96 bytes

    print(f"\nSeeds:")
    print(f"  SK_SEED  = {seed_sk.hex()}")
    print(f"  PUB_SEED = {seed_pub.hex()}")
    print(f"  SK_PRF   = {seed_prf.hex()}")

    # Test individual components
    print(f"\n--- Test 1: PRF ---")
    addr = Addr()
    test_in = bytes(range(32))
    result = prf(params, test_in, seed_pub)
    print(f"  PRF(in=00..1f, key=PUB_SEED) = {result.hex()}")

    print(f"\n--- Test 2: PRF_keygen ---")
    addr2 = Addr()
    addr2.a = [0, 0, 0, 0, 0, 0, 0, 0]
    test_in_kg = seed_pub + addr2.to_bytes()
    result_kg = prf_keygen(params, test_in_kg, seed_sk)
    print(f"  PRF_keygen(in=PUB_SEED||addr, key=SK_SEED) = {result_kg.hex()}")

    print(f"\n--- Test 3: thash_f ---")
    addr3 = Addr()
    addr3.a[3] = XMSS_ADDR_TYPE_OTS
    addr3.a[5] = 0  # chain_addr = 0
    addr3.a[6] = 0  # hash_addr = 0
    test_input_f = bytes(range(32))
    result_f = thash_f(params, test_input_f, seed_pub, addr3.copy())
    print(f"  thash_f(in=00..1f, pub_seed, addr) = {result_f.hex()}")

    print(f"\n--- Test 4: expand_seed (WOTS sk[0]) ---")
    addr4 = Addr()
    addr4.a[3] = XMSS_ADDR_TYPE_OTS
    sk_list = expand_seed(params, seed_sk, seed_pub, addr4)
    print(f"  WOTS sk[0] = {sk_list[0].hex()}")
    print(f"  WOTS sk[1] = {sk_list[1].hex()}")
    print(f"  Total sk entries: {len(sk_list)}")

    print(f"\n--- Test 5: WOTS+ pkgen ---")
    addr5 = Addr()
    addr5.a[3] = XMSS_ADDR_TYPE_OTS
    pk_list = wots_pkgen(params, seed_sk, seed_pub, addr5)
    print(f"  WOTS pk[0] = {pk_list[0].hex()}")
    print(f"  WOTS pk[1] = {pk_list[1].hex()}")
    print(f"  Total pk entries: {len(pk_list)}")

    print(f"\n--- Test 6: L-tree (leaf 0) ---")
    addr6_lt = Addr()
    addr6_ot = Addr()
    addr6_lt.a[3] = XMSS_ADDR_TYPE_LTREE
    addr6_ot.a[3] = XMSS_ADDR_TYPE_OTS
    addr6_lt.a[4] = 0  # ltree_addr = 0 (leaf 0)
    addr6_ot.a[4] = 0  # ots_addr = 0 (leaf 0)
    leaf = gen_leaf_wots(params, seed_sk, seed_pub, addr6_lt, addr6_ot)
    print(f"  Leaf 0 = {leaf.hex()}")

    print(f"\n--- Test 7: Merkle root (via treehash) ---")
    top_tree_addr = Addr()
    set_layer_addr(top_tree_addr, params.d - 1)
    root_direct, _ = treehash(params, seed_sk, seed_pub, 0, top_tree_addr)
    print(f"  Root     = {root_direct.hex()}")

    print(f"\n--- Test 7b: Full XMSS keygen ---")
    full_seed = seed_sk + seed_prf + seed_pub  # SK_SEED || SK_PRF || PUB_SEED
    pk, sk = xmss_keygen(params, full_seed)
    print(f"  Root     = {pk[:32].hex()}")
    print(f"  PUB_SEED = {pk[32:].hex()}")

    print(f"\n--- Test 8: Verify against expected golden values ---")
    expected_sk0 = "a07cbc1c8a54bea1c10680776c031c66be99650c0994b7a4360288c1bfc4b5f8"
    expected_pk0 = "16e47a3d8efab46b39a6fcfa6c017cfd1bb377a7e29b37fff09c1335eaf1a141"
    expected_leaf = "311a4d9262ba7230891dacdc13b6f84fd444ff1ca80f51f25978c8f2d6a78c43"
    expected_root = "aa4892254686bd0ce4c42a509de6cf2e15d5000fe91b46c69d4fe653de0a1f80"

    ok = True
    if sk_list[0].hex() == expected_sk0:
        print(f"  sk[0]     MATCH")
    else:
        print(f"  sk[0]     MISMATCH! Got {sk_list[0].hex()}")
        print(f"           Expected {expected_sk0}")
        ok = False

    if pk_list[0].hex() == expected_pk0:
        print(f"  pk[0]     MATCH")
    else:
        print(f"  pk[0]     MISMATCH! Got {pk_list[0].hex()}")
        print(f"           Expected {expected_pk0}")
        ok = False

    if leaf.hex() == expected_leaf:
        print(f"  leaf[0]   MATCH")
    else:
        print(f"  leaf[0]   MISMATCH! Got {leaf.hex()}")
        print(f"           Expected {expected_leaf}")
        ok = False

    if root_direct.hex() == expected_root:
        print(f"  root      MATCH (via treehash)")
    else:
        print(f"  root      MISMATCH! Got {root_direct.hex()}")
        print(f"           Expected {expected_root}")
        ok = False

    if ok:
        print(f"\n{'='*70}")
        print(f"ALL TESTS PASSED - OpenSSL-backed C reference matches golden vectors")
        print(f"{'='*70}")
    else:
        print(f"\n{'='*70}")
        print(f"SOME TESTS FAILED - see above")
        print(f"{'='*70}")
