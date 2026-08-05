# A Generic Framework for Side-Channel Attacks against LWE-based Cryptosystems

> **原始资料类型**: 学术论文
> **标题**: A Generic Framework for Side-Channel Attacks against LWE-based Cryptosystems
> **作者**: Julius Hermelink, Silvan Streit, Erik Mårtensson, Richard Petri
> **机构**: Max Planck Institute for Security and Privacy (Bochum), Fraunhofer AISEC (Munich), TUM, Lund University, Advenica AB
> **关键词**: Lattice-based cryptography, Lattice Reduction, ML-KEM, Belief Propagation, Side-Channel Attacks, Kyber
> **开源代码**: https://github.com/juliusjh/distribution_hints 和 https://github.com/juliusjh/distribution_hints_solvers

## 论文核心摘要

本文提出了"分布提示"（Distribution Hints）——一种统一建模侧信道信息中概率信息的新型提示类型。这些提示泛化了此前定义的大多数提示类型和实际攻击中获得的信息。作者定义了两种求解器：基于置信传播（BP）和贪心方法，并证明后者是前者的计算更省的近似。该框架不限于值泄漏，可处理有噪声的汉明重量泄漏或部分错误信息。

## 三大贡献

### 1. 分布提示（Distribution Hints）统一定义
- 泛化了 [DDGR20] 定义的除短向量提示外的所有提示类型
- 允许建模有概率的错误信息（side-channel 信息本质上带有不确定性）
- 可建模 HW 泄漏、非正态噪声分布
- 将此前各攻击中特定算法视为本文求解器的特例

### 2. BP 与贪心求解器的理论统一
- **BP 求解器**: 全连接因子图，变量节点为密钥系数，因子节点为不等式/分布
- **贪心求解器**: 被证明是 BP 的计算更省近似——理论上需要更多提示，但实际中因数值问题和实用性考量可能优于 BP
- > ⚠️ 矛盾标注: 本文对贪心 vs BP 的观点与 [[raw/paper-ravi2024-defeating-lcc]] (Ravi 2024) 不同。Ravi 声称贪心求解器优于 BP 因子 2；本文则认为贪心是 BP 的近似，两者互补，而非简单优于。

### 3. 实际应用
- **改进 Ravi 2024 的攻击**: 将所需信息减少超过 2 倍，使之前不可行的噪声水平变得可行
- **INTT 攻击改进**: 解释分布提示如何改进此前对逆 NTT 的攻击 [PPM17, BBB+23]
- **新攻击方向**: 概述了一个此前未探索的 ML-KEM 解密例程攻击

## 关键技术细节

### 噪声项泄漏
- 噪声项 `⟨e,r⟩ - ⟨s, e1+Δu⟩ + e2 + Δv` 的系数可写为 `⟨v_i, x⟩ + c_i`，其中 `x = (e, s)`
- 此前攻击 [XPRO20, BDH+21, Ravi2024] 利用此构建不等式

### 与格约减方法的对比

| 维度 | 分布提示框架 | 格约减方法 [DDGR20] |
|-----|------------|-------------------|
| 提示类型 | 概率/分布 | 确定性 |
| 错误容忍 | 内在支持 | 难以建模 |
| HW 泄漏 | 直接支持 | 需近似为值泄漏 |
| 计算资源 | 低（贪心）/中（BP） | 高（BKZ β≈300） |
| 适用场景 | 不等式系数与密钥不相关时 | 完美/模提示在 s 上 |

### 运行时间对比 (Table 1, 40 核)
| 设置 | 贪心 (40核) | BP (40核) |
|------|-----------|----------|
| Approximate (2000) | 0.97-1.44 min | 38.58-57.43 min |
| Approximate (5000) | 0.26-0.65 min | 13.35-30.27 min |
| Perfect (2000) | 0.74-1.09 min | 9.67-11.56 min |
| Perfect (5000) | 0.19-0.34 min | 9.68-15.68 min |

## 与已有工作的关系

- **泛化** [[raw/paper-ravi2024-defeating-lcc]] (Ravi 2024): Ravi 的贪心求解器是本文贪心方法的特例
- **改进** [PP21, Del22]: BP 求解器的改进和泛化
- **补充** [DDGR20] (格约减框架): 互补关系——格约减处理确定性提示，分布提示处理概率性提示
- **结合** [Hermelink13]: BP 输出可集成到 primal attack 格中，贪心也可

## 核心结论

1. 贪心求解器和 BP **互补**而非简单替代——贪心是 BP 的近似，但在大提示量/噪声场景中更实用
2. 分布提示框架比格约减方法更灵活，特别适用于 HW 泄漏和有错误的信息
3. 可将 Ravi 2024 攻击的信息需求减少超过 2 倍
4. 为侧信道信息处理提供了系统化方法论
