# DBDD (畸变有界距离解码)

> **类型**: concept
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ddgr2020-lwe-side-info]], [[raw/paper-dachman2023-geometric]]

## 摘要

DBDD（Distorted Bounded Distance Decoding，畸变有界距离解码）是 DDGR [CRYPTO 2020] 引入的中间问题，介于 LWE 和 uSVP（唯一最短向量问题）之间。它允许通过"畸变矩阵"建模各维度上不同权重的距离度量，从而自然地集成各种类型的侧信道提示。DBDD 是 LWE with Hints 框架中提示集成的核心载体。

## 详情

### 问题定义

给定：
- 格 L ⊂ Z^n
- 中心 c ∈ Z^n
- 畸变矩阵 B（正定矩阵，建模各维度权重）
- 距离上界 d

**DBDD 实例 (L, c, B, d)**: 找到唯一的 x ∈ L 使得 ||x - c||_B ≤ d，其中 ||y||_B = √(y^T · B · y)

### 与标准 BDD 的区别

| 特性 | BDD | DBDD |
|------|-----|------|
| 距离度量 | 欧氏距离 ||·||₂ | 畸变距离 ||·||_B |
| 各维度权重 | 均等 | 由 B 矩阵控制 |
| 几何形状 | 球 | 椭球 |
| 适用场景 | 标准 LWE | 带提示的 LWE |

### 从 LWE 到 DBDD

```
LWE:  b = A·s + e
  ↓ 标准转换
BDD:  在格 L(A^⊥) 中找最近向量
  ↓ 加入畸变（噪声分布信息）
DBDD: 在畸变距离下找最近向量
  ↓ Kannan 嵌入
uSVP: 找唯一最短向量
  ↓ 格约减
密钥恢复
```

### 提示集成

DBDD 的核心价值在于提示集成——每种提示对应一种对 DBDD 实例的修改：

| 提示类型 | DBDD 修改 | 几何意义 | 效果 |
|---------|----------|---------|------|
| 完美提示 | 超平面投影 → 降维 | 椭球 ∩ 超平面 | 维度 n → n-1 |
| 模提示 | 平行超平面族投影 | 椭球 ∩ 多超平面 | 维度 n → n-k |
| 近似提示 | 修改畸变矩阵 B | 椭球缩放+交叉 | 降低体积 |
| 短向量提示 | 添加格关系 | 椭球 ∩ 格陪集 | 改善格结构 |
| 不等式提示 | 半空间交叉 | 椭球 ∩ 半空间 | 降低体积 |

### 椭球表示与几何运算

DDGR [CRYPTO 2020] 原始处理为逐步代数运算；Dachman-Soled [CRYPTO 2023] 重新用椭球几何统一表示：

- **DBDD 实例** = 椭球 E = { x : (x-c)^T · B^{-1} · (x-c) ≤ 1 }
- **提示集成** = 椭球与约束区域的交叉
- **近似** = 用 Löwner-John 最小体积包含椭球近似交叉结果

### 体积与安全估计

- **椭球体积** ∝ det(B)^{1/2} · V_n（n维单位球体积）
- **格体积** = det(L)
- **安全度量** = bikz = log₂(格体积 / 椭球体积) 的函数
- **提示集成后**: 体积下降 → bikz 下降 → 所需 BKZ 块大小 β 下降

### Sage 工具

DDGR 提供了开源 SageMath 工具包：
- 初始化 DBDD 实例
- 逐步集成提示
- 自动计算剩余 BKZ 块大小
- 输出安全估计（bikz 值）

## 关联

- 相关概念: [[concepts/lwe-hints-framework]], [[concepts/lattice-reduction]]
- 相关实体: [[entities/kyber-kem]]
- 参见: [[topics/lattice-reduction-attacks-on-lwe]]

## 引用来源

- [1] [[raw/paper-ddgr2020-lwe-side-info]] — DBDD 定义、提示集成、Sage 工具
- [2] [[raw/paper-dachman2023-geometric]] — 椭球几何视角重访 DBDD
- [3] [[raw/paper-may2023-too-many-hints]] — 用代数方法替代 DBDD 逐步集成
- [4] [[raw/paper-cao2025-refined-attack]] — 用高斯消元替代 DBDD 降维

## 变更记录

- 2026-08-05: 初始创建，来源 [[raw/paper-ddgr2020-lwe-side-info]] 和 [[raw/paper-dachman2023-geometric]]
