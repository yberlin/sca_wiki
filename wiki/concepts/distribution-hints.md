# 分布提示（Distribution Hints）

> **类型**: concept
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-hermelink2025-generic-framework]], [[raw/paper-dachman2023-geometric]]

## 摘要

分布提示是 Hermelink et al. (2025) 提出的统一种提示类型，允许建模概率信息。它泛化了 DDGR 定义的所有提示类型（除短向量提示），并可直接处理 HW 泄漏、非正态噪声、部分错误信息——这些在实际侧信道攻击中普遍存在但此前难以建模。

## 详情

### 定义
- 形式: `⟨v, x⟩ + c` 服从某分布 D（而非确定值）
- **泛化能力**:
  - 完美提示: D 为点分布
  - 近似提示: D 为高斯分布
  - 不等式提示: D 在区间内均匀（[[raw/paper-dachman2023-geometric]] 从几何视角首次定义）
  - HW 泄漏: D 为 HW → 值的映射分布

### 两种求解器

#### BP 求解器
- 全连接因子图
- 变量节点: 密钥系数 x_j
- 因子节点: 分布提示
- 消息传递: 迭代更新边缘分布
- 优势: 理论上信息效率最高
- 劣势: 计算密集、高内存、噪声鲁棒性差

#### 贪心求解器
- 从最可能猜测 x' 出发
- 每轮选择使违反提示惩罚最小的操作 (j, c)
- **理论关系**: BP 的计算更省近似
- 优势: 快速、低内存、噪声鲁棒
- 劣势: 理论上需要更多提示

### 贪心 vs BP: 互补关系

> ⚠️ 矛盾标注: 关于贪心与 BP 的关系，本知识库中存在两种观点：
> - **Ravi 2024** [[raw/paper-ravi2024-defeating-lcc]]: 声称贪心**优于** BP（不等式需求减半，速度快 30×）
> - **Hermelink 2025** [[raw/paper-hermelink2025-generic-framework]]: 证明贪心是 BP 的**近似**，两者互补。贪心在大提示量/噪声场景更实用，但 BP 在少提示/低噪声时信息效率更高。
> 
> **调和**: Ravi 的对比可能受到 BP 实现的近似（[Del22] 的 FFT 截断）影响。Hermelink 的分析表明，理想 BP 更优，但实际实现中贪心可能胜出。

### 运行时间 (40 核 Intel Xeon Gold 6230)

| 设置 | 贪心 | BP |
|------|------|-----|
| Approximate (2000) | 0.97-1.44 min | 38.58-57.43 min |
| Approximate (5000) | 0.26-0.65 min | 13.35-30.27 min |
| Perfect (2000) | 0.74-1.09 min | 9.67-11.56 min |
| Perfect (5000) | 0.19-0.34 min | 9.68-15.68 min |

### 实际应用
1. **改进 Ravi 2024 攻击**: 信息需求减少 >2×，使更高噪声水平可行
2. **INTT 攻击改进**: 分布提示可改进 [PPM17, BBB+23] 的单迹攻击
3. **新攻击方向**: 概述了 ML-KEM 解密例程的未探索攻击

### 与格约减方法的互补

| 场景 | 推荐方法 |
|------|---------|
| 不等式系数与密钥不相关 | 分布提示 (BP/贪心) |
| 完美/模提示在 s 上 | 格约减 [MN, Cao] |
| HW 泄漏 | 分布提示 |
| 有错误的提示 | 分布提示 |
| 小系数近似提示 | 分布提示 |
| 大系数近似提示 | 格约减 [DDGR] |

## 关联
- 相关实体: [[entities/kyber-kem]]
- 相关概念: [[concepts/lwe-hints-framework]], [[concepts/greedy-solver]], [[concepts/lattice-reduction]]
- 参见: [[topics/lattice-reduction-attacks-on-lwe]], [[topics/sca-countermeasures-for-lattice-pqc]]

## 引用来源
- [1] [[raw/paper-hermelink2025-generic-framework]] — 分布提示定义和求解器
- [2] [[raw/paper-ravi2024-defeating-lcc]] — 贪心 vs BP 对比（不同观点）
- [3] [[raw/paper-dachman2023-geometric]] — 不等式提示的几何起源

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-hermelink2025-generic-framework]]
- 2026-08-05: 更新——添加几何视角论文来源，标注不等式提示的几何起源
