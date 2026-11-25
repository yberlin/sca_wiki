# 故障注入攻击

> **类型**: concept
> **创建时间**: 2026-08-06
> **最后更新**: 2026-11-24
> **来源**: 14 篇论文（见引用来源）

## 摘要

故障注入攻击（Fault Injection Attack, FIA）通过主动向密码设备注入故障（电压、时钟、电磁、激光等），使设备产生错误行为，从而泄露秘密信息。在格后量子密码中，故障注入已被成功应用于 NTT、FO 变换/重加密、Keccak/SHA-3、签名验证、随机数生成等多个组件，成为与被动侧信道攻击互补的重要攻击向量。

## 按攻击目标分类

### A. FO 变换/重加密攻击（Kyber KEM 专用）

这是格 KEM 故障攻击的**最大类别**，利用 FO 变换的重加密检查作为信息 oracle。

| 论文 | 年份 | 故障模型 | 关键特点 | 迹数 |
|------|------|----------|----------|------|
| [[raw/paper-pessl2021-fault-cca-kem]] | 2021 | 指令跳过（解码过程）| **奠基**: 首个格 KEM FI，有效/无效故障 → 不等式 | 6,500 |
| [[raw/paper-hermelink2021-fault-cc-kyber]] | 2021 | 比特翻转（重加密"纠正"）| **FI+CC 组合**: 密文操纵+故障纠正，突破洗牌+掩码 | — |
| [[raw/paper-delvaux2022-roulette]] | 2022 | set-to-0/随机/指令跳过 | **Roulette**: 掩码反而帮助攻击，容错 25%，ChipWhisperer | ≤20 |

**攻击链**: Pessl 2021 (奠基) → Hermelink 2021 (FI+CC 组合) → Delvaux 2022 (放宽模型 + 掩码反直觉)

### B. NTT 故障注入

| 论文 | 年份 | 故障模型 | 关键特点 |
|------|------|----------|----------|
| [[raw/paper-ravi2022-fiddling-twiddle-ntt]] | 2022 | EMFI (twiddle 常数) | **NTT FI 奠基**: 降低输出熵，Kyber+Dilithium |
| [[raw/paper-bauer2024-fault-resistant-ntt]] | 2024 | — (防护) | **NTT FI 防护**: 多项式求值+插值，72% 开销 |

### C. Keccak/SHA-3 故障

| 论文 | 年份 | 故障模型 | 关键特点 |
|------|------|----------|----------|
| [[raw/paper-wang2024-keccak-fault]] | 2024 | EMFI (循环中止) | **全阶段覆盖**: 6 策略→Kyber 8+Dilithium 7 攻击，89.5% 成功率 |

### D. 签名验证绕过（Dilithium + Falcon）

| 论文 | 年份 | 故障模型 | 关键特点 |
|------|------|----------|----------|
| [[raw/paper-bauer2025-forging-dilithium-falcon]] | 2023 | 单次故障 | **验证绕过**: 任意消息签名被验证通过 |

### E. 随机数生成攻击

| 论文 | 年份 | 故障模型 | 关键特点 |
|------|------|----------|----------|
| [[raw/paper-valsaraj2025-randomness-fault-pqc]] | 2025 | LFI (种子指针) | **种子指针**: 100% 成功率，影响 PQM4/LibOQS/PQClean/WolfSSL |

### F. 洗牌绕过（FI+SCA 组合）

| 论文 | 年份 | 故障模型 | 关键特点 |
|------|------|----------|----------|
| [[raw/paper-jendral2023-single-trace-masked-kyber]] | 2023 | VFI (绕过洗牌) | **FI+DL 组合**: VFI 绕过洗牌 → DL 恢复消息，成功率 0.887 |

## Dilithium 专用故障攻击分类

### G. 确定性签名差分故障攻击（奠基）

| 论文 | 年份 | 故障模型 | 关键特点 | 签名数 |
|------|------|----------|----------|--------|
| [[raw/paper-bruinderink2018-dfa-deterministic-lattice]] | 2018 | 随机故障 → nonce 重用 | **格签名 FI 奠基**: 65.2% 执行时间易受攻击 | — |

