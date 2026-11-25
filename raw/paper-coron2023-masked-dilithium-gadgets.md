# Improved Gadgets for the High-Order Masking of Dilithium

> **作者**: Jean-Sébastien Coron, François Gérard, Matthias Trannoy, Rina Zeitoun
> **发表**: TCHES 2023 (IACR ePrint 2023/896)
> **URL**: https://eprint.iacr.org/2023/896
> **类型**: Dilithium 防护 — 高阶掩码

## 摘要

本文提出了 Dilithium 的新型改进高阶掩码 gadgets。Dilithium 是 NIST 标准化的后量子签名方案。提出的 gadgets 包括 ShiftMod 小工具（高效算术移位），以及新的布尔到算术掩码转换算法（复杂度与 μ 和 q 均无关）。此外还改进了 Decompose 函数的掩码技术。所有新 gadgets 在 t-探测模型中证明安全。

## 核心贡献

### 1. ShiftMod 小工具
- 用于高效的算术移位
- 作为其他掩码 gadgets 的组成模块

### 2. 布尔到算术掩码转换
- 将 μ 位整数 x 模任意 q 进行布尔到算术掩码转换
- **复杂度与 μ 和 q 均无关**（重要改进）
- 用于 Dilithium 中掩码随机变量 y 模 q 的生成

### 3. Decompose 函数掩码改进
- 改进 Dilithium 中 Decompose 函数的掩码技术

### 4. 完整实现与验证
- 完整的高阶掩码 Dilithium 实现
- t-探测模型安全性证明
- C 实现性能评估
- 与先前工作的效率比较

## 关键技术细节

- **安全模型**: ISW t-探测模型
- **掩码阶数**: 任意阶（高阶）
- **目标**: Dilithium 签名方案
- **关键 gadgets**: ShiftMod, Boolean-to-Arithmetic conversion, masked Decompose
- **实现**: C 语言，完整签名

## 后续工作

- Coron 等人在 TCHES 2024 进一步改进了掩码向量 y 生成和拒绝采样 [[concepts/masking-and-shuffling]]
- Hermelink 2025 在 CRYPTO 2025 分析了掩码 ML-DSA 的最薄弱环节 [[raw/paper-hermelink2025-masked-mldsa-attack]]

## 关联
- Dilithium 实体: [[entities/dilithium]]
- 防护概念: [[concepts/masking-and-shuffling]]
- 后续攻击: [[raw/paper-hermelink2025-masked-mldsa-attack]]
- 硬件实现: [[raw/paper-raj2024-mldsa-hardware-masking]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
