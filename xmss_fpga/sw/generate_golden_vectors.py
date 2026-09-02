#!/usr/bin/env python3
"""
generate_golden_vectors.py
==========================
Generates golden test vectors for XMSS RTL verification.

Uses RFC 8391 reference algorithms to compute:
  1. SHA-256 and SHAKE hash function outputs (F, H, H_msg, PRF)
  2. WOTS+ chain function outputs
  3. WOTS+ key generation, signing, verification
  4. XMSS L-tree and Merkle tree

Output: JSON file with hex-encoded test vectors.
Dependencies: Python 3.8+, hashlib, json (no external crypto libs)
"""

import hashlib
import json
import os
import struct
import math


def sha256(data):
    return hashlib.sha256(data).digest()

def shake128(data, output_len):
    h = hashlib.shake_128()
    h.update(data)
    return h.digest(output_len)

def shake256(data, output_len):
    h = hashlib.shake_256()
    h.update(data)
    return h.digest(output_len)

def to_byte(value, length):
    return value.to_bytes(length, byteorder='big')

def make_hash_funcs(hash_type, n):
    if hash_type == 'SHA2':
        F = lambda k, m: sha256(to_byte(0, n) + k + m)[:n]
        H = lambda k, m: sha256(to_byte(1, n) + k + m)[:n]
        Hmsg = lambda k, m: sha256(to_byte(2, n) + k + m)[:n]
        PRF = lambda k, m: sha256(to_byte(3, n) + k + m)[:n]
        PRF_keygen = lambda k, m: sha256(to_byte(4, n) + k + m)[:n]
    elif hash_type == 'SHAKE128':
        sf = shake128
        F = lambda k, m: sf(to_byte(0, n) + k + m, n)
        H = lambda k, m: sf(to_byte(1, n) + k + m, n)
        Hmsg = lambda k, m: sf(to_byte(2, n) + k + m, n)
        PRF = lambda k, m: sf(to_byte(3, n) + k + m, n)
        PRF_keygen = lambda k, m: sf(to_byte(4, n) + k + m, n)
    elif hash_type == 'SHAKE256':
        sf = shake256
        F = lambda k, m: sf(to_byte(0, n) + k + m, n)
        H = lambda k, m: sf(to_byte(1, n) + k + m, n)
        Hmsg = lambda k, m: sf(to_byte(2, n) + k + m, n)
        PRF = lambda k, m: sf(to_byte(3, n) + k + m, n)
        PRF_keygen = lambda k, m: sf(to_byte(4, n) + k + m, n)
    else:
        raise ValueError("Unknown hash type: " + hash_type)
    return F, H, Hmsg, PRF, PRF_keygen


class Address:
    def __init__(self):
        self.layer_addr = 0
        self.tree_addr = 0
        self.type = 0
        self.ots_addr = 0
        self.ltree_addr = 0
        self.chain_addr = 0
        self.hash_addr = 0
        self.tree_height = 0
        self.tree_index = 0
        self.key_and_mask = 0

    def set_type(self, t):
        self.type = t
        self.ots_addr = 0
        self.ltree_addr = 0
        self.chain_addr = 0
        self.hash_addr = 0
        self.tree_height = 0
        self.tree_index = 0
        self.key_and_mask = 0

    def to_bytes(self):
        w = [0] * 8
        w[0] = self.layer_addr
        w[1] = (self.tree_addr >> 32) & 0xFFFFFFFF
        w[2] = self.tree_addr & 0xFFFFFFFF
        w[3] = self.type
        if self.type == 0:
            w[4] = self.ots_addr
            w[5] = self.chain_addr
            w[6] = self.hash_addr
        elif self.type == 1:
            w[4] = self.ltree_addr
            w[5] = self.tree_height
            w[6] = self.tree_index
        elif self.type == 2:
            w[4] = 0
            w[5] = self.tree_height
            w[6] = self.tree_index
        w[7] = self.key_and_mask
        return struct.pack('>8I', *w)

    def copy(self):
        a = Address()
        a.layer_addr = self.layer_addr
        a.tree_addr = self.tree_addr
        a.type = self.type
        a.ots_addr = self.ots_addr
        a.ltree_addr = self.ltree_addr
        a.chain_addr = self.chain_addr
        a.hash_addr = self.hash_addr
        a.tree_height = self.tree_height
        a.tree_index = self.tree_index
        a.key_and_mask = self.key_and_mask
        return a


