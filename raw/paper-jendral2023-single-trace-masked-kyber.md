# A Single-Trace Message Recovery Attack on a Masked and Shuffled Implementation of CRYSTALS-Kyber

> **作者**: Sönke Jendral, Kalle Ngo, Ruize Wang, Elena Dubrova
> **发表**: IEEE HOST 2024 (IACR ePrint 2023/1587)
> **URL**: https://eprint.iacr.org/2023/1587
> **类型**: Kyber SCA — 故障+侧信道组合攻击

## 摘要

本文提出了一种针对掩码和洗牌 Kyber 软件实现的攻击，结合故障注入和侧信道分析。首先通过电压故障注入绕过洗牌。在成功故障注入后，使用基于深度学习的辅助功率分析（汉明权重泄露模型）恢复消息（共享密钥）。提出部分密钥枚举方法，显著提高消息恢复成功率（从 0.122 提升到 0.887，枚举 32 位）。

## 核心贡献

### 1. 故障注入绕过洗牌
- 电压故障注入绕过 Fisher-Yates 洗牌
- 找到一致的故障设置，不崩溃设备
- 证明洗牌防护可被主动故障攻击绕过

### 2. 深度学习辅助侧信道分析
- 基于汉明权重泄露模型
- 深度学习辅助的模板功率分析
- 从单迹恢复消息（共享密钥）

### 3. 部分密钥枚举
- 枚举 32 位将成功率从 0.122 提升到 0.887
- 实用的枚举策略

### 4. 组合攻击范式
- **故障注入 + 侧信道分析** 的组合攻击
- 首次针对掩码+洗牌双重防护的 Kyber 实现

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击目标 | 掩码+洗牌 Kyber |
| 故障类型 | 电压故障注入 (VFI) |
| 故障目标 | Fisher-Yates 洗牌绕过 |
| SCA 方法 | 深度学习辅助模板分析 |
| 泄露模型 | 汉明权重 (HW) |
| 恢复目标 | 消息/共享密钥 |
| 枚举 | 32 位 |
| 成功率 | 0.887 (枚举后) |

## 与已有工作的关系

- **组合攻击**: 结合了 Ravi 2022 NTT 故障注入 [[raw/paper-ravi2022-fiddling-twiddle-ntt]] 和 Pessl 2019 NTT SCA [[raw/paper-pessl2019-practical-ntt]] 的思路
- **突破洗牌**: Hermelink 2022 从 BP 角度突破洗牌 [[raw/paper-hermelink2022-bp-shuffling-ntt]]，本文从故障角度突破
- **后续攻击**: Zhang 2025 从 CC-SCA 角度攻击洗牌实现 [[raw/paper-zhang2025-cc-sca-shuffled-kyber]]

## 关联
- 故障注入: [[raw/paper-ravi2022-fiddling-twiddle-ntt]]
- NTT SCA: [[raw/paper-pessl2019-practical-ntt]]
- 洗牌突破: [[raw/paper-hermelink2022-bp-shuffling-ntt]]
- 后续: [[raw/paper-zhang2025-cc-sca-shuffled-kyber]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- 防护概念: [[concepts/masking-and-shuffling]]
- Kyber 实体: [[entities/kyber-kem]]
