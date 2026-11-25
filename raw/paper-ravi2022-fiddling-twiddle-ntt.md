# Fiddling the Twiddle Constants — Fault Injection Analysis of the Number Theoretic Transform

> **作者**: Prasanna Ravi, Bolin Yang, Shivam Bhasin, Fan Zhang, Anupam Chattopadhyay
> **发表**: IACR ePrint 2022/824 (预印本)
> **URL**: https://eprint.iacr.org/2022/824
> **类型**: 故障注入 — NTT 故障分析

## 摘要

本文提出了首次对数论变换（NTT）的故障注入分析。NTT 是多项式乘法的核心计算单元，广泛用于多个结构化格 KEM 和数字签名方案。我们识别了 NTT 中的关键单故障漏洞，严重降低其输出熵，从而可以进行从密钥恢复到消息恢复到签名伪造的多种攻击。

## 核心贡献

### 1. NTT 单故障漏洞
- 识别 NTT 中 twiddle 常数的单故障漏洞
- 故障严重降低 NTT 输出熵
- 适用于格 KEM 和签名方案

### 2. Kyber 攻击
- **密钥恢复**: 针对密钥生成
- **消息恢复**: 针对加密过程

### 3. Dilithium 攻击
- **存在性签名伪造**: 针对确定性签名和概率签名
- **验证绕过**: 针对验证过程

### 4. 电磁故障注入验证
- 所有攻击均通过电磁故障注入（EMFI）在 ARM Cortex-M4 上验证
- 目标: pqm4 库的 Kyber 和 Dilithium 实现
- 高成功率

## 关键技术细节

- **攻击方法**: 电磁故障注入（EMFI）
- **目标组件**: NTT 中的 twiddle 常数
- **故障模型**: 单故障使输出熵降低
- **平台**: ARM Cortex-M4 (pqm4 库)
- **影响范围**: Kyber KEM + Dilithium 签名

## 与已有工作的关系

- **同一作者**: Ravi 团队后续发布了综述 [[raw/paper-ravi2022-sca-fia-survey]]
- **故障注入拓展**: 后续 Wang 2024 针对Keccak 的故障攻击 [[raw/paper-wang2024-keccak-fault]]
- **NTT 攻击关联**: 与 NTT SCA 攻击 [Primas17, Pessl19] 互补——一个从被动侧信道，一个从主动故障

> ⚠️ 特别标注: 本文作者 Bolin Yang 即当前知识库用户

## 关联
- 攻击者实体: [[entities/ravi-research-group]], [[entities/pqm4-library]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- Kyber 实体: [[entities/kyber-kem]]
- Dilithium 实体: [[entities/dilithium]]
- 故障概念: [[concepts/fault-injection]]
- 相关攻击: [[raw/paper-primas2017-single-trace-lattice]] (被动 SCA vs 主动 FI)