class WOTSPlus:
    def __init__(self, n, w, hash_type):
        self.n = n
        self.w = w
        self.hash_type = hash_type
        self.len1 = math.ceil(8 * n / math.log2(w))
        self.len2 = math.floor(math.log2(self.len1 * (w - 1)) / math.log2(w)) + 1
        self.len = self.len1 + self.len2
        self.F, self.H, self.H_msg, self.PRF, self.PRF_keygen = make_hash_funcs(hash_type, n)

    def base_w(self, x, out_len):
        result = []
        in_idx = 0
        bits = 0
        total = 0
        for _ in range(out_len):
            if bits == 0:
                total = x[in_idx]
                in_idx += 1
                bits += 8
            bits -= int(math.log2(self.w))
            result.append((total >> bits) & (self.w - 1))
        return result

    def chain(self, x, start, steps, seed, adrs):
        if steps == 0:
            return x
        tmp = x
        for i in range(start, start + steps):
            adrs.hash_addr = i
            adrs.key_and_mask = 0
            key = self.PRF(seed, adrs.to_bytes())
            adrs.key_and_mask = 1
            mask = self.PRF(seed, adrs.to_bytes())
            xored = bytes(a ^ b for a, b in zip(tmp, mask))
            tmp = self.F(key, xored)
        return tmp

    def gen_sk(self, seed, pub_seed=None, adrs=None):
        """
        RFC 8391 expand_seed: derives WOTS+ private key elements from seed.
        Uses PRF_keygen (padding=4) with input = pub_seed || addr_bytes.
        Falls back to old PRF-based method if pub_seed/adrs not provided
        (for backward compatibility with standalone hash tests).
        """
        if pub_seed is not None and adrs is not None:
            # RFC 8391 compliant: PRF_keygen(sk_seed, pub_seed || addr)
            sk = []
            adrs.hash_addr = 0
            adrs.key_and_mask = 0
            for i in range(self.len):
                adrs.chain_addr = i
                sk.append(self.PRF_keygen(seed, pub_seed + adrs.to_bytes()))
            return sk
        else:
            # Legacy fallback (hash test vectors only)
            sk = []
            for i in range(self.len):
                idx_bytes = to_byte(i, 32)
                sk.append(self.PRF(seed, idx_bytes))
            return sk

    def gen_pk(self, sk, seed, adrs):
        pk = []
        for i in range(self.len):
            adrs.chain_addr = i
            pk.append(self.chain(sk[i], 0, self.w - 1, seed, adrs.copy()))
        return pk

    def sign(self, msg, sk, seed, adrs):
        msg_digits = self.base_w(msg, self.len1)
        csum = sum(self.w - 1 - d for d in msg_digits)
        shift = 8 - ((self.len2 * int(math.log2(self.w))) % 8)
        if shift == 8:
            shift = 0
        csum <<= shift
        csum_bytes = csum.to_bytes(
            math.ceil(self.len2 * math.log2(self.w) / 8), 'big')
        csum_digits = self.base_w(csum_bytes, self.len2)
        full = msg_digits + csum_digits
        sig = []
        for i in range(self.len):
            adrs.chain_addr = i
            sig.append(self.chain(sk[i], 0, full[i], seed, adrs.copy()))
        return sig

    def pk_from_sig(self, sig, msg, seed, adrs):
        msg_digits = self.base_w(msg, self.len1)
        csum = sum(self.w - 1 - d for d in msg_digits)
        shift = 8 - ((self.len2 * int(math.log2(self.w))) % 8)
        if shift == 8:
            shift = 0
        csum <<= shift
        csum_bytes = csum.to_bytes(
            math.ceil(self.len2 * math.log2(self.w) / 8), 'big')
        csum_digits = self.base_w(csum_bytes, self.len2)
        full = msg_digits + csum_digits
        tmp_pk = []
        for i in range(self.len):
            adrs.chain_addr = i
            tmp_pk.append(self.chain(sig[i], full[i],
                                      self.w - 1 - full[i], seed, adrs.copy()))
        return tmp_pk


