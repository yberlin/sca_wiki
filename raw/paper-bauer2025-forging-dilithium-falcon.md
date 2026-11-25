# Forging Dilithium and Falcon Signatures by Single Fault Injection

> **作者**: Sven Bauer, Fabrizio De Santis
> **发表**: FDTC 2023 (IACR ePrint 2025/2029)
> **URL**: https://eprint.iacr.org/2025/2029
> **类型**: Dilithium/Falcon FI — 验证绕过攻击

## 摘要

嵌入式设备依赖数字签名确保完整性和认证。故障注入可用于篡改设备，在密码计算期间引起故障。本文介绍了针对 Dilithium 和 Falcon 签名方案验证例程的新型故障注入攻击，允许攻击者通过故障注入使任意消息的签名被接受。在 ARM Cortex-M4 上使用 pqm4 库进行仿真验证，并精确定位易受攻击的指令。

## 核心贡献

### 1. 验证绕过攻击
- 目标: 签名验证例程（而非签名生成）
- 单次故障注入 → 任意消息的伪造签名被验证通过
- 对嵌入式设备安全造成灾难性后果

### 2. 新型非平凡攻击
- "非显而易见"的攻击路径
- 针对验证例程的具体指令
- 精确定位易受攻击的指令

### 3. Dilithium 和 Falcon 双目标
- 同时攻击两个 NIST 标准化的格签名方案
- 通用性更强

### 4. 防护建议
- 提出并讨论可能的防护措施

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击目标 | 签名验证例程 |
| 攻击效果 | 任意消息的伪造签名被接受 |
| 故障次数 | 单次 |
| 目标方案 | Dilithium (ML-DSA), Falcon |
| 验证方法 | 仿真 (ARM Cortex-M4 + pqm4) |
| 会议 | FDTC 2023 |

## 与已有工作的关系

- **同一作者**: Bauer & De Santis 也是 NTT 故障防护 [[raw/paper-bauer2024-fault-resistant-ntt]] 的作者
- **验证绕过**: Ravi 2022 [[raw/paper-ravi2022-fiddling-twiddle-ntt]] 也展示了 Dilithium 验证绕过，但目标不同（NTT vs 验证例程）
- **Keccak FI**: Wang 2024 [[raw/paper-wang2024-keccak-fault]] 也包含 Dilithium 验证绕过策略

## 关联
- NTT FI 防护: [[raw/paper-bauer2024-fault-resistant-ntt]]
- NTT FI 攻击: [[raw/paper-ravi2022-fiddling-twiddle-ntt]]
- Keccak FI: [[raw/paper-wang2024-keccak-fault]]
- Dilithium 实体: [[entities/dilithium]]
- 故障概念: [[concepts/fault-injection]]
