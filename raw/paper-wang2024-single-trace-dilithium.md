# Single Trace is All It Takes: Efficient Side-channel Attack on Dilithium

> **作者**: (未列名)
> **发表**: IACR ePrint 2024/512 (预印本)
> **URL**: https://eprint.iacr.org/2024/512
> **类型**: Dilithium SCA — 高效单迹攻击

## 摘要

本文关注 Dilithium 的实际安全性。在 STM32F4 平台上对 Dilithium2 进行实际攻击。结果表明仅需两条签名即可在 5 分钟内执行攻击，单条签名提供 60% 的私钥恢复概率（1 小时内）。攻击分析多项式加法 z = y + cs1，分两阶段：侧信道分析恢复 y 或 cs1，然后求解 cs1 的带误差方程组。

## 核心贡献

### 1. 线性回归模板攻击
- 利用大数+小数加法的数学性质
- 恢复 y（随机多项式）
- 单迹 40% 成功率

### 2. CNN 模板攻击
- 用 200 条签名训练 CNN
- 恢复 cs1（与私钥相关）
- 单迹 74% 成功率

### 3. 联合泄露利用
- 利用 z = y + cs1 约束
- 联合 y 和 cs1 的泄露
- cs1 恢复成功率提升到 **92%**

### 4. 约束优化残差分析
- 求解 cs1 = b 的带误差方程组
- 可独立使用或作为 BP/ILP 的预处理
- 95% 正确率: 83% 成功，5 秒
- 5% 正确率: 仍可恢复，需 ~200 条签名，5 分钟

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 平台 | STM32F4 (Dilithium-2) |
| 目标 | z = y + cs1 加法运算 |
| y 恢复 | 线性回归, 40% 单迹 |
| cs1 恢复 | CNN 模板, 74% 单迹 |
| 联合恢复 | 92% 单迹 |
| 后处理 | 约束优化 |
| 95% 正确率 | 83% 成功, 5 秒 |
| 5% 正确率 | ~200 签名, 5 分钟 |

## 与已有工作的关系

- **改进 Wang 2023**: 将单迹成功率从 9% 提升至 60% [[raw/paper-wang2023-single-trace-dilithium]]
- **BP 关联**: 可作为 BP 或 ILP 的预处理
- **格约减替代**: 约束优化在某些场景可替代格约减

## 关联
- 前身: [[raw/paper-wang2023-single-trace-dilithium]]
- BP 概念: [[concepts/greedy-solver]], [[concepts/distribution-hints]]
- 格约减概念: [[concepts/lattice-reduction]]
- Dilithium 实体: [[entities/dilithium]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
