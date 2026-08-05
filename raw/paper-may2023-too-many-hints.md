# Too Many Hints – When LLL Breaks LWE

> **原始资料类型**: 学术论文
> **标题**: Too Many Hints – When LLL Breaks LWE
> **作者**: Alexander May, Julian Nowakowski
> **机构**: Ruhr-University Bochum, Germany
> **发表会议**: ASIACRYPT 2023, LNCS 14441, pp. 106-137
> **DOI**: 10.1007/978-981-99-8730-6_4
> **关键词**: LWE with Hints, Partial Key Exposure, PQC Standards

## 论文核心摘要

本文引入了一种新方法论，一次性集成和组合任意数量的完美提示和模提示。相比 DDGR [CRYPTO 2020] 的逐步集成方式，本文方法在格基构造上显著更高效，使得在密码学维度下处理大量提示成为可能——定义了"too many hints"制度，其中 LLL 归约即可恢复 LWE 密钥。

## 核心方法

### 方法论创新
- **LWE-centric 而非格-centric**: 先处理所有提示，再集成到格基中（DDGR 从格基出发逐步变换）
- **mod-q 提示**: 简单高效的线性代数方法，k 个提示将 LWE 维度从 n 降至 n-k
- **完美提示**: 先构建提示矩阵，用 LLL 降维，再集成 LWE 样本
- **模提示**: 本质上归约为完美提示处理

### "Too Many Hints" 制度
- n 个线性无关的 mod-q 提示 → 高斯消元即可求解（平凡上界）
- 实际只需 k ≈ 0.9n 个 mod-q 提示 → LLL 归约即可恢复密钥
- 完美提示更强: k ≈ n/2 个即可

## 实验结果

| 方案 | 维度 n | mod-q 提示 k | mod-q 时间 | 完美提示 k | 完美时间 |
|------|-------|-------------|-----------|-----------|---------|
| Kyber-512 | 512 | 449 (88%) | 20 min | 234 (46%) | 3 h |
| Falcon-512 | 512 | 452 (88%) | 20 min | 233 (46%) | 3 h |
| NTRU-HRSS | 701 | 622 (89%) | 45 min | 332 (47%) | 11 h |
| Kyber-768 | 768 | 702 (91%) | 35 min | 390 (51%) | 1 day |
| Dilithium-1024 | 1024 | 876 (85%) | 10 h | 463 (45%) | 7 days |

### 关键发现
- **Kyber-512**: 仅需 449 个 mod-q 提示（占 88%），20 分钟内 LLL 恢复密钥
- **完美提示仅需 n/2**: 234 个完美提示即可恢复 Kyber-512 密钥——"这个数量相当惊人！"
- **mod-q 提示 k≈0.9n**: 剩余维度 n-k≈0.1n（约 60-66），LLL 可解
- **Dilithium-1024**: 大 q 允许最大剩余维度 n-k=148

## 与已有工作的对比

| 维度 | DDGR [CRYPTO 2020] | 本文 MN [Asiacrypt 2023] |
|------|-------------------|------------------------|
| 格基构造 | 逐步（计算密集） | 一次处理（高效） |
| 大提示量 | 不可行 | 可行（密码学维度） |
| 理论估计 | 有 | 有 + 实验验证 |
| LLL 可解性 | 仅估计 | 实际验证 |

## 被后续工作引用和改进
- [[raw/paper-cao2025-refined-attack]] (Cao 2025, CRYPTO): 用高斯消元进一步加速，Kyber-512 从 7h 降至 1h
- [[raw/paper-hermelink2025-generic-framework]] (Hermelink 2025): 将 MN 的方法与分布提示框架结合

## 核心结论

1. 首次在密码学维度下实际执行 LWE with hints 攻击（而非仅估计）
2. "Too many hints" 制度定义明确: mod-q ≈0.9n, perfect ≈n/2
3. 完美提示在实践中极为强大——仅需 46% 的提示即可用 LLL 恢复密钥
4. 强调了保护格基密码方案免受密钥泄漏的重要性