class XMSSTree:
    def __init__(self, wots, h):
        self.wots = wots
        self.h = h
        self.n = wots.n

    def rand_hash(self, left, right, seed, adrs):
        adrs.key_and_mask = 0
        key = self.wots.PRF(seed, adrs.to_bytes())
        adrs.key_and_mask = 1
        bm0 = self.wots.PRF(seed, adrs.to_bytes())
        adrs.key_and_mask = 2
        bm1 = self.wots.PRF(seed, adrs.to_bytes())
        lx = bytes(a ^ b for a, b in zip(left, bm0))
        rx = bytes(a ^ b for a, b in zip(right, bm1))
        return self.wots.H(key, lx + rx)

    def l_tree(self, pk, seed, adrs):
        """
        RFC 8391 L-tree algorithm.
        Faithful port of C reference xmss_commons.c l_tree().
        Operates in-place on a copy of pk, pulling up odd nodes
        instead of zero-padding.
        """
        n = self.n
        leaves = list(pk)  # copy
        l = len(leaves)
        height = 0
        adrs.tree_height = height

        while l > 1:
            parent_nodes = l >> 1
            for i in range(parent_nodes):
                adrs.tree_index = i  # C: set_tree_index(addr, i) — parent index
                h = self.rand_hash(leaves[i*2], leaves[i*2 + 1], seed, adrs.copy())
                leaves[i] = h
            # If odd, pull last node up (don't hash it with zeros)
            if l & 1:
                leaves[l >> 1] = leaves[l - 1]
                l = (l >> 1) + 1
            else:
                l = l >> 1
            height += 1
            adrs.tree_height = height

        return leaves[0]

    def tree_hash(self, leaves, seed, adrs):
        """
        Build a Merkle tree from pre-computed leaves, return root.
        Faithful port of C reference treehash logic.
        """
        n = self.n
        nodes = list(leaves)
        l = len(nodes)
        height = 0
        adrs.tree_height = height

        while l > 1:
            parent_nodes = l >> 1
            for i in range(parent_nodes):
                adrs.tree_index = i  # parent node index
                h = self.rand_hash(nodes[i*2], nodes[i*2 + 1], seed, adrs.copy())
                nodes[i] = h
            if l & 1:
                nodes[l >> 1] = nodes[l - 1]
                l = (l >> 1) + 1
            else:
                l = l >> 1
            height += 1
            adrs.tree_height = height

        return nodes[0]
        return nodes[0]

    def compute_leaves(self, wots_pk_list, seed):
        """Compute all L-tree leaves from a list of WOTS+ pk arrays."""
        leaves = []
        for i in range(len(wots_pk_list)):
            adrs_ltree = Address()
            adrs_ltree.set_type(1)
            adrs_ltree.ltree_addr = i
            leaf = self.l_tree(wots_pk_list[i], seed, adrs_ltree.copy())
            leaves.append(leaf)
        return leaves


def gen_hash_test_vectors(n, hash_type):
    F, H, H_msg_f, PRF, PRF_keygen = make_hash_funcs(hash_type, n)
    seed = bytes(range(n))
    key = bytes(range(n, 2*n))
    msg_single = bytes(range(2*n, 3*n))
    msg_double = bytes(range(2*n, 4*n))
    msg_var = b"Test message for H_msg"
    adrs = Address()
    adrs_bytes = adrs.to_bytes()
    return {
        "hash_type": hash_type,
        "n": n,
        "inputs": {
            "seed": seed.hex(),
            "key": key.hex(),
            "msg_single": msg_single.hex(),
            "msg_double": msg_double.hex(),
            "msg_variable": msg_var.hex(),
            "address": adrs_bytes.hex(),
        },
        "outputs": {
            "F": F(key, msg_single).hex(),
            "H": H(key, msg_double).hex(),
            "H_msg": H_msg_f(key, msg_var).hex(),
            "PRF": PRF(seed, adrs_bytes).hex(),
        }
    }


