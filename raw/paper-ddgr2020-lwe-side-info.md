# LWE with Side Information: Attacks and Concrete Security Estimation

> **来源类型**: 论文 (Conference)
> **会议**: CRYPTO 2020
> **作者**: Dana Dachman-Soled, Léo Ducas, Huijing Gong, Mélvenne Rossi
> **年份**: 2020
> **页数**: 30
> **原始文件**: `LWE with Side Information-attacks and concrete security estimation.pdf`

## 核心贡献

本文是 **LWE with Hints 框架的奠基论文**（被后续所有工作 MN, Cao, Hermelink 引用）。首次系统化地定义了侧信道泄漏对 LWE 密钥恢复的帮助，建立了提示类型分类法，并提供了具体的格约减安全估计工具。

### 三大贡献

1. **提示类型分类法**: 定义了 4 种提示类型（perfect, modular, approximate, short vector），统一建模各种侧信道泄漏
2. **DBDD 集成框架**: 引入畸变有界距离解码（Distorted BDD）作为中间问题，将提示逐步集成后转化为 uSVP 进行格约减
3. **Sage 安全估计工具**: 开源 SageMath 工具包，自动计算给定提示量下的 BKZ 块大小需求

## 四种提示类型

| 提示类型 | 数学定义 | 信息量 | 实际来源 |
|---------|---------|--------|---------|
| **完美 (Perfect)** | ⟨v, s⟩ = l | 最强 | 泄漏 NTT 前未取模的精确值 |
| **模 (Modular)** | ⟨v, s⟩ = l mod m | 中 | 泄漏 mod q 后的值 |
| **近似 (Approximate)** | ⟨v, s⟩ ≈ l + N(0,σ) | 弱 | 有噪声的泄漏 |
| **短向量 (Short Vector)** | w = s + e, ||e|| 小 | 中-强 | 格上的短向量关系 |

## DBDD 框架

### 问题定义
- **DBDD (Distorted Bounded Distance Decoding)**: 给定格 L 和畸变参数，找到唯一满足 ||x - c||_D ≤ d 的格点 x
- 畸变度量 D 允许非各向同性距离（不同维度有不同权重）

### 集成流程
```
LWE 实例 + 提示 → DBDD 实例 → Kannan 嵌入 → uSVP → 格约减
```

1. LWE → BDD: 标准转换
2. BDD → DBDD: 加入畸变（噪声分布信息）
3. 提示集成: 每个提示修改 DBDD 实例（降维/修改中心/修改畸变矩阵）
4. DBDD → uSVP: Kannan 嵌入转为唯一最短向量问题
5. uSVP → 格约减: BKZ 求解

### 提示集成的几何意义
- **完美提示**: 超平面切割——在超平面 ⟨v, s⟩ = l 上投影
- **模提示**: 多个平行超平面切割
- **近似提示**: 超平面附近的高斯模糊切割
- **短向量提示**: 在格上添加一个短向量关系

## Frodo 应用案例

- **Frodo-640**: 原始安全估计 448 bikz
- **+ 5 个完美提示**: 安全降至 ~220 bikz（降低 ~50%）
- **+ 10 个完美提示**: 安全降至 ~29 bikz（完全崩溃）
- **+ 解密失败提示**: 利用 DFR (Decryption Failure Rate) 泄漏的近似提示

## 结构提示

论文还讨论了来自设计本身的结构性提示：
- Frodo 的秘密向量有特定结构（稀疏/小系数）
- 这些"免费"提示降低了实际安全强度
- 类比: Kyber 的秘密从 CBD 采样（已知分布→可建模为结构提示）

## 安全估计方法

### BKZ 代价模型
- **Core-SVP**: 2^(0.292·β) (经典) / 2^(0.265·β) (量子)
- **维度估计**: DBDD 集成后计算剩余格的维度和体积
- **β_req**: 从体积反推所需 BKZ 块大小

### Sage 工具
```
# 伪代码示意
dbdd = DBDD(n, q, sigma, s_dist)
dbdd.integrate_hint_perfect(v, l)    # 完美提示
dbdd.integrate_hint_modular(v, l, m) # 模提示
dbdd.integrate_hint_approx(v, l, sigma) # 近似提示
beta = dbdd.estimate_beta()           # 估计所需 BKZ 块大小
```

## 局限性

1. **逐步集成**: 每个提示单独处理，计算密集
2. **无法处理密码学维度**: 实际提示量太大时框架不可扩展
3. **仅理论估计**: 未在真实 LWE 实例上验证
4. **无"too many hints"概念**: 未发现提示量阈值

## 与后续工作的关系

| 后续论文 | 改进点 | 引用关系 |
|---------|--------|---------|
| MN [Asiacrypt 2023] | 一次处理所有提示，定义阈值 | 直接引用本文提示类型 |
| Cao [CRYPTO 2025] | 高斯消元替代逐步集成 | 引用本文 DBDD→uSVP 流程 |
| Hermelink [2025] | 分布提示统一框架 | 扩展本文提示类型分类 |
| Dachman-Soled [CRYPTO 2023] | 几何视角重访 | 本文的直接续作 |
| Li [TCHES 2025] | 模提示→直接低维格 | 引用本文模提示定义 |

## 关键数据点

- Frodo 原始安全: 448 bikz
- 5 完美提示后: ~220 bikz
- 10 完美提示后: ~29 bikz
- 提示集成是**非线性**的——前几个提示降维最多

## 变更记录
- 2026-08-05: 初始创建，来源 PDF 提取
