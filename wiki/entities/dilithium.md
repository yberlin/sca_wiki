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
- > ⚠️ 知识空白（已填补）: 以下论文填补了 Dilithium SCA 的空白

### 与 Kyber 的对比
- Kyber (ML-KEM): 仅存 s, 解密计算 ⟨c, s⟩
- Dilithium (ML-DSA): 存 (s, e), 签名计算 ⟨h, s⟩ 和 ⟨h, e⟩
- Dilithium 的泄漏面更宽，但大 q 提供更好的抗 LLL 能力

### Dilithium 侧信道攻击面
- **单迹 DL 攻击** [[raw/paper-wang2023-single-trace-dilithium]]: 密钥解包泄露，深度学习辅助功率分析，9% 单迹成功率
- **高效单迹攻击** [[raw/paper-wang2024-single-trace-dilithium]]: CNN 模板 + 线性回归，60% 单迹成功率，5 分钟
- **NTT+SIS 攻击** [[raw/paper-qiao2023-ntt-meets-sis]]: Dilithium2 仅需 32 系数，2000 迹，0.5 分钟，快 400×
- **掩码 ML-DSA 攻击** [[raw/paper-hermelink2025-masked-mldsa-attack]]: 分析掩码 ML-DSA 的最薄弱环节 y，CRYPTO 2025

### Dilithium 防护措施
- **高阶掩码 gadgets** [[raw/paper-coron2023-masked-dilithium-gadgets]]: ShiftMod + 布尔到算术转换，TCHES 2023
- **硬件一阶掩码** [[raw/paper-raj2024-mldsa-hardware-masking]]: 首个 ML-DSA 受保护硬件，100 万迹验证

### Dilithium 故障注入
- **NTT twiddle 故障** [[raw/paper-ravi2022-fiddling-twiddle-ntt]]: 签名伪造 + 验证绕过
- **Keccak 故障** [[raw/paper-wang2024-keccak-fault]]: 7 种策略（签名伪造、验证绕过）

### Dilithium 专用故障注入攻击（扩展）
- **确定性 DFA 奠基** [[raw/paper-bruinderink2018-dfa-deterministic-lattice]]: nonce 重用，65.2% 执行时间易受攻击 (TCHES 2018)
- **MLWE→RLWE 降维** [[raw/paper-elghamrawy2023-mlwe-to-rlwe]]: 指令跳过 → MLWE 降为 RLWE + LWE Hints 框架 (TCHES 2023)
- **校正故障** [[raw/paper-krahmer2024-correction-fault-dilithium]]: 两种攻击（指令跳过 + 矩阵 A 故障），512-1024 签名 (TCHES 2024)
- **Hedged 单迹** [[raw/paper-jendral2024-hedged-dilithium-fi]]: VFI 跳过 SHAKE256 种子，58.2% 单迹成功率 (FDTC 2024)
- **验证绕过** [[raw/paper-bauer2025-forging-dilithium-falcon]]: 单次故障使任意消息签名被验证通过 (FDTC 2023)
- **种子指针** [[raw/paper-valsaraj2025-randomness-fault-pqc]]: LFI 破坏种子指针，签名伪造 100% 成功率 (2025)

## 关联
- 相关实体: [[entities/kyber-kem]]
- 相关概念: [[concepts/lwe-hints-framework]], [[concepts/lattice-reduction]], [[concepts/ntt-side-channel-attacks]], [[concepts/fault-injection]], [[concepts/deep-learning-sca]]
- 参见: [[topics/sca-countermeasures-for-lattice-pqc]]

## 引用来源
- [1] [[raw/paper-may2023-too-many-hints]] — Dilithium 的提示需求量
- [2] [[raw/paper-cao2025-refined-attack]] — Dilithium 的改进攻击
- [3] [[raw/paper-wang2023-single-trace-dilithium]] — 首个 Dilithium 单迹 DL 攻击
- [4] [[raw/paper-wang2024-single-trace-dilithium]] — 高效单迹攻击（CNN + 线性回归）
- [5] [[raw/paper-qiao2023-ntt-meets-sis]] — SIS 辅助 Dilithium 密钥恢复
- [6] [[raw/paper-hermelink2025-masked-mldsa-attack]] — 掩码 ML-DSA 最薄弱环节攻击 (CRYPTO 2025)
- [7] [[raw/paper-coron2023-masked-dilithium-gadgets]] — 高阶掩码 gadgets (TCHES 2023)
- [8] [[raw/paper-raj2024-mldsa-hardware-masking]] — 硬件一阶掩码实现
- [9] [[raw/paper-ravi2022-fiddling-twiddle-ntt]] — NTT 故障注入
- [10] [[raw/paper-wang2024-keccak-fault]] — Keccak 故障攻击
- [11] [[raw/paper-ravi2022-sca-fia-survey]] — SCA/FIA 综述
- [12] [[raw/paper-bruinderink2018-dfa-deterministic-lattice]] — 格签名 DFA 奠基 (TCHES 2018)
- [13] [[raw/paper-elghamrawy2023-mlwe-to-rlwe]] — MLWE→RLWE 降维 (TCHES 2023)
- [14] [[raw/paper-krahmer2024-correction-fault-dilithium]] — 校正故障 (TCHES 2024)
- [15] [[raw/paper-jendral2024-hedged-dilithium-fi]] — Hedged 单迹 FI (FDTC 2024)
- [16] [[raw/paper-bauer2025-forging-dilithium-falcon]] — 验证绕过 (FDTC 2023)
- [17] [[raw/paper-valsaraj2025-randomness-fault-pqc]] — 种子指针 LFI (2025)

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-may2023-too-many-hints]]
- 2026-08-06: 大幅更新——添加 Dilithium SCA/FIA 攻击面（单迹攻击、NTT+SIS、掩码攻击）、防护措施（高阶掩码 gadgets、硬件掩码）、故障注入，共 8 篇新引用
- 2026-11-24: 大幅更新——添加 6 篇 Dilithium 专用故障注入论文（DFA 奠基、MLWE→RLWE、校正故障、Hedged 单迹、验证绕过、种子指针），Dilithium FI 攻击面从 2 篇扩展到 8 篇
