# 格约减攻击：LLL 与 BKZ

> **类型**: concept
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ddgr2020-lwe-side-info]], [[raw/paper-may2023-too-many-hints]], [[raw/paper-cao2025-refined-attack]], [[raw/paper-li2025-hertzbleed-hints]], [[raw/paper-fouque2025-avengers]]

## 摘要

格约减是求解 LWE 的核心工具。LLL 是多项式时间的弱归约算法；BKZ 是更强的归约算法，块大小 β 越大约减越强但越慢。侧信道提示通过降低 LWE 维度/体积，使得弱归约（LLL）即可恢复密钥，或降低 BKZ 所需的 β 值。

## 详情

### LLL (Lenstra-Lenstra-Lovász)
- **复杂度**: 多项式时间
- **约减质量**: 弱，但在低维度（~60-150）下足够恢复短向量
- **应用场景**: "Too many hints" 制度——提示量足够大时 LLL 即可
- **实例**:
  - Kyber-512: 449 mod-q 或 234 perfect 提示 → LLL 20 min / 3 h
  - NTRU-509: 226 perfect → LLL 2.3 min

### BKZ (Blockwise Korkine-Zolotarev)
- **复杂度**: 指数级（β 越大越慢）
- **约减质量**: 强，β 越大越接近 SVP 最优
- **应用场景**: 提示量不足以用 LLL 时
- **G6K 框架**: 通用筛格核，实现 Pump and Jump BKZ
  - Li 2025: Kyber 简化方案用 G6K β=25-36, 400 秒恢复密钥
  - NTTRU: β=117, 复杂度 2^34（Core-SVP 估计）

### 维度与归约算法的选择

```
提示数量 ──→ 剩余维度 n-k ──→ 所需归约
  n (全部)  →  0        →  高斯消元
  0.9n     →  ~0.1n(60-66) → LLL
  n/2      →  ~n/2       → LLL (perfect hints 更强)
  37-46% (Avengers) → ~n/2 → 高斯消元 or BKZ β=23-65
  O(h log²h) (Hhan, sparse) → 0 → 多项式时间线性代数
  <n/2     →  >n/2      → BKZ (β 随维度增大)
  0        →  n          → BKZ (β≈300+, 不可行)
```

### Avengers (Fouque 2025) 实际 BKZ 实验数据
- Kyber-512 (η₁=3): 最差 ρ≈37%, β=65, <18h; 最佳 β=0 (高斯消元, <1s)
- Kyber-768 (η₁=2): 最差 ρ≈43%, β=23, <18h; 最佳 β=0 (<1s)
- Kyber-1024 (η₁=2): 最差 ρ≈46%, β=25, <18h; 最佳 β=0 (<1s)
- 使用 fplll/SageMath BKZ 实现
- 平均成功率: Kyber-512 96.7%, Kyber-768 99.98%, Kyber-1024 100%

### 各方案的归约需求

| 方案 | n | LLL 可解维度 | LLL mod-q k | LLL perfect k | BKZ β (无提示) |
|------|---|------------|-------------|---------------|---------------|
| Kyber-512 | 512 | ~63 | 449 | 234 | ~400+ |
| Kyber-768 | 768 | ~66 | 702 | 390 | ~500+ |
| NTRU-701 | 701 | ~79 | 622 | 332 | ~500+ |
| Dilithium-1024 | 1024 | ~148 | 876 | 463 | ~700+ |

### Primal Attack 估值
- 从 LWE 实例构造 CVP（最近向量问题）→ 用 Kannan 嵌入转为 SVP
- DDGR 将此流程精化为 LWE → [[concepts/dbdd|DBDD]] → uSVP → 格约减
- 提示集成后计算剩余 BKZ 块大小 β_req
- Core-SVP 估值: 2^(c·β) 为计算复杂度下界
- DDGR 提供开源 Sage 工具自动计算 β_req

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/nttru]], [[entities/dilithium]]
- 相关概念: [[concepts/lwe-hints-framework]], [[concepts/modular-hints]], [[concepts/dbdd]], [[concepts/sparse-secret-lwe]]
- 参见: [[topics/lattice-reduction-attacks-on-lwe]]

## 引用来源
- [1] [[raw/paper-ddgr2020-lwe-side-info]] — Primal attack with hints, DBDD→uSVP→BKZ 流程, Sage 工具
- [2] [[raw/paper-may2023-too-many-hints]] — LLL/BKZ 可行性阈值
- [3] [[raw/paper-cao2025-refined-attack]] — REF 归约替代 LLL
- [4] [[raw/paper-li2025-hertzbleed-hints]] — G6K BKZ 实验结果
- [5] [[raw/paper-fouque2025-avengers]] — 实际 BKZ β=23-65 实验，"way too many hints" 高斯消元

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-may2023-too-many-hints]]
- 2026-08-05: 更新——添加 DDGR 来源引用、DBDD 概念链接、Sage 工具说明
- 2026-08-05: 更新——添加 Fouque 2025 实际 BKZ 实验数据和"way too many hints"制度
