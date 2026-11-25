# Probabilistic Algorithms with Applications to Countering Fault Attacks on Lattice-based Post-Quantum Cryptography

> **作者**: Nimish Mishra, Debdeep Mukhopadhyay
> **发表**: IACR ePrint 2024/551 (2024)
> **URL**: https://eprint.iacr.org/2024/551
> **类型**: FI 防护 — 概率化防护框架

## 摘要

利用有效/无效故障传播的故障攻击比差分故障攻击具有更丰富的攻击面。最近提出了多种基于传播的格 KEM 故障攻击，其中许多没有已知防护。本文提出一种正交防护原理，不依赖临时策略（如洗牌秘密系数），而是依赖密码学保证提供可量化的防御。具体来说，提出使用拒绝采样将确定性算法转换为概率性算法的框架。

## 核心贡献

### 1. 概率化防护框架
- 使用拒绝采样将确定性算法转为概率性算法
- 密码学保证的可量化防御
- 非临时策略（非洗牌等临时方法）

### 2. 恒定重试次数
- 正确执行: 成功概率极高（2-3 次重试）
- 故障注入: 成功概率可忽略
- 选择特定分布使框架以恒定重试次数运行

### 3. 适用范围
- Kyber
- NewHope
- Masked Kyber
- 完全切断已知故障攻击的传播

### 4. 正交防护
- 与现有防护（掩码、洗牌）正交
- 可组合使用

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 防护类型 | 概率化（拒绝采样） |
| 适用方案 | Kyber, NewHope, Masked Kyber |
| 重试次数 | 2-3 (正常执行) |
| 故障成功率 | 可忽略 |
| 防护性质 | 正交（可组合） |

## 与已有工作的关系

- **防护对象**: Pessl & Prokop 2021 [[raw/paper-pessl2021-fault-cca-kem]], Hermelink 2021 [[raw/paper-hermelink2021-fault-cc-kyber]], Delvaux 2022 [[raw/paper-delvaux2022-roulette]] 等基于传播的故障攻击
- **与 NTT FI 防护对比**: Bauer 2024 [[raw/paper-bauer2024-fault-resistant-ntt]] 保护 NTT，本文保护解封装过程

## 关联
- FO 故障: [[raw/paper-pessl2021-fault-cca-kem]], [[raw/paper-hermelink2021-fault-cc-kyber]], [[raw/paper-delvaux2022-roulette]]
- NTT FI 防护: [[raw/paper-bauer2024-fault-resistant-ntt]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- Kyber 实体: [[entities/kyber-kem]]
- 故障概念: [[concepts/fault-injection]]
- 防护概念: [[concepts/masking-and-shuffling]]
