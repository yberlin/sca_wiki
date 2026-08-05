# CRYSTALS-Dilithium 签名方案

> **类型**: entity
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-may2023-too-many-hints]], [[raw/paper-cao2025-refined-attack]]

## 摘要

CRYSTALS-Dilithium（标准化名称 ML-DSA）是基于 Module-LWE 的后量子数字签名方案，由 NIST 于 2022 年选为标准化签名算法之一。与 Kyber 共享 Crystals 家族的数学基础，但用于签名而非密钥封装。

## 详情

### 数学基础
- **底层问题**: Module-LWE (与 Kyber 相同)
- **秘密密钥**: (s, e) 同时存储（Kyber 仅存 s）
- **签名计算**: 对加盐哈希 h 计算 ⟨h, s⟩ 和 ⟨h, e⟩
- **泄漏面**: s 和 e 的内积都可能泄漏

### 参数集

| 参数集 | 安全等级 | n | q | 密钥维度 |
|-------|---------|---|---|---------|
| Dilithium-512 | NIST L2 | 512 | 大 q | — |
| Dilithium-1024 | NIST L5 | 1024 | 大 q | — |

### 在侧信道研究中的位置
- Dilithium 存储 (s, e)，签名计算涉及两者的内积 → 泄漏面比 Kyber 更宽
- [[raw/paper-may2023-too-many-hints]]: Dilithium-1024 需 876 个 mod-q 提示（85%）或 463 个完美提示（45%），大 q 允许最大剩余维度 148
- [[raw/paper-cao2025-refined-attack]]: Dilithium-1024 too-many-hints 门槛 450（vs MN 463），44.9 min
- > ⚠️ 知识空白: 本文知识库中尚无专门针对 Dilithium 的 CC-SCA 分析论文（已有针对 Kyber 的 [[raw/paper-ravi2024-defeating-lcc]]）

### 与 Kyber 的对比
- Kyber (ML-KEM): 仅存 s, 解密计算 ⟨c, s⟩
- Dilithium (ML-DSA): 存 (s, e), 签名计算 ⟨h, s⟩ 和 ⟨h, e⟩
- Dilithium 的泄漏面更宽，但大 q 提供更好的抗 LLL 能力

## 关联
- 相关实体: [[entities/kyber-kem]]
- 相关概念: [[concepts/lwe-hints-framework]], [[concepts/lattice-reduction]]
- 参见: [[topics/sca-countermeasures-for-lattice-pqc]]

## 引用来源
- [1] [[raw/paper-may2023-too-many-hints]] — Dilithium 的提示需求量
- [2] [[raw/paper-cao2025-refined-attack]] — Dilithium 的改进攻击

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-may2023-too-many-hints]]
