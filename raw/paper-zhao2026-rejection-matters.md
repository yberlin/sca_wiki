# Rejection Matters: Efficient Non-Profiling Side-Channel Attack on ML-DSA via Exploiting Public Templates

> **作者**: Yuhan Zhao, Wei Cheng, Zehua Qiao, Yuejun Liu, Yongbin Zhou
> **发表**: IACR ePrint 2026/056 (2026)
> **URL**: https://eprint.iacr.org/2026/056
> **类型**: ML-DSA SCA — 拒绝采样泄漏 + 公开模板非剖析攻击

## 摘要

本文揭示 ML-DSA 一个此前被忽视的攻击面：**拒绝签名尝试（rejected signing trials）与最终接受尝试（accepted trial）的泄漏可以同时利用**，且构建泄漏模板无需克隆设备——PTA（Public-based Template Attack）仅用目标设备上公开可用的数据（公钥、已发布签名、公开挑战 c）即可构建。在已知挑战 c 下，对敏感中间量执行 CPA，使 ML-DSA-44 每次签名请求的可利用泄漏平均增加 4 倍。ARM Cortex-M4 实测：仅 96 条迹完全恢复挑战 c，约 300 条迹完成密钥恢复——比先前工作少 10 倍。攻击适用于全部三个 ML-DSA 变体，且**直接适用于 hedged（非确定性）模式，证明 hedging 在此场景下不提供 SCA 防护**。

## 核心贡献

### 1. 新攻击面：拒绝采样泄漏
- Dilithium/ML-DSA 的 Fiat-Shamir with aborts 每次签名平均多次拒绝重试，被拒绝尝试的中间值泄漏此前被丢弃
- 同时利用拒绝+接受尝试的泄漏，单位签名请求泄漏 ×4

### 2. PTA：无需克隆设备的模板攻击
- 传统 Secret-based Template Attack 需在克隆设备上剖析敏感中间值泄漏
- PTA 用**目标设备自身公开数据**（签名、公钥、公开 c）构建模板——攻击门槛大幅降低

### 3. Hedged 模式无 SCA 防护
- hedging（随机化 nonce）对时序/故障类攻击有效（防 nonce 重用）
- 但对功耗 SCA，拒绝采样泄漏依旧存在——hedged ≠ 安全

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击目标 | ML-DSA 拒绝采样循环中 y = Ay + y2 等中间量 |
| 模板构建 | 公开数据（PTA），无需克隆设备 |
| 恢复 c 所需迹数 | 96 条（ML-DSA-44） |
| 密钥恢复所需迹数 | ~300 条（比先前工作少 10×） |
| 适用变体 | ML-DSA-44/65/87 全部安全级别 |
| hedged 模式 | 直接适用（hedging 无 SCA 防护） |
| 平台 | ARM Cortex-M4 |
| 泄漏源 | 拒绝尝试 + 接受尝试功耗迹线 |

## 与已有工作的关系

- **单迹 Dilithium 攻击演进**: Wang 2023/2024 攻击 NTT/密钥解包 [[raw/paper-wang2023-single-trace-dilithium]], [[raw/paper-wang2024-single-trace-dilithium]]，本文开辟拒绝采样新泄漏点，且把迹数需求压到 96/300
- **Hedged 安全迷思**: 与 Jendral 2024 (hedged 单迹 FI) [[raw/paper-jendral2024-hedged-dilithium-fi]] 和 Krahmer 2024 (校正故障) [[raw/paper-krahmer2024-correction-fault-dilithium]] 一同证明 hedged 模式在 FI 和 SCA 两条战线上都不安全
- **NTRU 系对比**: Hermelink 2025 的 BP 突破洗牌 [[raw/paper-hermelink2022-bp-shuffling-ntt]] 依赖大量迹的统计；PTA 思路（用公开数据替代剖析）与 Fouque 2025 CBD 攻击的"公开可验证"思想呼应 [[raw/paper-fouque2025-avengers]]
- **非剖析攻击趋势**: 与 Tosun 2025 (IACR CiC 2(3)) 的高阶非剖析 HOCPA（二阶/三阶掩码 Dilithium 700/2400 迹、Kyber 2200/14500 迹）同属"摆脱克隆设备依赖"的攻击浪潮
- **同名关联**: Qiao 也是 [[raw/paper-qiao2023-ntt-meets-sis]] 作者——NTT+SIS 与本文拒绝采样泄漏构成 Dilithium 泄漏面两个正交维度

## 关联
- Dilithium 实体: [[entities/dilithium]]
- 故障注入概念（hedged 分析）: [[concepts/fault-injection]]
- 深度学习/模板 SCA: [[concepts/deep-learning-sca]]
- NTT SCA（Qiao 关联）: [[concepts/ntt-side-channel-attacks]]
- 防护综述: [[topics/sca-countermeasures-for-lattice-pqc]]
