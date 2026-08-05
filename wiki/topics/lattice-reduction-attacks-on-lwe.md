# 主题综述：格约减攻击 LWE with Hints

> **类型**: topic
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ddgr2020-lwe-side-info]], [[raw/paper-dachman2023-geometric]], [[raw/paper-may2023-too-many-hints]], [[raw/paper-cao2025-refined-attack]], [[raw/paper-li2025-hertzbleed-hints]], [[raw/paper-hermelink2025-generic-framework]]

## 摘要

本文档综合分析利用侧信道泄漏（hints）辅助格约减来攻击 LWE-based 后量子密码方案的完整图景。涵盖从提示获取到格约减恢复密钥的全流程，以及两条技术路线（格约减 vs 贝叶斯更新）的对比与互补。

## 技术路线全景

```
侧信道泄漏
    │
    ├── 格约减路线 (Lattice-centric)
    │   ├── DDGR [CRYPTO 2020]: DBDD → uSVP → BKZ（奠基框架）
    │   ├── 几何扩展 [CRYPTO 2023]: 椭球视角 + 不等式提示 + 组合提示
    │   ├── MN [Asiacrypt 2023]: 一次处理 → "too many hints" → LLL
    │   ├── Cao [CRYPTO 2025]: SIS-LWE 分解 → 高斯消元 → 格约减
    │   ├── Li [TCHES 2025]: 模提示 → 直接低维格 → G6K BKZ
    │   ├── Fouque [TCHES 2025]: CBD 单迹 → "way too many hints" → 高斯消元/BKZ
    │   └── Hhan [S&P 2026]: 稀疏秘密 → O(h log²h) 提示 → 多项式时间
    │
    └── 贝叶斯更新路线 (Bayesian updating)
        ├── BP [PP21, HPP21, Del22]: 置信传播
        ├── 贪心 [Ravi 2024]: 贪心搜索
        └── Hermelink [2025]: 分布提示统一框架 (BP + 贪心)
```

## 提示获取 → 密钥恢复：完整流程

### Step 1: 提示获取

