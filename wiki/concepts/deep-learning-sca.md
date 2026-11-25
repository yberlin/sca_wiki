# 深度学习侧信道攻击

> **类型**: concept
> **创建时间**: 2026-08-06
> **最后更新**: 2026-08-06
> **来源**: [[raw/paper-wang2023-single-trace-dilithium]], [[raw/paper-wang2024-single-trace-dilithium]], [[raw/paper-zhang2025-cc-sca-shuffled-kyber]], [[raw/paper-jendral2023-single-trace-masked-kyber]], [[raw/paper-fouque2025-avengers]]

## 摘要

深度学习侧信道攻击将深度学习技术应用于侧信道分析，通过神经网络自动提取侧信道迹线中的特征，实现密钥恢复。在格后量子密码中，深度学习已被成功应用于 Dilithium 单迹攻击、Kyber 洗牌突破、CBD 采样器攻击等多个场景，显著提升了攻击的自动化程度和成功率。

## 深度学习方法分类

### 1. CNN 模板攻击
- **Wang 2024** [[raw/paper-wang2024-single-trace-dilithium]]: CNN 恢复 Dilithium 的 cs1，74% 单迹成功率
- 用 200 条签名训练 CNN
- 从 z = y + cs1 的多项式加法泄露恢复

### 2. 深度学习辅助功率分析
- **Wang 2023** [[raw/paper-wang2023-single-trace-dilithium]]: 深度学习辅助模板分析 Dilithium 密钥解包
- **Jendral 2023** [[raw/paper-jendral2023-single-trace-masked-kyber]]: 深度学习辅助功率分析 Kyber 消息恢复

### 3. MLP 分类器
- **Zhang 2025** [[raw/paper-zhang2025-cc-sca-shuffled-kyber]]: MLP 从侧信道迹线进行汉明权重分类，97.11% 准确率
- 结合可解释深度学习进行迹线分割

### 4. AdaBoost 决策树
- **Fouque 2025** [[raw/paper-fouque2025-avengers]]: AdaBoost 决策树分类器恢复 Kyber CBD 采样器系数，68% 恢复率

### 5. 线性回归
- **Wang 2024** [[raw/paper-wang2024-single-trace-dilithium]]: 利用大数+小数加法性质，线性回归恢复 y，40% 单迹

## 深度学习 vs 传统方法

| 维度 | 深度学习 | 传统方法 |
|------|----------|----------|
| 模板创建 | 自动学习特征 | 手工设计模板 |
| 特征提取 | CNN/MLP/AdaBoost | 统计相关 |
| 适用场景 | 复杂非线性泄露 | 线性泄露 |
| 数据需求 | 训练数据（200-1000 条） | 模板对（213~10^6） |
| 成功率 | 40-97% | 依赖模板质量 |

## 关键应用场景

### Dilithium
- 密钥解包泄露 → DL 辅助模板分析 (Wang 2023)
- z = y + cs1 → CNN + 线性回归 (Wang 2024)

### Kyber
- 洗牌实现 → MLP + 可解释 DL (Zhang 2025)
- 掩码+洗牌 → DL 辅助 SCA + VFI (Jendral 2023)
- CBD 采样器 → AdaBoost 决策树 (Fouque 2025)

## 关联
- Dilithium 攻击: [[raw/paper-wang2023-single-trace-dilithium]], [[raw/paper-wang2024-single-trace-dilithium]]
- Kyber 攻击: [[raw/paper-zhang2025-cc-sca-shuffled-kyber]], [[raw/paper-jendral2023-single-trace-masked-kyber]]
- CBD 采样器: [[raw/paper-fouque2025-avengers]]
- Dilithium 实体: [[entities/dilithium]]
- Kyber 实体: [[entities/kyber-kem]]
- 相关概念: [[concepts/ntt-side-channel-attacks]], [[concepts/greedy-solver]]

## 引用来源
- [1] [[raw/paper-wang2023-single-trace-dilithium]] — Dilithium 单迹 DL 攻击
- [2] [[raw/paper-wang2024-single-trace-dilithium]] — Dilithium CNN 模板攻击
- [3] [[raw/paper-zhang2025-cc-sca-shuffled-kyber]] — MLP 汉明权重分类
- [4] [[raw/paper-jendral2023-single-trace-masked-kyber]] — DL 辅助 + VFI 组合
- [5] [[raw/paper-fouque2025-avengers]] — AdaBoost CBD 采样器

## 变更记录
- 2026-08-06: 初始创建，涵盖 DL SCA 方法分类、应用场景、与传统方法对比
