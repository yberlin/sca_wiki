# CRYSTALS-Kyber KEM

> **类型**: entity
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ravi2024-defeating-lcc]]

## 摘要

CRYSTALS-Kyber 是一种基于 Module Learning With Errors (MLWE) 问题的密钥封装机制（KEM），于 2022 年 7 月被 NIST 选为第一个标准化的后量子 KEM 算法。Kyber 即将大规模部署于各类计算设备，包括资源受限的嵌入式微控制器。

## 详情

### 数学基础

- **底层困难问题**: Module Learning With Errors (MLWE)
- **多项式环**: R_q = Z_q/(X^n + 1), 其中 q = 3329, n = 256
- **模维度**: R_q^k, k = 2/3/4 (对应 NIST 安全等级 1/3/5)
- **噪声分布**: 中心化二项分布 (Centered Binomial Distribution, CBD), 范围 [-η, η]

### 参数集

| 参数集 | 安全等级 | k | n | q |
|-------|---------|---|---|---|
| Kyber512 | NIST L1 | 2 | 256 | 3329 |
| Kyber768 | NIST L3 | 3 | 256 | 3329 |
| Kyber1024 | NIST L5 | 4 | 256 | 3329 |

### 密钥生成 (CPAPKE.KeyGen)
1. A ← U(R_q^{k×k}) — 均匀随机矩阵
2. (s, e) ← χ(R_q^k) × χ(R_q^k) — 从 CBD 采样秘密和错误
3. b = A·s + e — MLWE 实例
4. 公钥 pk = (A, b), 秘密密钥 sk = s

### 加密 (CPAPKE.Enc)
1. 采样 r, e1, e2 ← χ
2. u = A^T·r + e1
3. v = ⟨b, r⟩ + e2 + ⌊q/2⌉·m
4. 压缩 c1 = ⌊u⌉_{q→p}, c2 = ⌊v⌉_{q→T}

### 解密 (CPAPKE.Dec)
1. u' = ⌊c1⌉_{p→q} (解压)
2. v' = ⌊c2⌉_{T→q} (解压)
3. m' = v' - ⟨s, u'⟩ — 噪声消息多项式
4. m = ⌊m'⌉_{q→2} — 解码为消息比特

### CCA 安全性 (FO 变换)
- IND-CPA 安全的 PKE 通过 Fujisaki-Okamoto (FO) 变换转化为 IND-CCA 安全的 KEM
- 解封装时重新加密并比对密文，验证合法性
- 理论上提供强 CCA 安全保证，但侧信道攻击可绕过

### 噪声消息多项式 m'

解密中的核心中间值：
- m' = ⌊q/2⌉·m + Δm
- Δm = ⟨e, r⟩ - ⟨s, e1 + Δu⟩ + e2 + Δv
- Δm 的标准差 σ(Δm[i]) ≈ 79 (Kyber768)
- m'[i] 的分布围绕 q/2 (当 m[i]=1) 或 0 (当 m[i]=0) 的窄钟形分布

### 实现库
- **pqm4**: ARM Cortex-M4 上的后量子密码库，包含参考和汇编优化实现
- **mkm4**: 一阶掩码 Kyber 实现库

## 关联
- 相关概念: [[concepts/sca-classification-kc-vs-cc]], [[concepts/oracle-attacks-pc-fd-df]]
- 相关攻击: [[concepts/sca-classification-kc-vs-cc]], [[concepts/oracle-attacks-pc-fd-df]]
- 相关防护: [[concepts/ciphertext-sanity-check]], [[concepts/decapsulation-failure-check]], [[concepts/masking-and-shuffling]]
- 相关格约减: [[concepts/lwe-hints-framework]], [[concepts/lattice-reduction]], [[concepts/modular-hints]], [[concepts/distribution-hints]]
- 相关团队: [[entities/ravi-research-group]]
- 相关方案: [[entities/dilithium]], [[entities/nttru]]
- 参见: [[topics/sca-countermeasures-for-lattice-pqc]], [[topics/lattice-reduction-attacks-on-lwe]], [[topics/comparison-ravi2024-vs-prior-work]]

## 引用来源
- [1] [[raw/paper-ravi2024-defeating-lcc]] — Kyber KEM 规范与 SCA 分析
- [2] [ABD+20] CRYSTALS-Kyber (version 3.0) 规范文档
- [3] [[raw/paper-may2023-too-many-hints]] — Kyber 的 LWE with hints 攻击门槛
- [4] [[raw/paper-cao2025-refined-attack]] — Kyber 的高斯消元改进攻击
- [5] [[raw/paper-li2025-hertzbleed-hints]] — Kyber 的 Hertzbleed + 低维格攻击
- [6] [[raw/paper-hermelink2025-generic-framework]] — Kyber 的分布提示框架
- [7] [[raw/paper-ddgr2020-lwe-side-info]] — LWE with Hints 奠基框架（通用安全估计工具）
- [8] [[raw/paper-dachman2023-geometric]] — 几何视角安全估计修正
- [9] [[raw/paper-fouque2025-avengers]] — CBD 采样器单迹攻击，密钥生成阶段攻击面
- [10] [[raw/paper-hhan2025-perfect-to-approx]] — 稀疏秘密 O(h log²h) 阈值（FHE 场景参考）

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-ravi2024-defeating-lcc]]
- 2026-08-05: 更新——添加 4 篇新论文的交叉引用（格约减攻击路线）
- 2026-08-05: 更新——添加 DDGR 和几何视角两篇奠基论文引用
- 2026-08-05: 更新——添加 Fouque (CBD 采样器攻击) 和 Hhan (稀疏秘密) 引用
