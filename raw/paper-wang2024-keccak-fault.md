# Beware of Keccak: Practical Fault Attacks on SHA-3 to Compromise Kyber and Dilithium on ARM Cortex-M Devices

> **作者**: Yuxuan Wang, Jintong Yu, Shipei Qu, Xiaolin Zhang, Xiaowei Li, Chi Zhang, Dawu Gu
> **发表**: IACR ePrint 2024/1522 (预印本)
> **URL**: https://eprint.iacr.org/2024/1522
> **类型**: 故障注入 — SHA-3/Keccak 故障攻击

## 摘要

Keccak 在 Kyber 和 Dilithium 中充当哈希算法和 XOF。Keccak 输出与敏感信息高度相关。在 RSA 和 ECDSA 中，哈希组件只用于处理公开信息（如消息）。但在 Kyber 和 Dilith 中，Keccak 的重要性远高于传统公钥密码。然而，很少有工作研究 Keccak 在 Kyber 和 Dilithium 物理安全中的作用。

## 核心贡献

### 1. Keccak 循环中止故障
- 在 Keccak 的迭代赋值/更新中注入循环中止故障
- 将 Keccak 输出设为已知值
- 6 种攻击策略

### 2. Kyber 攻击策略 (8 种)
- 利用 Keccak 输出已知性
- 破坏随机数扩展或关键过程
- 实现密钥恢复、签名伪造、验证绕过

### 3. Dilithium 攻击策略 (7 种)
- 密钥恢复
- 签名伪造
- 验证绕过

### 4. 多平台验证
- 5 种设备: ARM Cortex-M0+, M3, M4, M33 (4 个系列)
- 故障成功率高达 89.5%
- 电磁故障注入验证
- 官方实现攻击成功率达 55.1%

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 目标 | SHA-3/Keccak |
| 故障类型 | 循环中止 (loop-abort) |
| 注入方法 | 电磁故障注入 (EMFI) |
| 平台 | Cortex-M0+, M3, M4, M33 |
| 故障成功率 | 89.5% |
| Kyber 策略 | 8 种 |
| Dilithium 策略 | 7 种 |
| 攻击成功率 | 55.1% |

## 与已有工作的关系

- **新攻击面**: 之前 NTT 故障攻击 [[raw/paper-ravi2022-fiddling-twiddle-ntt]] 针对 NTT，本文针对 Keccak
- **通用性**: 可迁移到其他使用 Keccak 的 PQC 算法（Falcon, BIKE, HQC）
- **安全启示**: Keccak 在 PQC 中过度用于生成和计算秘密信息导致严重漏洞

## 关联
- NTT 故障攻击: [[raw/paper-ravi2022-fiddling-twiddle-ntt]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- Kyber 实体: [[entities/kyber-kem]]
- Dilithium 实体: [[entities/dilithium]]
- 故障概念: [[concepts/fault-injection]]
