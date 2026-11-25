# A Fault-Resistant NTT by Polynomial Evaluation and Interpolation

> **作者**: Sven Bauer, Fabrizio De Santis, Kristjane Koleci, Anita Aghaie
> **发表**: TCHES 2024 (IACR ePrint 2024/788)
> **URL**: https://eprint.iacr.org/2024/788
> **类型**: NTT FI 防护 — 多项式求值与插值

## 摘要

NTT 是格密码的核心组件，也是故障攻击的主要目标。本文提出一种新颖高效的 NTT 故障防护方法，基于多项式求值与插值。通过在选定点的求值和插值重建来验证 NTT 输出的正确性，可保护完整的环乘法（NTT 变换 + 逐点乘法）。在 ARM Cortex-M4 上实现，Dilithium 场景下开销为 72%。

## 核心贡献

### 1. 多项式求值-插值防护
- 对多项式 f 在选定点 u 求值: f(u)
- 计算 NTT(f)
- 通过多项式插值从 NTT 输出重建 f(u)
- 比较求值与插值结果 → 检测故障

### 2. 完整保护
- 保护 NTT 正变换
- 保护 NTT 逆变换
- 保护逐点乘法
- 完整环乘法保护

### 3. 实际实现
- ARM Cortex-M4 微控制器
- Dilithium 场景: 72% 计算开销
- 适用于 Kyber 和 Dilithium

### 4. 误差检测特性
- 证明误差检测能力
- 计算所需额外计算开销
- 展示如何具体用于保护 Kyber 和 Dilith 的 NTT

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 防护目标 | NTT 正变换/逆变换/逐点乘法 |
| 防护方法 | 多项式求值 + 插值验证 |
| 适用方案 | Kyber, Dilithium |
| Dilithium 开销 | 72% 计算开销 |
| 平台 | ARM Cortex-M4 |

## 与已有工作的关系

- **防护对象**: Ravi 2022 [[raw/paper-ravi2022-fiddling-twiddle-ntt]] 的 NTT twiddle 常数故障攻击
- **同一作者**: Bauer & De Santis 也是签名验证故障攻击 [[raw/paper-bauer2025-forging-dilithium-falcon]] 的作者

## 关联
- NTT FI 攻击: [[raw/paper-ravi2022-fiddling-twiddle-ntt]]
- 签名验证 FI: [[raw/paper-bauer2025-forging-dilithium-falcon]]
- Kyber 实体: [[entities/kyber-kem]]
- Dilithium 实体: [[entities/dilithium]]
- 故障概念: [[concepts/fault-injection]]
- NTT SCA 概念: [[concepts/ntt-side-channel-attacks]]
