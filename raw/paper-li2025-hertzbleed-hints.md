# Improved Attacks Against Lattice-Based KEMs Using Hints From Hertzbleed

> **原始资料类型**: 学术论文
> **标题**: Improved Attacks Against Lattice-Based KEMs Using Hints From Hertzbleed
> **作者**: Zhiwei Li, Jun Xu, Jun Song, Haomeng Xu, Yan Jia, Yanli Zou, Lei Hu
> **机构**: State Key Laboratory of Cyberspace Security Defense, Institute of Information Engineering, CAS (中科院信工所)
> **发表期刊**: IACR TCHES 2025, Vol. 2025, No. 4, pp. 463-485
> **DOI**: 10.46586/tches.v2025.i4.463-485
> **接收**: 2025-04-15 | **接受**: 2025-06-15 | **发表**: 2025-09-05
> **关键词**: Lattice-based cryptography, Kyber, NTTRU, NTT, Modular hints

## 论文核心摘要

本文改进了 CHES 2024 上 Yu 等人提出的基于 Hertzbleed（DVFS 频率侧信道）的 NTT 侧信道攻击。Yu 等人将泄漏建模为模提示（modular hints）并集成到原始高维格中。本文的关键观察是：这些模提示**足以直接构造低维格**，而非集成到高维原始格中。

## 两大贡献

### 1. 简化 Kyber: 直接构造低维格恢复密钥
- 从 Hertzbleed 攻击获得 256/384/512 个模提示（对应 Kyber512/768/1024）
- 直接用模提示构造 2/3/4 个 256 维低维格
- 用 G6K 框架的 BKZ 算法搜索最短非零向量
- **实验结果**: 在个人电脑上 400 秒内恢复完整私钥

| 参数 | n | q | 提示数 | 格维度 | 格数 | 理论β | 实际β | 时间 |
|------|---|---|-------|-------|------|-------|-------|------|
| Kyber512 | 256 | 3329 | 256 | 256 | 2 | 69 | 25-36 | 374s |
| Kyber768 | 256 | 3329 | 384 | 256 | 3 | 56 | 25-34 | 306s |
| Kyber1024 | 256 | 3329 | 512 | 256 | 4 | 56 | 25-34 | 312s |

### 2. CCA-secure NTTRU: 降维 + 估值改进
- 提取额外模提示（基于 Yu 等人的侧信道方法）
- 利用 NTTRU 私钥特殊形式 `f = 3f' + 1`
- 构造 768 维格，用高斯消元降维
- **攻击复杂度**: 从 Yu 等人的 2^114 降至 **2^34**（巨大改进）

## 与已有工作的对比

| 维度 | Yu et al. CHES 2024 | 本文 |
|------|-------------------|------|
| 格构造 | 集成到高维原始格 | 直接构造低维格 |
| Kyber 密钥恢复 | 无法实现 | 400 秒恢复完整私钥 |
| NTTRU 复杂度 | 2^114 | 2^34 |
| 格约减 | BKZ (高维) | G6K BKZ (低维) |

## 核心结论

1. 模提示的价值被此前工作严重低估——直接构造低维格比集成到高维格有效得多
2. 简化 Kyber 的完整密钥恢复在 PC 上 400 秒即可完成
3. NTTRU 的攻击复杂度从 2^114 降至 2^34，是实际可行的攻击
4. 强调了保护 NTT 操作免受 DVFS 侧信道攻击的重要性
