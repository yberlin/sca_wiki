# More Practical Single-Trace Attacks on the Number Theoretic Transform

> **作者**: Peter Pessl, Robert Primas
> **发表**: LATINCRYPT 2019 (IACR ePrint 2019/795)
> **URL**: https://eprint.iacr.org/2019/795
> **类型**: 基础工作 — 改进 NTT 单迹攻击

## 摘要

单迹侧信道攻击对经典公钥方案实现构成相当大的威胁。然而，对于格密码，这类攻击的理解要少得多，只有少量先前的工作展示了攻击。Primas 等人提出了针对 NTT 的单迹攻击，但他们攻击的是变时间实现，并且需要相当强大的侧信道对手，能够创建接近百万个多变量模板。因此，能否在针对最先进的常时间实现的同时使攻击更加实用，仍然是一个开放问题。

本文对这个问题给出了肯定的回答。

## 核心贡献

### 1. 信念传播改进
- 对 BP 的使用引入多项改进
- 提高了攻击性能和噪声抗性

### 2. 目标转移：加密替代解密
- 将攻击目标从解密改为加密
- 限制为恢复传输的对称密钥（而非私钥）
- 但大幅提升了攻击性能

### 3. 单变量模板
- 从多变量模板切换到单变量汉明权重模板
- 仅需 **213 个模板**（vs Primas 2017 的百万级）
- 成功攻击常时间 Kyber 实现

### 4. 实际验证
- 目标: ARM Cortex-M4 上的汇编优化常时间 Kyber 实现
- 仿真和真实设备均验证成功
- 在噪声模型下评估性能和噪声抗性

## 关键技术细节

| 维度 | Primas 2017 | Pessl 2019 |
|------|-------------|-----------|
| 目标 | 解密 (私钥恢复) | 加密 (消息恢复) |
| 实现 | 变时间 | 常时间 |
| 模板 | ~10^6 多变量 | 213 单变量 |
| BP | 基础 | 改进版 |
| 平台 | Cortex-M4F | Cortex-M4 |

## 与已有工作的关系

- **直接改进** [[raw/paper-primas2017-single-trace-lattice]]: 将模板需求降低 4 个数量级
- **后续被扩展**: Hermelink 2022 加入洗牌对抗 [[raw/paper-hermelink2022-bp-shuffling-ntt]]
- **BP 框架** [[concepts/greedy-solver]]: 本文改进的 BP 后续被 Ravi 2024 的贪心求解器近似

## 关联
- 前身: [[raw/paper-primas2017-single-trace-lattice]]
- BP 洗牌对抗: [[raw/paper-hermelink2022-bp-shuffling-ntt]]
- 综述引用: [[raw/paper-ravi2022-sca-fia-survey]]