def gen_wots_test_vectors(n, w, hash_type):
    wots = WOTSPlus(n, w, hash_type)
    seed = bytes(range(n))       # sk_seed
    pub_seed = bytes(range(n, 2*n))  # pub_seed (separate from sk_seed)
    msg = bytes(range(n, 2*n))
    adrs = Address()
    adrs.set_type(0)
    adrs.ots_addr = 0
    sk = wots.gen_sk(seed, pub_seed, adrs.copy())
    adrs.chain_addr = 0
    chain_result = wots.chain(sk[0], 0, w-1, pub_seed, adrs.copy())
    pk = wots.gen_pk(sk, pub_seed, adrs.copy())
    sig = wots.sign(msg, sk, pub_seed, adrs.copy())
    reconstructed_pk = wots.pk_from_sig(sig, msg, pub_seed, adrs.copy())
    pk_match = (pk == reconstructed_pk)
    return {
        "hash_type": hash_type,
        "n": n,
        "w": w,
        "len1": wots.len1,
        "len2": wots.len2,
        "len": wots.len,
        "inputs": {
            "seed": seed.hex(),
            "message": msg.hex(),
            "address": adrs.to_bytes().hex(),
        },
        "sk": [s.hex() for s in sk],
        "pk": [p.hex() for p in pk],
        "chain_0_full": chain_result.hex(),
        "signature": [s.hex() for s in sig],
        "reconstructed_pk": [p.hex() for p in reconstructed_pk],
        "pk_match": pk_match,
    }


def gen_xmss_tree_test_vectors(n, w, h, hash_type):
    wots = WOTSPlus(n, w, hash_type)
    tree = XMSSTree(wots, h)
    seed_sk = bytes(range(n))
    seed_pub = bytes(range(n, 2*n))

    # Compute all WOTS+ key pairs
    wots_pk_list = []
    for i in range(2**h):
        adrs_ots = Address()
        adrs_ots.set_type(0)
        adrs_ots.ots_addr = i
        sk_i = wots.gen_sk(seed_sk, seed_pub, adrs_ots.copy())
        pk_i = wots.gen_pk(sk_i, seed_pub, adrs_ots.copy())
        wots_pk_list.append(pk_i)

    # Compute all L-tree leaves
    all_leaves = tree.compute_leaves(wots_pk_list, seed_pub)

    # Compute Merkle tree root
    adrs_tree = Address()
    adrs_tree.set_type(2)
    tree_root = tree.tree_hash(all_leaves, seed_pub, adrs_tree.copy())

    return {
        "hash_type": hash_type,
        "n": n,
        "w": w,
        "h": h,
        "inputs": {
            "sk_seed": seed_sk.hex(),
            "pub_seed": seed_pub.hex(),
        },
        "leaf_0_pk": [p.hex() for p in wots_pk_list[0]],
        "leaf_0": all_leaves[0].hex(),
        "all_leaves": [l.hex() for l in all_leaves],
        "tree_root": tree_root.hex(),
    }


