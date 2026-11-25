# Roulette: A Diverse Family of Feasible Fault Attacks on Masked Kyber

> **作者**: Jeroen Delvaux
> **发表**: TCHES 2022(4), pp. 637-660
> **URL**: https://tches.iacr.org/index.php/TCHES/article/view/9835
> **类型**: Kyber FI — 突破掩码的多样化故障攻击

## 摘要

在 Indocrypt 2021，Hermelink, Pessl 和 Pöppelmann 提出了针对 Kyber 的故障攻击，通过生成和求解私钥的线性不等式系统来恢复密钥。本文从四个方面促进和多样化该攻击，引入更便宜和更宽容的故障注入设置。

## 核心贡献

### 1. 攻击面扩大
- 原始: 密文比较的两个输入操作数
- 扩展: 重加密模块（二项采样、INTT 最后一层的蝴蝶运算、模约减、密文压缩）
- 可绕过 Indocrypt 论文提出的定制防护

### 2. 故障模型放宽
- 原始: 精确比特翻转
- 扩展: set-to-0、set-to-1、随机故障、任意比特翻转、指令跳过

### 3. 掩码和盲注反而帮助攻击
- 随机化中间变量的随机故障命中期望值集
- 圆环上的视觉类比 → "轮盘赌"命名
- 与大多数故障攻击不同（掩码通常阻碍或无影响）

### 4. 加速和改善容错
- 运行时间: ~100 分钟 → ~1 分钟
- 不等式错误率: ~1% → ~25%
- 使用 Pessl & Prokop 的过滤技术将不等式需求减半
- 50% 不等式损坏仍可完全恢复密钥

### 5. 低成本实际验证
- ChipWhisperer 板（价格合理）
- 时钟故障攻击掩码 Kyber on ARM Cortex-M4
- 最多 20 次故障注入即可

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击目标 | 重加密模块（INTT 蝴蝶、二项采样等） |
| 故障模型 | set-to-0/1, 随机, 比特翻转, 指令跳过 |
| 掩码影响 | **帮助攻击**（随机化→轮盘命中） |
| 运行时间 | ~1 分钟 |
| 容错率 | 25% 不等式错误 |
| 平台 | ChipWhisperer + Cortex-M4 |
| 最大故障数 | 20 |

## 与已有工作的关系

- **直接改进**: Hermelink 2021 [[raw/paper-hermelink2021-fault-cc-kyber]] — 放宽故障模型，扩大攻击面
- **基础**: Pessl & Prokop 2021 [[raw/paper-pessl2021-fault-cca-kem]] — 使用其过滤技术
- **掩码反直觉**: 掩码在此攻击中反而帮助攻击者——与正常 SCA 防护相反

## 关联
- 前身: [[raw/paper-hermelink2021-fault-cc-kyber]], [[raw/paper-pessl2021-fault-cca-kem]]
- 掩码概念: [[concepts/masking-and-shuffling]]
- Kyber 实体: [[entities/kyber-kem]]
- 故障概念: [[concepts/fault-injection]]
- 贪心求解器: [[concepts/greedy-solver]]
