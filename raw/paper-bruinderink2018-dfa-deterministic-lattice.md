# Differential Fault Attacks on Deterministic Lattice Signatures

> **作者**: Leon Groot Bruinderink, Peter Pessl
> **发表**: TCHES 2018(3), pp. 21-43
> **URL**: https://tches.iacr.org/index.php/TCHES/article/view/8787
> **类型**: Dilithium FI 奠基 — 首个格签名差分故障攻击

## 摘要

本文将差分故障攻击的适用性扩展到格密码。展示了两个确定性格签名方案 Dilithium 和 qTESLA 如何受到此类攻击。特别是，单随机故障可导致 nonce 重用场景，从而允许密钥恢复。还扩展到故障诱导的部分 nonce 重用攻击，这些攻击不会破坏签名有效性，因此更难检测。

## 核心贡献

### 1. 首个格签名差分故障攻击
- 将差分故障攻击从经典密码扩展到格签名
- 目标: Dilithium 和 qTESLA（确定性签名模式）
- 单随机故障 → nonce 重用 → 密钥恢复

### 2. 部分 nonce 重用攻击
- 故障诱导的部分 nonce 重用
- 签名仍然有效，更难检测
- 使用线性代数和格基约减提取密钥元素

### 3. 实验验证
- 时钟故障注入 on ARM Cortex-M4
- Dilithium 执行时间的 **65.2%** 易受无剖析攻击
- 随机故障在签名过程中任意位置注入仍可成功

### 4. 修改签名算法
- 部分密钥无法恢复，但修改后的签名算法仍可签名任意消息

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击类型 | 差分故障攻击 (DFA) |
| 目标 | 确定性 Dilithium, qTESLA |
| 故障模型 | 单随机故障 → nonce 重用 |
| 恢复方法 | 线性代数 + 格基约减 |
| 平台 | ARM Cortex-M4 |
| 故障方法 | 时钟故障 (clock glitching) |
| 易受攻击比例 | 65.2% 执行时间 |

## 历史意义

本文是**格签名故障注入攻击的奠基性工作**，首次证明了确定性格签名方案对故障攻击的脆弱性。直接导致 NIST 在 ML-DSA 标准中将随机化（hedged）模式设为默认。

## 与已有工作的关系

- **直接后果**: NIST 将 hedged 模式设为 ML-DSA 默认 → 后续 Krahmer 2024 [[raw/paper-krahmer2024-correction-fault-dilithium]] 和 Jendral 2024 [[raw/paper-jendral2024-hedged-dilithium-fi]] 攻击 hedged 模式
- **后续扩展**: ElGhamrawy 2023 [[raw/paper-elghamrawy2023-mlwe-to-rlwe]] 扩展到随机化 Dilithium
- **同一作者**: Pessl 也是 NTT SCA 奠基论文 [[raw/paper-primas2017-single-trace-lattice]] 和 FO 故障攻击 [[raw/paper-pessl2021-fault-cca-kem]] 的作者

## 关联
- 后续 hedged 攻击: [[raw/paper-krahmer2024-correction-fault-dilithium]], [[raw/paper-jendral2024-hedged-dilithium-fi]]
- 随机化扩展: [[raw/paper-elghamrawy2023-mlwe-to-rlwe]]
- FO 故障: [[raw/paper-pessl2021-fault-cca-kem]]
- Dilithium 实体: [[entities/dilithium]]
- 故障概念: [[concepts/fault-injection]]
- 格约减概念: [[concepts/lattice-reduction]]
