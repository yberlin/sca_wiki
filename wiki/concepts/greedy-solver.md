# 贪心求解器（Greedy Solver）用于线性不等式密钥恢复

> **类型**: concept
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ravi2024-defeating-lcc]]

## 摘要

本论文提出的新型贪心搜索求解器，从侧信道泄漏构建的线性不等式组中恢复秘密密钥。相比 Pessl & Prokop [PP21] 和 Delvaux [Del22] 的置信传播（Belief Propagation, BP）方法，该求解器更简单、更高效、所需不等式不到 BP 的一半，且对噪声更鲁棒。

## 详情

### 问题形式化

给定线性不等式组 `H·x + w ≥ 0`，其中：
- `x ∈ Z_q^{2kn}` 是待求的 `[poly_to_vec(e) ∥ poly_to_vec(s)]`
- `H ∈ Z_q^{2γ × 2kn}` 是不等式矩阵
- `w ∈ Z_q^{2γ}` 是偏移向量
- `γ` 是不等式对数（每对对应一个 m[i]=0 的观测）

### 不等式构建
对于 m_j[i] = 0 的观测（此时 m'[i] = Δm[i]）：
- 从 HW(m'[i]) 查表得到 `ω(i,j)` 和 `Ω(i,j)`
- 构建两条不等式: `ω(i,j) ≤ Δm_j[i] ≤ Ω(i,j)`
- 展开为: `h^(i,j) · [e∥s] + (e2)_j[i] + Δv_j[i] - ω(i,j) ≥ 0` 和 `-h^(i,j) · [e∥s] - (e2)_j[i] - Δv_j[i] + Ω(i,j) ≥ 0`

### HW 到 Δm 的信息提取

| HW(m'[i]) | max m'[i] | min m'[i] | spread |
|-----------|----------|----------|--------|
| 0 | 0 | 0 | 0 |
| 1 | 256 | 1 | 255 |
| 5 | 351 | -250 | 601 |
| 6 | 324 | -352 | 676 |
| 10 | 253 | -319 | 572 |
| 16 | -1 | -1 | 0 |

- m[i]=0 时，低 HW → Δm[i]>0 概率高；高 HW → Δm[i]<0 概率高
- m[i]=1 时，正负噪声 HW 分布接近，难以提取信息
- **最优 spread 过滤**: max_spread = 317

### 贪心算法（Algorithm 7）
1. 初始化 `x = 0`
2. 每轮迭代:
   - 对每个 `(j, v)` 计算 score: 应用 `x[j] += v` 后，违反的不等式惩罚之和
   - 选择 top-α_it 个 score 最高的操作
   - 对每个选中的 j，重新计算最佳 v 并应用
3. α_it 随迭代轮数指数衰减
4. 收敛到正确密钥

### Score 函数（Algorithm 8）
```
score = 0
t = H·x + w + v·H_j  (应用操作后的目标向量)
for each inequality i:
    if t[i] < 0:
        score -= |t[i]|  (按违反距离惩罚)
```

### 与 BP 的对比

| 维度 | 贪心求解器 | BP [PP21, Del22] |
|-----|----------|------------------|
| 所需不等式 | <2× (更少) | 基准 |
| σ=0.5 运行时间 | <20 秒 | >10 分钟 |
| 噪声鲁棒性 | 好 | 快速退化 |
| 理解难度 | 简单 | 复杂 |
| 内存需求 | 低 | 高（大量不等式时） |
| 掩码场景适用 | ✓ | ✗ (不等式太多) |

### 掩码场景适配
- 一阶掩码: 构建 17×17 的 max/min 表（HW of share0 × HW of share1）
- 表的构建无需 SCA，仅依赖实现（100,000 次解密模拟）
- 将表直接转换为不等式输入贪心求解器

### 理论统一：贪心作为 BP 的近似

> ⚠️ 矛盾标注: [[raw/paper-hermelink2025-generic-framework]] (Hermelink 2025) 提供了更深入的理论分析：
> - **Ravi 2024 观点**: 贪心**优于** BP（不等式需求减半，速度快 30×）
> - **Hermelink 2025 观点**: 贪心是 BP 的**计算更省近似**——理论上需要更多提示，但实际中因 BP 数值问题和内存限制，贪心可能胜出
> - **调和**: Ravi 的对比可能受 BP 实现的 FFT 截断近似影响。理想 BP 信息效率更高，但在大提示量/高噪声场景中贪心更实用。两者**互补**。

Hermelink 2025 将贪心和 BP 统一在 [[concepts/distribution-hints|分布提示]] 框架下，证明此前特定攻击的算法都是这两个求解器的特例。

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/ravi-research-group]]
- 相关概念: [[concepts/decapsulation-failure-check]], [[concepts/masking-and-shuffling]], [[concepts/distribution-hints]], [[concepts/lwe-hints-framework]]
- 参见: [[topics/sca-countermeasures-for-lattice-pqc]], [[topics/lattice-reduction-attacks-on-lwe]]

## 引用来源
- [1] [[raw/paper-ravi2024-defeating-lcc]] — 求解器算法与对比
- [2] [PP21] Pessl & Prokop, BP 方法原始论文
- [3] [Del22] Delvaux, BP 改进
- [4] [[raw/paper-hermelink2025-generic-framework]] — 理论统一：贪心是 BP 的近似

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-ravi2024-defeating-lcc]]
- 2026-08-05: 更新——添加 Hermelink 2025 的理论统一分析和矛盾标注，来源 [[raw/paper-hermelink2025-generic-framework]]
