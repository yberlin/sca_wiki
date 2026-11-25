# Finding and Protecting the Weakest Link — On Side-Channel Attacks on y in Masked ML-DSA

> **作者**: Julius Hermelink, Kai-Chun Ning, Richard Petri
> **发表**: CRYPTO 2025 (IACR ePrint 2025/276)
> **URL**: https://eprint.iacr.org/2025/276
> **类型**: Dilithium SCA — 掩码 ML-DSA 攻击与防护

## 摘要

NIST 标准化了 ML-KEM 和 ML-DSA。两者都已有侧信道分析，并已有首个完全掩码的 ML-DSA 实现。之前的攻击聚焦于未受保护的实现或假设仅有隐藏防护。因此，与 ML-KEM 不同，受保护 ML-DSA 实现的侧信道威胁大多不明确。本文分析了掩码 ML-DSA 实现的侧信道脆弱性。

## 核心贡献

### 1. 系统脆弱性评估
- 使用**信息论**系统评估多个潜在攻击点
- 不同泄露模型下的脆弱性分析
- 识别 y（随机多项式）为最薄弱环节

### 2. 阶数攻击框架
- 使用最近提出的格方案侧信道信息框架
- 展示如何发起一阶、二阶和高阶攻击
- 提出过滤技术解决大量 hints 的数值不稳定问题

### 3. 过滤技术
- 允许框架从大量 hints 中求解私钥
- 此前数值不稳定阻碍了这一过程
- 关键技术贡献

### 4. 实际设备验证
- 在物理设备上执行相关攻击
- 讨论最近的掩码实现
- 实例化针对最具威胁攻击的防护

### 5. 低开销防护
- 针对最高噪声容忍度的攻击
- 非常低的开销
- 物理设备验证仿真结果

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 目标 | 掩码 ML-DSA 中的 y（随机多项式） |
| 评估方法 | 信息论分析 |
| 攻击阶数 | 一阶、二阶、高阶 |
| 框架 | 格方案侧信道信息框架 (BP) |
| 过滤技术 | 解决数值不稳定 |
| 防护 | 低开销，针对最薄弱环节 |
| 会议 | CRYPTO 2025 |

## 与已有工作的关系

- **同一作者**: Hermelink 也是分布提示框架 [[raw/paper-hermelink2025-generic-framework]] 和 BP 洗牌突破 [[raw/paper-hermelink2022-bp-shuffling-ntt]] 的作者
- **掩码基础**: Coron 2023 的高阶掩码 gadgets [[raw/paper-coron2023-masked-dilithium-gadgets]]
- **硬件评估**: Raj 2024 的 ML-DSA 硬件掩码 [[raw/paper-raj2024-mldsa-hardware-masking]]
- **BP 框架**: 与 distribution hints 和 greedy solver 密切相关

## 关联
- 作者相关工作: [[raw/paper-hermelink2025-generic-framework]], [[raw/paper-hermelink2022-bp-shuffling-ntt]]
- 掩码基础: [[raw/paper-coron2023-masked-dilithium-gadgets]]
- 硬件防护: [[raw/paper-raj2024-mldsa-hardware-masking]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- Dilithium 实体: [[entities/dilithium]]
- BP 概念: [[concepts/greedy-solver]], [[concepts/distribution-hints]]
- 防护概念: [[concepts/masking-and-shuffling]]
