# NTT 侧信道攻击

> **类型**: concept
> **创建时间**: 2026-08-06
> **最后更新**: 2026-08-06
> **来源**: [[raw/paper-primas2017-single-trace-lattice]], [[raw/paper-pessl2019-practical-ntt]], [[raw/paper-hermelink2022-bp-shuffling-ntt]], [[raw/paper-bock2023-breaking-dpa-kyber]], [[raw/paper-qiao2023-ntt-meets-sis]]

## 摘要

数论变换（NTT）是几乎所有高效格密码实现的核心计算组件，用于多项式乘法。由于其结构特点和在实现中的核心地位，NTT 已成为格密码侧信道攻击的**最主要攻击面**。从 2017 年 Primas 的奠基性工作到 2025 年的最新攻击，NTT 攻击经历了从变时间到常时间、从多变量到单变量模板、从纯被动到主动故障注入的演进。

## 攻击演进时间线

| 年份 | 论文 | 关键进展 |
|------|------|----------|
| 2017 | [[raw/paper-primas2017-single-trace-lattice]] | 首个 NTT 单迹攻击（变时间，~10^6 多变量模板）|
| 2019 | [[raw/paper-pessl2019-practical-ntt]] | 实用化（常时间，213 单变量模板，改 BP）|
| 2021 | Hamburg 2021 | 选择密文 SCA，稀疏多项式，k 条迹 |
| 2022 | [[raw/paper-hermelink2022-bp-shuffling-ntt]] | 突破洗牌防护（shuffle node + BP）|
| 2022 | [[raw/paper-ravi2022-fiddling-twiddle-ntt]] | NTT 故障注入（twiddle 常数 EMFI）|
| 2023 | [[raw/paper-bock2023-breaking-dpa-kyber]] | 不完整 NTT 弱点（pair-pointwise mult）|
| 2023 | [[raw/paper-qiao2023-ntt-meets-sis]] | SIS 辅助恢复（仅需 32-64 系数）|
| 2024 | [[raw/paper-ravi2024-blind-sca-kyber]] | 盲 SCA（不需密文知识）|

## 攻击分类

### 被动侧信道（SCA）
1. **模板攻击 + BP**: Primas 2017 → Pessl 2019 → Hermelink 2022 演进线
2. **CPA 攻击**: 直接 CPA 恢复 NTT 域系数 → Qiao 2023 的 SIS 辅助
3. **盲 SCA**: Ravi 2024 无需密文知识的 pointwise multiplication 泄露
4. **模板攻击（不使用 ML）**: Bock 2023 的相关匹配方法

### 主动故障注入（FI）
1. **Twiddle 常数故障**: Ravi 2022 的 EMFI 攻击
2. **洗牌绕过**: Jendral 2023 的电压故障绕过洗牌

## 关键弱点分析

### 1. 不完整 NTT 弱点
Kyber-768 使用**不完整 NTT**，导致每个秘密系数在 pair-pointwise multiplication 中被多次使用，引入额外侧信道弱点（Bock 2023）。

### 2. 洗牌防护不足
虽然 Fisher-Yates 洗牌旨在破坏时间相关性，但：
- BP 的 shuffle node 可迭代学习置换（Hermelink 2022）
- 故障注入可绕过洗牌（Jendral 2023）
- 统计特征仍泄露（Zhang 2025）

### 3. 系数子集即可恢复
Qiao 2023 证明仅需要 32-64 个（共 256 个）NTT 域系数即可通过 SIS 问题恢复完整私钥。

## 关联
- 基础工作: [[raw/paper-primas2017-single-trace-lattice]], [[raw/paper-pessl2019-practical-ntt]]
- 洗牌突破: [[raw/paper-hermelink2022-bp-shuffling-ntt]], [[raw/paper-zhang2025-cc-sca-shuffled-kyber]]
- 故障注入: [[raw/paper-ravi2022-fiddling-twiddle-ntt]]
- SIS 辅助: [[raw/paper-qiao2023-ntt-meets-sis]]
- 盲攻击: [[raw/paper-ravi2024-blind-sca-kyber]]
- Kyber 实体: [[entities/kyber-kem]]
- 相关概念: [[concepts/sca-classification-kc-vs-cc]], [[concepts/greedy-solver]], [[concepts/masking-and-shuffling]], [[concepts/fault-injection]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- 防护综述: [[topics/sca-countermeasures-for-lattice-pqc]]

## 引用来源
- [1] [[raw/paper-primas2017-single-trace-lattice]] — 首个 NTT 单迹攻击
- [2] [[raw/paper-pessl2019-practical-ntt]] — 实用化改进
- [3] [[raw/paper-hermelink2022-bp-shuffling-ntt]] — 突破洗牌
- [4] [[raw/paper-bock2023-breaking-dpa-kyber]] — 不完整 NTT 弱点
- [5] [[raw/paper-qiao2023-ntt-meets-sis]] — SIS 辅助恢复
- [6] [[raw/paper-ravi2024-blind-sca-kyber]] — 盲 SCA
- [7] [[raw/paper-ravi2022-sca-fia-survey]] — 综述

## 变更记录
- 2026-08-06: 初始创建，涵盖 NTT SCA 演进时间线、攻击分类、弱点分析
