# Single-Trace Side-Channel Attacks on Masked Lattice-Based Encryption

> **作者**: Robert Primas, Peter Pessl, Stefan Mangard
> **发表**: CHES 2017 (IACR ePrint 2017/594)
> **URL**: https://eprint.iacr.org/2017/594
> **类型**: 基础工作 — 首个格密码单迹侧信道攻击

## 摘要

虽然格密码已被证明是后量子密码学中特别高效的方法，但其对侧信道攻击的安全性仍然是一个开放问题。已经存在一些使用掩码实现 DPA 安全的初步工作。然而，对于公钥原语，仅使用单条迹线的 SPA 攻击同样高度相关。对于格密码，这一实现安全方面仍未探索。

本文提出了首个针对格加密的单迹攻击。由于仅需一次侧信道观测即可实现完全密钥恢复，因此也可用于攻击掩码实现。攻击利用来自数论变换（NTT）的泄露，NTT 是几乎所有高效格实现的核心组件。

## 核心贡献

### 1. 三步攻击框架
1. **模板匹配**: 对解密过程中所有模运算执行模板匹配
2. **信念传播（BP）**: 高效组合所有侧信道信息
3. **格解码**: 执行格解码恢复私钥

### 2. 单迹攻击能力
- 仅需一条功率迹线即可实现完全密钥恢复
- 可攻击掩码实现（因为单迹攻击不受掩码的 DPA 防护影响）
- 基于 ARM Cortex-M4F 微控制器实际测量验证

### 3. 通用性
- 攻击 NTT 泄露，NTT 是几乎所有高效格实现的核心
- 可适配到大量其他格构造及其实现

## 关键技术细节

- **攻击目标**: NTT 中的模运算（解密过程）
- **攻击者模型**: 已知密文（KC-SCA），模板攻击者
- **模板数量**: 接近百万个多变量模板
- **后处理**: 信念传播 + 格解码
- **平台**: ARM Cortex-M4F
- **泄露模型**: 变时间实现

## 历史意义

本文是格密码侧信道攻击的**奠基性工作**，首次证明了单迹攻击对格加密的可行性。后续工作（Pessl & Primas 2019, Hamburg 2021, Hermelink 2022 等）均在此基础上改进。

## 关联
- 后续改进: [[raw/paper-pessl2019-practical-ntt]]
- BP 框架扩展: [[raw/paper-hermelink2022-bp-shuffling-ntt]]
- 综述引用: [[raw/paper-ravi2022-sca-fia-survey]]
- 相关概念: [[concepts/sca-classification-kc-vs-cc]], [[concepts/greedy-solver]]
