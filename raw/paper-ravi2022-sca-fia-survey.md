# Side-channel and Fault-injection Attacks over Lattice-based Post-quantum Schemes (Kyber, Dilithium): Survey and New Results

> **作者**: Prasanna Ravi, Anupam Chattopadhyay, Jan Pieter D'Anvers, Anubhab Baksi
> **发表**: ACM TECS 2024 (IACR ePrint 2022/737)
> **URL**: https://eprint.iacr.org/2022/737
> **类型**: 综述 — 格密码 SCA/FIA 系统性调查

## 摘要

本文对结构化格方案上的侧信道攻击（SCA）和故障注入攻击（FIA）进行了系统性研究，重点关注 Kyber KEM 和 Dilithium 签名方案。通过研究，试图理解现有攻击之间的相似性和差异，并将其分类。鉴于报告的攻击种类繁多，同时防护所有攻击需要为 Kyber 和 Dilithium 实现定制化防护。

## 核心贡献

### 1. 系统性攻击分类
- **SCA 分类**: KC-SCA vs CC-SCA（已知/选择密文）
- **FIA 分类**: 密钥恢复、消息恢复、签名伪造
- 涵盖 Kyber 和 Dilithium 的所有已知 SCA/FIA

### 2. 定制化防护措施
- 提出**多种定制防护**，同时防御多种 SCA/FIA
- **新颖防护**: 针对 Kyber KEM 的 CC-SCA 防护
- 防护集成在单一 Kyber/Dilithium 设计中

### 3. 双平台实现验证
- **pqm4 库**: ARM Cortex-M4 微控制器
- **liboqs 库**: Raspberry Pi 3 (ARM Cortex-A53)
- 性能评估显示定制防护开销合理

### 4. 防护策略主张
- 定制防护可用于实际格方案实现
- 可独立使用或作为通用防护（如掩码）的补充

## 攻击分类概览

| 攻击类型 | Kyber | Dilithium |
|----------|-------|-----------|
| SPA (单迹) | NTT 泄露 [Primas17, Pessl19] | 签名泄露 |
| DPA (多迹) | NTT, 解密 [多种] | 签名 |
| CC-SCA | PC/FD/DF Oracle [多种] | 签名伪造 |
| FIA 密钥恢复 | NTT FI [Ravi22/824] | nonce 重用 |
| FIA 签名伪造 | — | 验证绕过 |

## 历史意义

本文是格密码侧信道攻击的**最全面综述**，系统分类了 Kyber 和 Dilithium 的所有已知 SCA/FIA 攻击，是研究者进入该领域的必读参考。

## 关联
- 攻击者实体: [[entities/ravi-research-group]]
- 防护概念: [[concepts/masking-and-shuffling]], [[concepts/sca-classification-kc-vs-cc]]
- Kyber 实体: [[entities/kyber-kem]]
- Dilithium 实体: [[entities/dilithium]]
- 综述主题: [[topics/sca-countermeasures-for-lattice-pqc]]
- 相关攻击: [[raw/paper-primas2017-single-trace-lattice]], [[raw/paper-ravi2022-fiddling-twiddle-ntt]]
