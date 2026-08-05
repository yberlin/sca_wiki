# LWE with Hints 框架

> **类型**: concept
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ddgr2020-lwe-side-info]], [[raw/paper-dachman2023-geometric]], [[raw/paper-may2023-too-many-hints]], [[raw/paper-cao2025-refined-attack]], [[raw/paper-hermelink2025-generic-framework]]

## 摘要

LWE with Hints 框架系统化地建模侧信道泄漏对 LWE 密钥恢复的帮助。DDGR [CRYPTO 2020] 首次定义了四种提示类型并将其集成到格约减问题中；后续工作 (MN, Cao, Hermelink) 不断改进提示集成的效率和通用性。

## 详情

### 提示类型 (DDGR 定义)

| 提示类型 | 定义 | 信息量 | 实际来源 |
|---------|------|--------|---------|
| 完美提示 (Perfect) | ⟨v, x⟩ = l | 最强 | 泄漏精确值（NTT 前未 mod q） |
| 模提示 (Modular) | ⟨v, x⟩ = l mod m | 中 | 泄漏 mod q 后的值 |
| mod-q 提示 | ⟨v, x⟩ = l mod q | 中 | NTT 后 mod q 的值 |
| 近似提示 (Approximate) | ⟨v, x⟩ = l + N(0,σ) | 弱 | 有噪声的泄漏 |

### 方法演进

```
DDGR [CRYPTO 2020]          MN [Asiacrypt 2023]        Cao [CRYPTO 2025]
  逐步集成 → 一次处理(LLL) → 一次处理(高斯消元/REF)
  理论估计   → 实际验证     → 大幅加速

  Hermelink [2025]: 分布提示统一框架
  (BP + 贪心 = 统一求解器, 贪心是 BP 近似)

  Hhan [S&P 2026]: 稀疏三值秘密 O(h log²h) 阈值
  Fouque [TCHES 2025]: "Way too many hints" → 高斯消元
```

### DDGR 框架 [CRYPTO 2020] — 奠基论文
- **方法**: 逐步将提示集成到 [[concepts/dbdd|DBDD]]（畸变有界距离解码）实例中
- **转换**: DBDD → uSVP（唯一最短向量问题）→ 格约减
- **局限**: 逐步集成计算密集，无法处理密码学维度的提示量
- **提示类型**: 完美、模、近似、短向量
- **Sage 工具**: 提供开源 SageMath 安全估计工具包
- **Frodo 案例**: 5 个完美提示安全从 448→220 bikz，10 个→29 bikz

### 几何视角扩展 [CRYPTO 2023]
- **椭球表示**: DBDD 实例 = 椭球，提示集成 = 椭球几何运算
- **新提示类型**: 不等式提示（半空间切割）、组合提示（椭球融合）
- **Löwner-John 椭球**: 近似交叉结果，保持椭球形式
- **修正**: 修正了 DDGR 完美提示偏乐观、近似提示偏保守的估计偏差

### MN 方法 [Asiacrypt 2023] — "Too Many Hints"
- **创新**: 一次处理所有提示，定义 "too many hints" 制度
- **mod-q**: 线性代数降维 n → n-k（极其高效，秒级构造格基）
- **完美**: 构建提示矩阵 → LLL 降维 → 集成 LWE 样本
- **制度定义**: mod-q k≈0.9n, perfect k≈n/2 即可用 LLL 恢复密钥
- **局限**: 完美提示用 LLL 归约，仍较慢

### Cao 方法 [CRYPTO 2025] — "Refined Attack"
- **创新**: SIS-LWE 分解——将提示转化为 Z-SIS 问题
- **降维**: 高斯消元（REF 归约）代替 LLL 归约
- **优势**: Kyber-512 从 7h→1h, NTRU 加速 10×
- **通用性**: 处理完美、模、mod-q、近似提示

### Hermelink 分布提示 [2025]
- **创新**: 将概率信息纳入提示定义——"分布提示"
- **统一**: BP 和贪心求解器都是分布提示的求解算法
- **贪心 vs BP**: 贪心是 BP 的近似——互补而非简单优于

### Fouque "Way too many hints" [TCHES 2025]
- **创新**: 当恢复系数 >37-46% 时，直接高斯消元（无需格约减）
- **来源**: 单迹攻击 Kyber CBD 采样器，AdaBoost 分类器
- **制度**: 超越 MN 的"too many hints"——h_e ≥ n-h_s 时线性代数即可

### Hhan 稀疏秘密 O(h log²h) [S&P 2026]
- **创新**: 利用稀疏三值结构（h≪n），将阈值从 O(n) 降至 O(h log²h)
- **算法**: NonZeroEntryGuess — 贪心选最大内积，更新剥离
- **适用**: FHE 方案（n=2^15-2^16, h=32-192）
- **分析**: GAA 下的保守下界

### 提示与攻击类型的映射

| 攻击/泄漏源 | 提示类型 | 来源论文 |
|------------|---------|---------|
| Hertzbleed NTT 泄漏 | mod-q | [[raw/paper-li2025-hertzbleed-hints]] |
| 解密失败不等式 | 不等式(半空间) | [[raw/paper-ravi2024-defeating-lcc]], [[raw/paper-dachman2023-geometric]] |
| HW(m') 泄漏 | 分布(概率) | [[raw/paper-ravi2024-defeating-lcc]] |
| CBD 采样器单迹 | 完美(坐标) | [[raw/paper-fouque2025-avengers]] |
| NTT 逆变换单迹 | 完美/模 | [PPM17, ADP18] |
| OpenFHE NTT 泄漏 | 完美/近似 | [[raw/paper-hhan2025-perfect-to-approx]] |
| Cold boot | 近似 | [ADP18] |

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/dilithium]], [[entities/nttru]]
- 相关概念: [[concepts/modular-hints]], [[concepts/lattice-reduction]], [[concepts/greedy-solver]], [[concepts/distribution-hints]], [[concepts/dbdd]], [[concepts/sparse-secret-lwe]]
- 参见: [[topics/lattice-reduction-attacks-on-lwe]], [[topics/sca-countermeasures-for-lattice-pqc]]

## 引用来源
- [1] [[raw/paper-ddgr2020-lwe-side-info]] — DDGR 原始框架，4 种提示类型，DBDD 定义
- [2] [[raw/paper-dachman2023-geometric]] — 几何视角扩展，不等式提示，组合提示
- [3] [[raw/paper-may2023-too-many-hints]] — "Too Many Hints" 制度定义
- [4] [[raw/paper-cao2025-refined-attack]] — 高斯消元改进
- [5] [[raw/paper-hermelink2025-generic-framework]] — 分布提示统一框架
- [6] [[raw/paper-fouque2025-avengers]] — "Way too many hints" 制度，CBD 采样器攻击
- [7] [[raw/paper-hhan2025-perfect-to-approx]] — 稀疏秘密 O(h log²h) 阈值

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-may2023-too-many-hints]] 等
- 2026-08-05: 更新——添加 DDGR [CRYPTO 2020] 和几何视角 [CRYPTO 2023] 的 raw 页面引用，添加 DBDD 概念链接，添加不等式提示
- 2026-08-05: 更新——添加 Fouque (way too many hints) 和 Hhan (O(h log²h)) 两条新路线，添加 sparse-secret-lwe 概念链接
