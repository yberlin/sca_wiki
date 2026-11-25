# When NTT Meets SIS: Efficient Side-channel Attacks on Dilithium and Kyber

> **作者**: Zehua Qiao, Yuejun Liu, Yongbin Zhou, Mingyao Shao, Shuo Sun
> **发表**: IACR ePrint 2023/1866 (预印本)
> **URL**: https://eprint.iacr.org/2023/1866
> **类型**: NTT SCA — SIS 辅助密钥恢复

## 摘要

NTT 是格后量子密码的核心组件，已成为侧信道攻击的主要目标。CPA 攻击 NTT 旨在恢复 NTT 域中的所有私钥系数。但恢复所有系数的要求限制了效率。关键问题：能否仅用已知系数子集恢复剩余系数？本文通过引入基于超定方程组和 SIS 辅助的密钥恢复方法，给出了肯定回答。

## 核心贡献

### 1. SIS 辅助密钥恢复
- 将 NTT 变换矩阵嵌入 SIS 搜索问题
- 以最少已知系数实现完整密钥恢复
- Kyber512: 仅需 **64 个系数**（共 256 个）
- Dilithium2: 仅需 **32 个系数**

### 2. 参数可调 CPA 方案
- 加速 NTT 域单系数恢复
- 可调参数适应不同场景

### 3. 实际攻击验证
- **Dilithium2**: 2000 条功率迹，0.5 分钟恢复 256 系数子集
- **Kyber512**: 500 条功率迹，0.4 分钟
- 比已知最佳攻击快 **400×**

### 4. 突破掩码
- 成功突破一阶掩码实现
- 探索对高阶掩码的适用性

## 关键技术细节

| 维度 | Kyber512 | Dilithium2 |
|------|----------|------------|
| 所需系数 | 64/256 | 32/256 |
| 迹数 | 500 | 2000 |
| 时间 | 0.4 min | 0.5 min |
| 加速比 | — | 400× vs 最佳已知 |

- **核心方法**: SIS (Short Integer Solution) 辅助恢复
- **攻击平台**: ARM Cortex-M4 (pqm4)
- **CPA 改进**: 参数可调的 CPA

## 与已有工作的关系

- **效率提升**: CPA 不再需要恢复所有 NTT 域系数
- **SIS 桥接**: 首次将 SIS 问题用于侧信道密钥恢复的桥接
- **掩码突破**: 一阶掩码可被突破

## 关联
- NTT 攻击基础: [[raw/paper-primas2017-single-trace-lattice]], [[raw/paper-pessl2019-practical-ntt]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- 格约减概念: [[concepts/lattice-reduction]]
- Kyber 实体: [[entities/kyber-kem]]
- Dilithium 实体: [[entities/dilithium]]
- 防护概念: [[concepts/masking-and-shuffling]]
