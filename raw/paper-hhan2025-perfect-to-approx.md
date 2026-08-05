# From Perfect to Approximate Hints: Efficient LWE Secret Recovery Leveraging Low Hamming Weight

> **来源类型**: 论文 (Conference)
> **会议**: IEEE S&P 2026 (Symposium on Security and Privacy)
> **作者**: Minki Hhan, Ga Hee Hong, Jiseung Kim, Changmin Lee, JeongHwan Lee
> **年份**: 2025 (published 2026)
> **页数**: 15
> **原始文件**: `From Perfect to Approximate Hints Efficient LWE Secret Recovery Leveraging low hamming weight.pdf`

## 核心贡献

本文针对**稀疏三值秘密**（sparse ternary secret）的 LWE 问题，提出仅用 **O(h log²h)** 个近似/完美提示即可恢复密钥的新算法，其中 h 是秘密向量的汉明重量。此前 DDGR/MN 需要约 n/2 或 0.9n 个提示（n 为维度），而实际 FHE 方案中 n=2^15 或 2^16，使得此前阈值不切实际。本文将提示量从 O(n) 降到 O(h log²h)，对 h≪n 的稀疏秘密场景效果显著。

### 三大贡献

1. **O(h log²h) 提示阈值**: 利用稀疏三值结构，大幅减少所需提示量
2. **GAA 下界分析**: 在高斯近似假设下提供保守的成功概率下界
3. **OpenFHE 侧信道应用**: 展示 NTT 域泄漏可产生所需的完美/近似提示

## 核心算法：NonZeroEntryGuess

### 核心思想
给定 Integer-LWE 实例 (A, c = A·s + e)，其中 s ∈ T_n(h)（汉明重量为 h 的三值向量）：

1. 计算 X_j = ⟨A_j, c⟩（每列与 c 的内积）
2. 若 j ∈ J（s_j ≠ 0），则 |X_j| 较大（自相关项贡献）
3. 若 j ∉ J（s_j = 0），则 |X_j| 接近零
4. **贪心选取**: 选最大 |X_j|，恢复 s_j = sign(X_j)，更新 c ← c - s_j·A_j
5. 重复 h 次直到所有非零位置找到

### 算法形式
```
Algorithm: NonZeroEntryGuess
Input: (A, c, h)
1. K = ∅, s = (0,...,0)
2. while |K| < h:
   3. j = argmax_i |⟨A_i, c⟩|
   4. s_j = sign(⟨A_j, c⟩)
   5. c ← c - s_j · A_j  (更新：剥离已恢复分量)
   6. 删除 A 的第 j 列
3. return s
```

### 关键观察
- **自相关区分**: 非零系数位置的 X_j 期望值为 |μ| = m·q²/12，零位置期望值为 0
- **更新策略**: 每次恢复一个系数后更新 c，提高后续成功率
- **O(h log²h)**: 在 GAA 下，m = C·h·log²h（C≥2）即可获得非平凡成功概率

## 与已有工作的对比

| 方法 | 所需提示量 | 分析类型 | 适用场景 |
|------|----------|---------|---------|
| DDGR [CRYPTO 2020] | ~n/2 (perfect) | 理论 | 通用 LWE |
| MN [Asiacrypt 2023] | 0.9n (mod-q), n/2 (perfect) | 理论+实验 | 通用 LWE |
| Cao [CRYPTO 2025] | ~MN 的 1/7 | 理论+实验 | 通用 LWE |
| **本文** | **O(h log²h)** | 理论(GAA)+实验 | **稀疏三值秘密** |
| Nolte [26] | 启发式 | 纯实验 | 稀疏二值秘密 |
| Cheon [27] | 启发式 | 纯实验 | KRD 模型 |

### 对比 Nolte [26] 和 Cheon [27]
- Nolte: "Greedy recovery of cool bits" — 比较标准差，无分析保证
- Cheon: KRD 模型下的 bootstrapping failure — 纯实验
- **本文优势**: 首个提供 GAA 下的解析下界，且实验成功率优于两者

## FHE 参数集对比

| 方案 | n | h | 本文所需提示 | MN 所需提示 | 降幅 |
|------|---|---|------------|------------|------|
| FHE bootstrapping | 2^15 | 32 | 320 | 2^14 | 99.9% |
| OpenFHE | 2^15 | 192 | ~3000 | 2^14 | 81.7% |

## OpenFHE 侧信道泄漏

### NTT 域泄漏
- OpenFHE 的 Forward NTT 实现中，模约减和系数乘法引入泄漏
- **条件分支泄漏**: `if sum ≥ q then sum -= q` — 功耗差异暴露溢出信息
- **乘法泄漏**: 整数乘法后取模，攻击者可恢复乘积的整数值
- **组合**: 溢出信息 + 乘积值 → 构造完美提示 ⟨v, s⟩ = l

### 提示构造
- 从 NTT 的 twiddle factor（公开的）和中间值泄漏推导出 v
- v 的分布非均匀，但算法仍然有效
- **仅验证了完美提示**；近似提示在 OpenFHE 场景尚未验证

## 实验结果

### 基本参数
- n=512, h=8, m=⌊2h log²h⌉=48, q=100-bit prime, σ=3.19
- 100 次实验

### 关键发现
1. **m = 2h log²h 即可获得非平凡成功率**（~27-44%）
2. **m = 5h log²h 时成功率 → 100%**
3. **σ < q/8 时噪声影响不大**
4. **q 的大小不显著影响成功率**（Integer-LWE 特性）
5. **h 增大时成功率上升**（当 m 随 h 自适应增长时）

### 与 Nolte/Cheon 对比
- 在相同 m 下，本文成功率优于两者
- 特别是 h 较大时，Nolte 成功率下降而本文上升

## 理论分析（GAA）

### 高斯近似假设
- 每个评分变量 X_i 建模为独立高斯
- 非零位置: X_i ~ G(s_i·μ, σ₁)
- 零位置: X_i ~ G(0, σ₀)
- μ = m·q²/12（自相关贡献）

### 成功概率下界
- 使用 erf 函数精确计算尾概率
- 保守下界（实际成功率更高）
- 第 k 步的成功概率 p_k 随 k 递增（更新策略的效果）

## 与知识库中已有概念的关系

| 概念 | 关系 |
|------|------|
| [[concepts/lwe-hints-framework]] | 使用 perfect/approximate 提示，但利用稀疏性大幅降低阈值 |
| [[concepts/lattice-reduction]] | 提示收集后用多项式时间算法（非 BKZ）恢复 |
| [[concepts/modular-hints]] | 对比基准：mod-q 需 0.9n vs 本文 O(h log²h) |
| [[raw/paper-ddgr2020-lwe-side-info]] | 基础框架 |
| [[raw/paper-may2023-too-many-hints]] | 直接对比：MN 的 n/2 阈值 vs 本文 h log²h |

## 局限性

1. **仅适用稀疏三值秘密**: s ∈ {-1, 0, 1}^n，不适用 Kyber 的 CBD 秘密
2. **GAA 假设**: 理论保证是启发式的，实际成功率高于下界
3. **OpenFHE 近似提示未验证**: 仅完美提示在 OpenFHE 场景实验验证
4. **非均匀 v 的影响**: NTT 泄漏产生的 v 非均匀分布，理论上仍有效但分析不完整

## 变更记录
- 2026-08-05: 初始创建，来源 PDF 提取
