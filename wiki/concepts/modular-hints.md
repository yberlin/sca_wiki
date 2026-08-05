# 模提示（Modular Hints）

> **类型**: concept
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ddgr2020-lwe-side-info]], [[raw/paper-may2023-too-many-hints]], [[raw/paper-li2025-hertzbleed-hints]]

## 摘要

模提示是 LWE with Hints 框架中的一种提示类型，形式为 `⟨v, s⟩ ≡ l (mod m)`。当 m=q 时称为 mod-q 提示，在 NTT-based 方案中自然产生（NTT 后值已 mod q）。模提示的集成极其高效——k 个 mod-q 提示直接将 LWE 维度从 n 降至 n-k。

## 详情

### 定义
- **模提示**: `⟨v, x⟩ = l mod m`（x 为密钥，v 为已知向量，l 为标量）
- **mod-q 提示**: `⟨v, x⟩ = l mod q`（在 Z_q 中操作）
- **信息量**: 每个模提示减少 1 维子空间

### 来源
- **Hertzbleed 攻击**: `NTT(s)[i] · NTT(u)[i] mod q` 的值
  - NTT(u) 已知 → 推断 NTT(s) 部分信息
  - [[raw/paper-li2025-hertzbleed-hints]]: 256/384/512 个 mod-q 提示（Kyber512/768/1024）
- **NTT 前泄漏**: 若在 mod q 归约前泄漏 → 完美提示（更强）

### 集成方法

| 方法 | 描述 | 效率 |
|------|------|------|
| DDGR | 逐步集成到 [[concepts/dbdd|DBDD]] | 慢 |
| MN | 线性代数直接降维 | 极快（秒级） |
| Cao | REF 归约批量处理 | 快 |

### MN 的线性代数方法
- k 个 mod-q 提示 → LWE 维度 n → n-k
- 构造格基: 秒级完成（n=512 仅需秒）
- 剩余维度 n-k 若足够小（~60-66）→ LLL 即可恢复

### "Too Many Hints" 制度 (mod-q)
- **门槛**: k ≈ 0.9n
- **Kyber-512**: 449 提示 → 20 min LLL
- **Dilithium-1024**: 876 提示 → 10 h LLL
- 大 q 的方案（Dilithium）允许更大剩余维度

### 与完美提示的对比
- 完美提示 `⟨v, x⟩ = l`（精确值，未 mod q）信息量更大
- 完美提示门槛 k ≈ n/2（仅需 46%）
- mod-q 需 k ≈ 0.9n（需 88-91%）

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/hertzbleed]], [[entities/nttru]]
- 相关概念: [[concepts/lwe-hints-framework]], [[concepts/lattice-reduction]], [[concepts/dbdd]]
- 参见: [[topics/lattice-reduction-attacks-on-lwe]]

## 引用来源
- [1] [[raw/paper-ddgr2020-lwe-side-info]] — 模提示的原始定义
- [2] [[raw/paper-may2023-too-many-hints]] — mod-q 提示的线性代数方法
- [3] [[raw/paper-li2025-hertzbleed-hints]] — Hertzbleed 产生的 mod-q 提示

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-may2023-too-many-hints]]
- 2026-08-05: 更新——添加 DDGR raw 页面引用和 DBDD 概念链接