def main():
    output_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'sim')
    os.makedirs(output_dir, exist_ok=True)

    all_vectors = {
        "description": "Golden test vectors for XMSS RTL verification",
        "source": "RFC 8391 reference algorithms, Python implementation",
        "date": "2026-08-27",
    }

    hash_tests = []
    for n, ht in [(32, 'SHA2'), (32, 'SHAKE128'), (32, 'SHAKE256'),
                  (64, 'SHA2'), (64, 'SHAKE256'), (24, 'SHA2'), (24, 'SHAKE256')]:
        hash_tests.append(gen_hash_test_vectors(n, ht))
    all_vectors["hash_tests"] = hash_tests

    wots_tests = []
    for n, ht in [(32, 'SHA2'), (32, 'SHAKE128'), (32, 'SHAKE256'),
                  (64, 'SHA2'), (24, 'SHA2')]:
        wots_tests.append(gen_wots_test_vectors(n, 16, ht))
    all_vectors["wots_tests"] = wots_tests

    tree_tests = []
    for n, h, ht in [(32, 4, 'SHA2'), (32, 4, 'SHAKE256')]:
        tree_tests.append(gen_xmss_tree_test_vectors(n, 16, h, ht))
    all_vectors["tree_tests"] = tree_tests

    output_path = os.path.join(output_dir, 'golden_vectors.json')
    with open(output_path, 'w') as f:
        json.dump(all_vectors, f, indent=2)
    print("Golden vectors written to: " + output_path)

    hex_dir = os.path.join(output_dir, 'hex')
    os.makedirs(hex_dir, exist_ok=True)
    for i, test in enumerate(hash_tests):
        prefix = test['hash_type'] + '_n' + str(test['n'])
        with open(os.path.join(hex_dir, prefix + '_F_key.hex'), 'w') as f:
            f.write(test['inputs']['key'] + '\n')
        with open(os.path.join(hex_dir, prefix + '_F_msg.hex'), 'w') as f:
            f.write(test['inputs']['msg_single'] + '\n')
        with open(os.path.join(hex_dir, prefix + '_F_expected.hex'), 'w') as f:
            f.write(test['outputs']['F'] + '\n')
        with open(os.path.join(hex_dir, prefix + '_PRF_key.hex'), 'w') as f:
            f.write(test['inputs']['seed'] + '\n')
        with open(os.path.join(hex_dir, prefix + '_PRF_msg.hex'), 'w') as f:
            f.write(test['inputs']['address'] + '\n')
        with open(os.path.join(hex_dir, prefix + '_PRF_expected.hex'), 'w') as f:
            f.write(test['outputs']['PRF'] + '\n')

    for i, test in enumerate(wots_tests):
        prefix = 'wots_' + test['hash_type'] + '_n' + str(test['n'])
        with open(os.path.join(hex_dir, prefix + '_seed.hex'), 'w') as f:
            f.write(test['inputs']['seed'] + '\n')
        with open(os.path.join(hex_dir, prefix + '_msg.hex'), 'w') as f:
            f.write(test['inputs']['message'] + '\n')
        with open(os.path.join(hex_dir, prefix + '_chain0.hex'), 'w') as f:
            f.write(test['chain_0_full'] + '\n')
        for j, s in enumerate(test['sk'][:8]):
            with open(os.path.join(hex_dir, prefix + '_sk' + str(j) + '.hex'), 'w') as f:
                f.write(s + '\n')
        for j, p in enumerate(test['pk'][:8]):
            with open(os.path.join(hex_dir, prefix + '_pk' + str(j) + '.hex'), 'w') as f:
                f.write(p + '\n')

    print("Hex files written to: " + hex_dir)
    print("Total hash tests: " + str(len(hash_tests)))
    print("Total WOTS+ tests: " + str(len(wots_tests)))
    print("Total tree tests: " + str(len(tree_tests)))

    # Write tree test hex files
    for i, test in enumerate(tree_tests):
        prefix = 'tree_' + test['hash_type'] + '_n' + str(test['n'])
        # Write all leaves
        with open(os.path.join(hex_dir, prefix + '_leaves.hex'), 'w') as f:
            for leaf in test['all_leaves']:
                f.write(leaf + '\n')
        # Write tree root
        with open(os.path.join(hex_dir, prefix + '_root.hex'), 'w') as f:
            f.write(test['tree_root'] + '\n')
        # Write leaf 0 pk and expected for SHA2 test (used by L-tree testbench)
        if test['hash_type'] == 'SHA2':
            with open(os.path.join(hex_dir, 'tree_pk0.hex'), 'w') as f:
                for p in test['leaf_0_pk']:
                    f.write(p + '\n')
            with open(os.path.join(hex_dir, 'tree_leaf0.hex'), 'w') as f:
                f.write(test['leaf_0'] + '\n')


if __name__ == '__main__':
    main()
