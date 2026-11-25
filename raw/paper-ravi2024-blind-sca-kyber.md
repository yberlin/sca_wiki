# Machine Learning based Blind Side-Channel Attacks on PQC-based KEMs — A Case Study of Kyber KEM

> **作者**: Prasanna Ravi, Dirmanto Jap, Shivam Bhasin, Anupam Chattopadhyay
> **发表**: ICCAD 2023 (IACR ePrint 2024/169)
> **URL**: https://eprint.iacr.org/2024/169
> **类型**: Kyber SCA — 盲侧信道攻击

## 摘要

Kyber KEM 的所有侧信道攻击要么需要知道密文，要么需要控制密文值。然而，在盲设置中没有已知攻击——攻击者无法获取密文。虽然对称密钥密码有盲侧信道攻击，但 Kyber KEM 尚无此类攻击。本文填补了这一空白，提出首个针对 Kyber KEM 的盲侧信道攻击。

## 核心贡献

### 1. 首个盲侧信道攻击
- 不需要知道或控制密文
- 攻击解密过程中的 pointwise multiplication 泄露
- 利用汉明权重（HW）分类器

### 2. 实际验证
- 目标: pqm4 库的 Kyber KEM 参考实现
- 平台: ARM Cortex-M4
- 仅需数百到数千条迹线即可完全密钥恢复

### 3. 实用性
- 在有足够准确的 HW 分类器前提下可行
- 扩展了 Kyber SCA 的攻击模型范围

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击类型 | 盲 SCA (无需密文知识) |
| 目标 | pointwise multiplication (解密) |
| 方法 | 机器学习 HW 分类器 |
| 迹线数 | 数百~数千 |
| 平台 | ARM Cortex-M4 (pqm4) |

## 与已有工作的关系

- **扩展攻击模型**: 从 KC-SCA/CC-SCA 扩展到盲 SCA
- **同一作者**: Ravi 团队的 NTT 故障注入 [[raw/paper-ravi2022-fiddling-twiddle-ntt]] 和综述 [[raw/paper-ravi2022-sca-fia-survey]]
- **攻击目标**: pointwise multiplication（与 Bock 2023 的 pair-pointwise multiplication 类似但不同）

## 关联
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- 攻击者实体: [[entities/ravi-research-group]]
- Kyber 实体: [[entities/kyber-kem]]
- pqm4 实体: [[entities/pqm4-library]]
- 分类概念: [[concepts/sca-classification-kc-vs-cc]]
