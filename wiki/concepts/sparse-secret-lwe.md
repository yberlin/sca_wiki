# 稀疏三值秘密 LWE

> **类型**: concept
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-hhan2025-perfect-to-approx]]

## 摘要

当 LWE 秘密向量 s 的汉明重量 h 远小于维度 n（h≪n）时，利用稀疏性可将侧信道提示的恢复阈值从 O(n) 降至 O(h log²h)。这在全同态加密（FHE）方案中尤其关键，因为 FHE 常使用 n=2^15 或 2^16 的大维度但 h 很小的稀疏三值秘密。

## 详情

### 稀疏三值秘密定义
- **三值向量**: s ∈ {-1, 0, 1}^n
- **稀疏性**: Hamming weight h ≪ n
- **记号**: T_n(h) = {s ∈ {-1,0,1}^n : ||s||_0 = h}
- **FHE 应用**: FHE 方案（如 OpenFHE）为提高效率常使用稀疏秘密

### 与标准 LWE 的区别

| 特性 | 标准 LWE | 稀疏三值 LWE |
|------|---------|-------------|
| 秘密分布 | CBD 或均匀 | {-1,0,1}，h 个非零 |
| 维度 n | 256-1024 (Kyber) | 2^15 - 2^16 (FHE) |
| 汉明重量 h | ≈n/2 | ≪n (如 32, 192) |
| MN 阈值 | n/2 perfect | n/2 ≈ 2^14 |
| 本文阈值 | — | O(h log²h) |

### NonZeroEntryGuess 算法

核心观察：计算 X_j = ⟨A_j, c⟩，非零系数位置的 |X_j| 显著大于零位置。

1. 选最大 |X_j| → 恢复 s_j = sign(X_j)
2. 更新 c ← c - s_j · A_j（剥离已恢复分量）
3. 重复 h 次
4. 总计算量: O(hmn)

### 提示阈值对比

| 提示类型 | DDGR 阈值 | MN 阈值 | 本文阈值 (稀疏) |
|---------|----------|---------|---------------|
| Perfect | ~n | n/2 | O(h log²h) |
| Modular | ~n | 0.9n (mod-q) | — |
| Approximate | ~n | — | O(h log²h) |

### 实际效果

| 方案 | n | h | MN 所需提示 | 本文所需提示 | 降幅 |
|------|---|---|------------|------------|------|
| FHE bootstrapping | 32768 | 32 | 16384 | 320 | 98% |
| OpenFHE | 32768 | 192 | 16384 | ~3000 | 82% |

### 与格约减的关系
- 提示收集后**不需要 BKZ** — 仅用多项式时间线性代数
- 区别于 DDGR/MN/Cao 路线（提示→降维→格约减）
- 本文路线: 提示→NonZeroEntryGuess→直接恢复（无格约减）

## 关联

- 相关概念: [[concepts/lwe-hints-framework]], [[concepts/lattice-reduction]], [[concepts/modular-hints]]
- 参见: [[topics/lattice-reduction-attacks-on-lwe]]

## 引用来源

- [1] [[raw/paper-hhan2025-perfect-to-approx]] — O(h log²h) 算法和 GAA 分析
- [2] [[raw/paper-ddgr2020-lwe-side-info]] — 基础提示框架
- [3] [[raw/paper-may2023-too-many-hints]] — MN 的 n/2 阈值对比

## 变更记录

- 2026-08-05: 初始创建，来源 [[raw/paper-hhan2025-perfect-to-approx]]
