# From MLWE to RLWE: A Differential Fault Attack on Randomized & Deterministic Dilithium

> **作者**: Mohamed ElGhamrawy, Melissa Azouaoui, Olivier Bronchain, Joost Renes, Tobias Schneider, Markus Schönauer, Okan Seker, Christine van Vredendaal
> **发表**: TCHES 2023(4), pp. 262-286 (IACR ePrint 2023/1074)
> **URL**: https://eprint.iacr.org/2023/1074
> **类型**: Dilithium FI — MLWE→RLWE 降维攻击

## 摘要

本文描述了针对随机化和确定性版本 CRYSTALS-Dilithium 的差分故障攻击。攻击仅需少量指令跳过，即可将 Dilithium 基于的 MLWE 问题归约为更小的 RLWE 问题，后者可用格约减技术实际求解。使用 DDGR CRYPTO 2020 的 LWE with side-information 框架从故障签名中提取 hints 实现密钥恢复。

## 核心贡献

### 1. MLWE → RLWE 降维
- 少量指令跳过故障 → 将 MLWE 降为 RLWE
- RLWE 问题更小，可用格约减实际求解
- 创新的攻击思路：不是直接恢复密钥，而是降低问题难度

### 2. 随机化和确定性版本均适用
- 适用于 Dilithium 的随机化签名模式
- 适用于确定性签名模式
- 覆盖 NIST 标准的所有模式

### 3. LWE with Hints 框架集成
- 使用 DDGR CRYPTO 2020 [[raw/paper-ddgr2020-lwe-side-info]] 的 LWE with side-information 框架
- 从故障签名中提取 hints
- 格约减恢复密钥

### 4. 算法级防护
- 提出算法级防护措施
- 第二种防护可参数化，仅引入可忽略的签名生成开销

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击类型 | 差分故障攻击 (DFA) |
| 目标 | 随机化 + 确定性 Dilithium |
| 故障模型 | 指令跳过 (少量) |
| 降维 | MLWE → RLWE |
| 恢复方法 | LWE with Hints + 格约减 |
| 防护 | 算法级，可忽略开销 |

## 与已有工作的关系

- **DFA 前身**: Bruinderink & Pessl 2018 [[raw/paper-bruinderink2018-dfa-deterministic-lattice]] — 从确定性扩展到随机化
- **LWE Hints 框架**: DDGR CRYPTO 2020 [[raw/paper-ddgr2020-lwe-side-info]] — 使用其框架提取 hints
- **后续 Correction FA**: Krahmer 2024 [[raw/paper-krahmer2024-correction-fault-dilithium]] — 不同的故障策略

## 关联
- DFA 前身: [[raw/paper-bruinderink2018-dfa-deterministic-lattice]]
- LWE Hints 框架: [[raw/paper-ddgr2020-lwe-side-info]], [[concepts/lwe-hints-framework]]
- 后续: [[raw/paper-krahmer2024-correction-fault-dilithium]]
- Dilithium 实体: [[entities/dilithium]]
- 故障概念: [[concepts/fault-injection]]
- 格约减概念: [[concepts/lattice-reduction]]
