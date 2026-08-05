# NTTRU 加密方案

> **类型**: entity
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-li2025-hertzbleed-hints]]

## 摘要

NTTRU 是 Lyubashevsky 和 Seiler 提出的基于 NTRU 假设的格基加密方案，使用 NTT 友好的环结构加速计算。其私钥具有特殊形式 `f = 3f' + 1`，这一结构可被攻击者利用。

## 详情

### 数学结构
- 基于 NTRU 假设（NTRU lattice: b = 0^m 的特殊情况）
- 使用 NTT 加速多项式乘法
- 私钥特殊形式: `f = 3f' + 1`

### 在侧信道研究中的位置
- [[raw/paper-li2025-hertzbleed-hints]]: 从 Hertzbleed 攻击获得模提示，利用私钥特殊形式构造 768 维格
- 高斯消元降维后，攻击复杂度从 Yu et al. (CHES 2024) 的 2^114 降至 **2^34**
- 由于维数高（768），需要比简化 Kyber（256）更强的格约减

### 参数
- n = 509 或 677
- [[raw/paper-cao2025-refined-attack]]: NTRU-509 需 226 个提示（too-many-hints），2.3 min
- [[raw/paper-cao2025-refined-attack]]: NTRU-677 需 325 个提示，3.8 min
- [[raw/paper-may2023-too-many-hints]]: NTRU-HRSS (n=701) 需 622 个 mod-q 或 332 个完美提示

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/dilithium]]
- 相关概念: [[concepts/lwe-hints-framework]], [[concepts/modular-hints]]
- 参见: [[topics/lattice-reduction-attacks-on-lwe]]

## 引用来源
- [1] [[raw/paper-li2025-hertzbleed-hints]] — NTTRU 的 Hertzbleed 攻击
- [2] [[raw/paper-cao2025-refined-attack]] — NTRU 的 too-many-hints 制度
- [3] [[raw/paper-may2023-too-many-hints]] — NTRU-HRSS 的提示需求

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-li2025-hertzbleed-hints]]