| 泄漏源 | 提示类型 | 来源论文 |
|--------|---------|---------|
| Hertzbleed DVFS 频率侧信道 | mod-q | [[raw/paper-li2025-hertzbleed-hints]] |
| HW(m') 侧信道 (合法密文) | 分布(不等式) | [[raw/paper-ravi2024-defeating-lcc]] |
| CBD 采样器单迹 (密钥生成) | 完美(坐标) | [[raw/paper-fouque2025-avengers]] |
| 解密失败 oracle | 不等式(半空间) | [[raw/paper-dachman2023-geometric]], [BDH+21] |
| OpenFHE NTT 泄漏 | 完美/近似 | [[raw/paper-hhan2025-perfect-to-approx]] |
| NTT 逆换单迹 | 完美/模 | [PPM17] |
| Cold boot | 近似 | [ADP18] |
| 故障注入 | 完美/近似 | [HPP21, Del22] |
| SCA + DF 组合 | 组合提示 | [[raw/paper-dachman2023-geometric]] |

### Step 2: 提示集成

| 方法 | 提示类型 | 集成方式 | 效率 |
|------|---------|---------|------|
| DDGR | 全部 | 逐步→[[concepts/dbdd|DBDD]] | 慢 |
| MN | perfect, modular | 一次→LLL降维 | 中 |
| Cao | 全部 | 一次→REF/高斯消元 | 快 |
| Hermelink | 分布 | BP/贪心迭代 | 中-快 |
| Fouque (Avengers) | 完美(坐标) | 坐标恢复→降维→高斯消元/BKZ | 快 |
| Hhan | 完美/近似 | NonZeroEntryGuess→线性代数 | 快 |

### Step 3: 格约减/求解

| 方法 | 剩余维度 | 算法 | 时间 |
|------|---------|------|------|
| MN (mod-q, k≈0.9n) | ~0.1n (60-66) | LLL | 20-45 min |
| MN (perfect, k≈n/2) | ~n/2 | LLL | 3h-7d |
| Cao (REF) | n-k (更小) | LLL | 1-45 min |
| Li (直接低维格) | 256 | G6K BKZ β=25-36 | 300-400s |
| Fouque (way too many) | 0 | 高斯消元 | <1s |
| Fouque (partial) | n-ρn | BKZ β=23-65 | <18h |
| Hhan (sparse, h log²h) | 0 | 多项式时间线性代数 | 秒级 |
| Hermelink (BP) | 原始 | BP迭代 | 10min-5h |
| Hermelink (贪心) | 原始 | 贪心迭代 | 0.2-1.4min |
| 无提示 | n | BKZ β≈300+ | 不可行 |

## 各方案的攻击门槛

| 方案 | n | mod-q LLL门槛 | perfect LLL门槛 | Cao too-many-hints | 最佳格约减攻击 |
|------|---|-------------|----------------|-------------------|-------------|
| Kyber-512 | 512 | 449 (88%) | 234 (46%) | 230 | G6K 374s [Li] |
| Kyber-768 | 768 | 702 (91%) | 390 (51%) | 376 | — |
| NTRU-509 | 509 | — | — | 226 | 2^34 [Li] |
| NTRU-701 | 701 | 622 (89%) | 332 (47%) | — | — |
| Dilithium-1024 | 1024 | 876 (85%) | 463 (45%) | 450 | — |
| Falcon-512 | 512 | 452 (88%) | 233 (46%) | 227 | — |
| Falcon-1024 | 1024 | — | — | 540 | — |

## 两条路线的互补关系

### 格约减路线优势
- 对确定性提示（perfect, modular）非常高效
- 提供剩余难度的理论估计
- 可处理大系数提示

### 贝叶斯更新路线优势
- 对概率性/有噪声的提示天然支持
- 可处理 HW 泄漏（格约减需近似为值泄漏）
- 部分错误信息可容忍
- 不等式系数与密钥不相关时更优

### 结合方向
- Hermelink 2025: BP 输出可集成到 primal attack 格中（贪心也可以）
- Cao 2025: 提示先用 SIS 分解再用格约减
- 未来: 综合两条路线的最优策略

## 关键发现

1. **完美提示极其强大** — 仅需 n/2 个即可用 LLL 恢复密钥 [MN]
2. **mod-q 提示需 0.9n** — 但格构造秒级完成 [MN]
3. **直接低维格优于高维集成** — Li 400 秒恢复简化 Kyber 密钥
4. **高斯消元优于 LLL 降维** — Cao 将 MN 的速度提升 7-10 倍
5. **贪心与 BP 互补** — Hermelink 统一了两者，纠正了"贪心简单优于 BP"的观点
6. **Dilithium 大 q 是双刃剑** — 更高 LLL 门槛但泄漏面更宽 (s, e 都泄漏)
7. **CBD 采样器是新攻击面** — Fouque 单迹恢复 37-68% 系数，高斯消元/BKZ 补全
8. **稀疏秘密大幅降低阈值** — Hhan 将阈值从 O(n) 降至 O(h log²h)，FHE 场景降 82-99%

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/dilithium]], [[entities/nttru]], [[entities/hertzbleed]]
- 相关概念: [[concepts/lwe-hints-framework]], [[concepts/modular-hints]], [[concepts/lattice-reduction]], [[concepts/distribution-hints]], [[concepts/greedy-solver]], [[concepts/dbdd]], [[concepts/sparse-secret-lwe]]
- 参见: [[topics/sca-countermeasures-for-lattice-pqc]], [[topics/comparison-ravi2024-vs-prior-work]]

## 引用来源
- [1] [[raw/paper-ddgr2020-lwe-side-info]] — DDGR 奠基框架，DBDD，4 种提示类型，Sage 工具
- [2] [[raw/paper-dachman2023-geometric]] — 几何视角，不等式提示，组合提示
- [3] [[raw/paper-may2023-too-many-hints]] — "Too Many Hints" 制度
- [4] [[raw/paper-cao2025-refined-attack]] — 高斯消元改进
- [5] [[raw/paper-li2025-hertzbleed-hints]] — Hertzbleed + 低维格
- [6] [[raw/paper-hermelink2025-generic-framework]] — 分布提示统一框架
- [7] [[raw/paper-ravi2024-defeating-lcc]] — 贪心求解器（对比基准）
- [8] [[raw/paper-fouque2025-avengers]] — CBD 单迹攻击，"way too many hints" 制度
- [9] [[raw/paper-hhan2025-perfect-to-approx]] — 稀疏秘密 O(h log²h) 阈值

## 变更记录
- 2026-08-05: 初始创建，综合 4 篇新论文
- 2026-08-05: 更新——添加 DDGR [CRYPTO 2020] 和几何视角 [CRYPTO 2023] 两篇奠基论文，添加 DBDD 概念链接，添加组合提示来源
- 2026-08-05: 更新——添加 Fouque (way too many hints) 和 Hhan (O(h log²h)) 两条新路线，添加 sparse-secret-lwe 概念链接，添加 CBD 和 OpenFHE 泄漏源