### H. 随机化/Hedged 模式攻击

| 论文 | 年份 | 故障模型 | 关键特点 | 签名数 |
|------|------|----------|----------|--------|
| [[raw/paper-elghamrawy2023-mlwe-to-rlwe]] | 2023 | 指令跳过 | **MLWE→RLWE 降维**: + LWE Hints 框架 | — |
| [[raw/paper-krahmer2024-correction-fault-dilithium]] | 2024 | 指令跳过/矩阵 A 故障 | **校正故障**: 两种攻击，512-1024 签名 | 512-1024 |
| [[raw/paper-jendral2024-hedged-dilithium-fi]] | 2024 | VFI (SHAKE256 种子) | **Hedged 单迹**: 58.2% 单迹成功率 | 1 |

**演进链**: Bruinderink 2018 (确定性 nonce 重用) → ElGhamrawy 2023 (随机化 MLWE→RLWE) → Krahmer 2024 (校正故障) + Jendral 2024 (hedged 单迹)

> ⚠️ **关键安全启示**: Bruinderink 2018 对确定性模式的攻击直接导致 NIST 在 ML-DSA 标准中将 hedged（随机化）模式设为默认。但后续论文证明 hedged 模式同样可被攻击。

## 故障注入方法总览

| 方法 | 论文 | 特点 | 成本 |
|------|------|------|------|
| 时钟故障 | Pessl 2021, Delvaux 2022, Bruinderink 2018 | 最常用，ChipWhisperer 可实现 | 低 |
| VFI (电压) | Hermelink 2021, Jendral 2023, Jendral 2024 | 低成本，绕过洗牌/种子 | 低 |
| EMFI (电磁) | Ravi 2022, Wang 2024 | 高精度，非侵入 | 中 |
| LFI (激光) | Valsaraj 2025 | 高精度，高成功率 | 高 |

## 故障防护措施

| 防护 | 论文 | 类型 | 开销 |
|------|------|------|------|
| NTT 多项式求值+插值 | [[raw/paper-bauer2024-fault-resistant-ntt]] | 检测 | 72% (Dilithium) |
| 概率化（拒绝采样）| [[raw/paper-mishra2024-probabilistic-fault-countermeasure]] | 预防 | 2-3 次重试 |
| FO 变换重加密检查 | Kyber 标准 | 检测 | 已内建（但可被绕过）|
| Hedged 模式 | ML-DSA 标准 | 预防 | 已内建（但可被攻击）|
| 定制防护 | [[raw/paper-ravi2022-sca-fia-survey]] | 综合 | 变化 |

## 与被动 SCA 的关系

- **互补**: FIA 可突破被动 SCA 难以攻破的防护（如洗牌）
- **组合**: FI+SCA 组合攻击（Jendral 2023 模式: VFI 绕过洗牌 → DL 恢复消息）
- **FI+CC 组合**: Hermelink 2021 模式: 密文操纵 + 故障纠正 → FO oracle
- **掩码反直觉**: Delvaux 2022 证明掩码在某些 FI 场景中反而帮助攻击
- **防护挑战**: 同时防护 SCA 和 FIA 需要定制化措施（Ravi 综述 [[raw/paper-ravi2022-sca-fia-survey]]）

## 攻击目标全景图

```
ML-KEM (Kyber)
├── FO 变换/重加密    ← Pessl 2021, Hermelink 2021, Delvaux 2022
├── NTT              ← Ravi 2022
├── Keccak/SHA-3     ← Wang 2024
├── 随机种子指针      ← Valsaraj 2025
└── 洗牌绕过          ← Jendral 2023 (FI+DL)

ML-DSA (Dilithium)
├── 确定性签名 nonce   ← Bruinderink 2018
├── 随机化签名         ← ElGhamrawy 2023 (MLWE→RLWE)
├── Hedged 签名        ← Jendral 2024 (SHAKE256 种子)
├── 校正故障           ← Krahmer 2024 (指令跳过 + 矩阵 A)
├── NTT               ← Ravi 2022
├── Keccak/SHA-3      ← Wang 2024
├── 签名验证           ← Bauer 2025
└── 随机种子指针        ← Valsaraj 2025

NTT 通用              ← Ravi 2022 (攻击), Bauer 2024 (防护)
```

