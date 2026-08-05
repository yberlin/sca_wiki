# Refined Attack on LWE with Hints: Constructing Lattice via Gaussian Elimination

> **原始资料类型**: 学术论文
> **标题**: Refined Attack on LWE with Hints: Constructing Lattice via Gaussian Elimination
> **作者**: Jinzheng Cao, Haodong Jiang, Qingfeng Cheng
> **机构**: Information Engineering University, Zhengzhou, China (信息工程大学)
> **发表会议**: CRYPTO 2025, LNCS 16000, pp. 385-416
> **DOI**: 10.1007/978-3-032-01855-7_13
> **关键词**: LWE, Lattice based attack, Post-quantum cryptography

## 论文核心摘要

本文提出了 LWE with hints 的改进攻击框架。核心创新是一种改进的提示集成方法，将 LWE with hints 分解为 SIS 部分和 LWE 部分。这一新视角通过高斯消元（而非 LLL 归约）高效降维。

## 三大贡献

### 1. 改进的格构造方法
- **SIS-LWE 分解**: 将提示转化为 Z-SIS（小整数解）问题，其秘密向量与 LWE 相同
- **高斯消元降维**: 用 REF（行阶梯形）归约代替 LLL 归约进行降维——比 MN [Asiacrypt 2023] 快数倍
- **一次处理所有提示**: DDGR 一次处理一个提示，MN 虽批量但依赖 LLL 归约，本文用 REF 实现批量处理+正确性证明

### 2. 复杂度估计器
- 提供估计 LWE with hints 平均求解时间的框架
- 涵盖完美提示、模提示、mod-q 提示和近似提示

### 3. "Too Many Hints" 制度的改进
- 扩展了 MN 的 "too many hints" 概念
- 提出"广义 too many hints 制度"——约 230 个提示即可用 LLL 直接恢复密钥

## 实验结果

### 与 MN 方法的速度对比

| 方案 | MN 方法时间 | 本文方法时间 | 加速比 |
|------|-----------|------------|--------|
| Kyber-512 (200 perfect hints) | 7h | 1h | 7× |
| NTRU (200-350 perfect hints) | — | 10× 加速 | 10× |

### Too Many Hints 制度对比

| 方案 | 预测 k | MN 方法 k | 本文 k | 时间 |
|------|-------|---------|-------|------|
| Kyber-512 | 235 | 233 | 230 | 2.1 min |
| Kyber-768 | 354 | 390 | 376 | 9.8 min |
| NTRU-509 | 234 | 230 | 226 | 2.3 min |
| NTRU-677 | 310 | 334 | 325 | 3.8 min |
| Falcon-512 | 238 | 231 | 227 | 1.8 min |
| Falcon-1024 | 477 | 560 | 540 | 27.8 min |
| Dilithium-1024 | 348 | 463 | 450 | 44.9 min |

## 与已有工作的对比

| 维度 | DDGR [CRYPTO 2020] | MN [Asiacrypt 2023] | 本文 [CRYPTO 2025] |
|------|-------------------|--------------------|--------------------|
| 提示处理 | 逐个 | 批量（LLL） | 批量（REF/高斯消元） |
| 正确性证明 | 有 | 有（需矩阵质量假设） | 有（直接证明） |
| mod-q 提示 | 不支持 | 支持 | 支持 |
| 效率 | 慢 | 中 | 快 |
| 通用性 | 高 | 中 | 高 |

## 核心结论

1. 通过 SIS-LWE 分解和高斯消元，大幅加速了 LWE with hints 的格构造
2. Kyber-512 从 7 小时降至 1 小时，NTRU 加速 10 倍
3. 扩展了 "too many hints" 制度，所需提示数更少
4. 强调了保护 PQC 方案免受泄漏的重要性
