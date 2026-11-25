# Improved ML-DSA Hardware Implementation With First Order Masking Countermeasure

> **作者**: Kamal Raj, Prasanna Ravi, Tee Kiah Chia, Anupam Chattopadhyay
> **发表**: IACR ePrint 2024/1817 (预印本)
> **URL**: https://eprint.iacr.org/2024/1817
> **类型**: Dilithium 防护 — 硬件一阶掩码

## 摘要

本文提出 ML-DSA 的受保护硬件实现。ML-DSA 是 Dilithium 3.1 的扩展，是后量子密码竞赛数字签名类别的获胜者。设计基于现有的高性能 Dilithium 3.1 设计。在硬件中实现了此前仅在软件中实现的 Dilithium 掩码 gadgets，集成到未受保护的 ML-DSA 设计中，并通过 KAT 验证功能正确性。

## 核心贡献

### 1. 首个 ML-DSA 受保护硬件实现
- 基于高性能 Dilithium 3.1 硬件设计
- 将软件掩码 gadgets 移植到硬件
- KAT 验证功能正确性

### 2. 实际侧信道评估
- 在标准侧信道评估 FPGA 板上实现
- 收集高达 100 万条功率迹线
- 实验结果表明抗侧信道攻击

### 3. 开销评估
| 资源 | 开销 |
|------|------|
| LUT | 1.127× |
| Flip-Flop | 1.2× |
| 执行时间 | 3.78× |

### 4. 掩码验证
- 一阶掩码
- FPGA 平台
- TVLA (Test Vector Leakage Assessment) 验证

## 关键技术细节

- **掩码阶数**: 一阶
- **平台**: 侧信道评估 FPGA 板
- **迹线数**: 高达 1,000,000
- **gadgets**: 从软件移植到硬件
- **安全模型**: 一阶 DPA 防护

## 与已有工作的关系

- **软件掩码基础**: Coron 2023 的高阶掩码 gadgets [[raw/paper-coron2023-masked-dilithium-gadgets]]（本文将类似 gadgets 硬件化）
- **攻击评估**: Hermelink 2025 分析了掩码 ML-DSA 的最薄弱环节 [[raw/paper-hermelink2025-masked-mldsa-attack]]
- **综述背景**: Ravi 2022 综述 [[raw/paper-ravi2022-sca-fia-survey]] 讨论了防护需求

## 关联
- 软件掩码: [[raw/paper-coron2023-masked-dilithium-gadgets]]
- 攻击评估: [[raw/paper-hermelink2025-masked-mldsa-attack]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- Dilithium 实体: [[entities/dilithium]]
- 防护概念: [[concepts/masking-and-shuffling]]
- 攻击者实体: [[entities/ravi-research-group]]