## 关联
- NTT 故障: [[raw/paper-ravi2022-fiddling-twiddle-ntt]], [[raw/paper-bauer2024-fault-resistant-ntt]]
- FO 故障: [[raw/paper-pessl2021-fault-cca-kem]], [[raw/paper-hermelink2021-fault-cc-kyber]], [[raw/paper-delvaux2022-roulette]]
- Keccak 故障: [[raw/paper-wang2024-keccak-fault]]
- 洗牌绕过: [[raw/paper-jendral2023-single-trace-masked-kyber]]
- Dilithium DFA: [[raw/paper-bruinderink2018-dfa-deterministic-lattice]], [[raw/paper-elghamrawy2023-mlwe-to-rlwe]], [[raw/paper-krahmer2024-correction-fault-dilithium]], [[raw/paper-jendral2024-hedged-dilithium-fi]]
- 验证绕过: [[raw/paper-bauer2025-forging-dilithium-falcon]]
- 种子指针: [[raw/paper-valsaraj2025-randomness-fault-pqc]]
- 防护: [[raw/paper-bauer2024-fault-resistant-ntt]], [[raw/paper-mishra2024-probabilistic-fault-countermeasure]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- NTT SCA 概念: [[concepts/ntt-side-channel-attacks]]
- 防护概念: [[concepts/masking-and-shuffling]]
- 贪心求解器: [[concepts/greedy-solver]] (不等式求解)
- LWE Hints: [[concepts/lwe-hints-framework]] (ElGhamrawy 2023 使用)
- 格约减: [[concepts/lattice-reduction]] (多个 FI 攻击的后处理)
- Kyber 实体: [[entities/kyber-kem]]
- Dilithium 实体: [[entities/dilithium]]

## 引用来源
- [1] [[raw/paper-bruinderink2018-dfa-deterministic-lattice]] — 格签名 DFA 奠基 (TCHES 2018)
- [2] [[raw/paper-pessl2021-fault-cca-kem]] — 格 KEM FI 奠基 (TCHES 2021)
- [3] [[raw/paper-hermelink2021-fault-cc-kyber]] — FI+CC 组合攻击 (INDOCRYPT 2021)
- [4] [[raw/paper-delvaux2022-roulette]] — Roulette 多样化故障 (TCHES 2022)
- [5] [[raw/paper-ravi2022-fiddling-twiddle-ntt]] — NTT twiddle FI (2022)
- [6] [[raw/paper-jendral2023-single-trace-masked-kyber]] — VFI+DL 组合 (HOST 2024)
- [7] [[raw/paper-elghamrawy2023-mlwe-to-rlwe]] — MLWE→RLWE 降维 (TCHES 2023)
- [8] [[raw/paper-wang2024-keccak-fault]] — Keccak 循环中止 (2024)
- [9] [[raw/paper-bauer2024-fault-resistant-ntt]] — NTT FI 防护 (TCHES 2024)
- [10] [[raw/paper-krahmer2024-correction-fault-dilithium]] — 校正故障 (TCHES 2024)
- [11] [[raw/paper-jendral2024-hedged-dilithium-fi]] — Hedged 单迹 (FDTC 2024)
- [12] [[raw/paper-mishra2024-probabilistic-fault-countermeasure]] — 概率化防护 (2024)
- [13] [[raw/paper-bauer2025-forging-dilithium-falcon]] — 验证绕过 (FDTC 2023)
- [14] [[raw/paper-valsaraj2025-randomness-fault-pqc]] — 种子指针攻击 (2025)
- [15] [[raw/paper-ravi2022-sca-fia-survey]] — SCA/FIA 综述

## 变更记录
- 2026-08-06: 初始创建，涵盖 NTT/洗牌/Keccak 故障注入分类（3 篇论文）
- 2026-11-24: **大幅重构**——系统性搜索 11 篇新论文后，按攻击目标重新分类为 8 大类（FO 变换/NTT/Keccak/验证绕过/随机数/洗牌/确定性 DFA/Hedged），新增攻击目标全景图、故障防护措施表、演进链分析
