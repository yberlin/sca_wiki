# Single-Trace Side-Channel Attacks on CRYSTALS-Dilithium: Myth or Reality?

> **作者**: Ruize Wang, Kalle Ngo, Joel Gärtner, Elena Dubrova
> **发表**: IACR ePrint 2023/1931 (预印本)
> **URL**: https://eprint.iacr.org/2023/1931
> **类型**: Dilithium SCA — 深度学习单迹攻击

## 摘要

本文提出了一种针对 CRYSTALS-Dilithium 的侧信道攻击，具有两种后处理变体。攻击利用签名算法的密钥解包过程中的信息泄露，通过基于深度学习辅助的功率分析恢复私钥向量 s1 和 s2 的多项式系数。

## 核心贡献

### 1. 深度学习辅助功率分析
- 利用密钥解包过程的信息泄露
- 基于深度学习的模板功率分析
- 恢复 s1 和 s2 的系数

### 2. 两种后处理变体
- **变体 1**: 已知 t0（公钥最低有效位），恢复一半系数 + 线性方程组求解
- **变体 2**: 不需 t0，恢复更多 s1 系数 + 格约减

### 3. 实验验证
- 平台: ARM Cortex-M4 上的 Dilithium-2
- 分析阶段（迹线捕获+训练）< 10 小时
- 变体 1: 单迹成功率 9%（跨设备），多迹接近 100%

### 4. 安全启示
- 证明 Dilithium 需要防护密钥免受单迹攻击
- 呼吁重新评估公钥压缩在 Dilithium 实现安全中的作用

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 目标 | 密钥解包 (secret key unpacking) |
| 方法 | 深度学习辅助模板分析 |
| 恢复目标 | s1, s2 系数 |
| 变体 1 | 已知 t0 → 线性方程组 |
| 变体 2 | 不需 t0 → 格约减 |
| 平台 | Cortex-M4 (Dilithium-2) |
| 单迹成功率 | 9% (变体 1) |
| 多迹成功率 | ~100% |

## 与已有工作的关系

- **后续改进**: Wang 2024 "Single Trace is All It Takes" 改进至 60% 单迹成功率 [[raw/paper-wang2024-single-trace-dilithium]]
- **Dilithium SCA 系列**: 与 Primas/Pessl 的 Kyber NTT 攻击平行的 Dilithium 攻击
- **格约减后处理**: 变体 2 使用格约减恢复剩余 s1

## 关联
- 后续改进: [[raw/paper-wang2024-single-trace-dilithium]]
- 格约减概念: [[concepts/lattice-reduction]]
- Dilithium 实体: [[entities/dilithium]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- NTT 攻击类比: [[raw/paper-primas2017-single-trace-lattice]]
