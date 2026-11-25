# A Single Trace Fault Injection Attack on Hedged CRYSTALS-Dilithium

> **作者**: Sönke Jendral
> **发表**: FDTC 2024 (IACR ePrint 2024/238)
> **URL**: https://eprint.iacr.org/2024/238
> **类型**: Dilithium FI — Hedged 模式单迹攻击

## 摘要

本文展示了针对 hedged 模式 CRYSTALS-Dilithium 实现的故障注入攻击。通过电压故障跳过签名生成过程中种子计算的一个步骤。成功故障注入后，生成的签名允许直接提取私钥向量。攻击在单迹中以 0.582 的概率成功。

## 核心贡献

### 1. 首个 Hedged 模式单迹故障攻击
- 之前故障攻击仅适用于确定性 Dilithium
- 本文首次攻击 NIST 默认的 hedged 模式
- 仅需单条故障签名即可恢复私钥

### 2. 电压故障注入
- Crowbar 技术电压故障
- 跳过 SHAKE256 海绵中输入数据的吸收
- 固定种子为已知常数值
- 一致地跳过目标函数而不崩溃设备

### 3. 直接密钥提取
- 故障后种子为已知值
- 从故障签名直接推导 s1
- 恢复 s1 即足以实现存在性签名伪造

### 4. 防护措施
- 提出针对此攻击的防护措施

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击目标 | Hedged Dilithium (ML-DSA 默认模式) |
| 故障类型 | 电压故障 (crowbar) |
| 故障目标 | SHAKE256 种子计算 |
| 恢复目标 | s1 (私钥向量) |
| 单迹成功率 | 58.2% |
| 平台 | ARM Cortex-M4 |
| 会议 | FDTC 2024 |

## 与已有工作的关系

- **同一作者**: Jendral 也是掩码+洗牌 Kyber 攻击 [[raw/paper-jendral2023-single-trace-masked-kyber]] 的作者
- **DFA 前身**: Bruinderink 2018 [[raw/paper-bruinderink2018-dfa-deterministic-lattice]] 仅攻击确定性模式
- **Correction FA**: Krahmer 2024 [[raw/paper-krahmer2024-correction-fault-dilithium]] 同期攻击 hedged 模式（不同方法）
- **MLWE→RLWE**: ElGhamrawy 2023 [[raw/paper-elghamrawy2023-mlwe-to-rlwe]] 也攻击随机化 Dilithium

## 关联
- 同作者: [[raw/paper-jendral2023-single-trace-masked-kyber]]
- DFA 前身: [[raw/paper-bruinderink2018-dfa-deterministic-lattice]]
- Correction FA: [[raw/paper-krahmer2024-correction-fault-dilithium]]
- MLWE→RLWE: [[raw/paper-elghamrawy2023-mlwe-to-rlwe]]
- Dilithium 实体: [[entities/dilithium]]
- 故障概念: [[concepts/fault-injection]]
