# Breaking DPA-Protected Kyber via the Pair-Pointwise Multiplication

> **作者**: Estuardo Alpirez Bock, Gustavo Banegas, Chris Brzuska, Lukasz Chmielewski, Kirthivaasan Puniamurthy, Milan Sorf
> **发表**: ACNS 2024 (IACR ePrint 2023/551)
> **URL**: https://eprint.iacr.org/2023/551
> **类型**: Kyber SCA — 突破掩码防护

## 摘要

本文提出了一种新的模板攻击，利用解封装过程中多项式乘法的侧信道信息来恢复 Kyber 的私钥。攻击利用 Kyber 的不完整 NTT 导致每个秘密系数被多次使用的特点（与完整 NTT 不同），这是一种单迹已知密文攻击，避免使用机器学习技术，仅依赖相关匹配。

## 核心贡献

### 1. 不完整 NTT 的弱点
- Kyber-768 使用**不完整 NTT**（incomplete NTT）
- 每个秘密系数在 pair-pointwise multiplication 中被**多次使用**
- 这引入了额外的侧信道弱点

### 2. 单迹模板攻击
- **不需机器学习**，仅用相关匹配
- 模板生成方法简单、易复现
- 描述不同攻击策略（不同模板数量）

### 3. 突破掩码和洗牌
- 适用于**掩码实现**和**乘法洗牌**设计
- 目标: mkm4 仓库的掩码实现

### 4. 实验验证
- 噪声汉明权重模型仿真: 13316 个模板，σ=0.3 噪声下高成功率
- 实际功率测量: 从单项式乘法恢复 128 个系数对
- 扩展方法（在线模板攻击启发）实现完整恢复

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击类型 | 单迹 KC-SCA |
| 目标 | Pair-pointwise multiplication (解封装) |
| 方法 | 模板攻击 + 相关匹配 |
| 模板数 | 13316 |
| 适用对象 | 掩码 + 洗牌实现 |
| 目标实现 | mkm4 仓库 |
| 噪声容忍 | σ ≤ 0.3 |

## 与已有工作的关系

- **互补**: Primas/Pessl 攻击 NTT 本身，本文攻击 pair-pointwise multiplication
- **弱点发现**: 不完整 NTT 是 Kyber 特有的额外弱点
- **防护挑战**: 证明掩码和洗牌都不足以单独防护

## 关联
- NTT 攻击基础: [[raw/paper-primas2017-single-trace-lattice]], [[raw/paper-pessl2019-practical-ntt]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- 防护概念: [[concepts/masking-and-shuffling]]
- Kyber 实体: [[entities/kyber-kem]]
- 分类: [[concepts/sca-classification-kc-vs-cc]]
