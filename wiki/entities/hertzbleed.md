# Hertzbleed 侧信道攻击

> **类型**: entity
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-li2025-hertzbleed-hints]]

## 摘要

Hertzbleed 是一种将功率侧信道转化为远程时序侧信道的攻击方法，利用现代 CPU 的动态电压频率调节（DVFS）机制。通过观察 DVFS 引起的频率变化（而非直接测量功率），攻击者可以远程提取密钥信息。

## 详情

### 攻击原理
- **DVFS**: 现代 CPU 的节能机制，根据负载调整时钟频率
- **数据依赖**: NTT 处理低 HW 或随机 HW 数据时，CPU 功耗/频率变化不同
- **频率侧信道**: 将功率泄漏转化为频率泄漏，可远程观测
- **区分能力**: 单非零系数 vs 多非零系数的多项式输入可被区分

### 在格基密码中的攻击
- **Yu et al. (CHES 2024)**: 首次将 Hertzbleed 应用于 NTT，提取模提示 `NTT(s)∘NTT(u)` 的分量值
- **Li et al. (TCHES 2025)** [[raw/paper-li2025-hertzbleed-hints]]: 改进 Yu 的工作，直接用模提示构造低维格

### 获取的信息类型
- **模提示 (Modular Hints)**: `NTT(s)[i] · NTT(u)[i] mod q` 的值
- NTT(u) 已知（公钥相关），因此可推断 NTT(s) 的部分信息
- 对应于 [[concepts/lwe-hints-framework]] 中的 mod-q hint

### 历史
- 最初攻击 SIKE [JAC+20]（已被 NIST 淘汰）
- 扩展到 AES [LCCR22]
- 软件 DVFS 攻击 [DG22]
- 格基密码 NTT 攻击 [YCY+24] (CHES 2024)

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/nttru]]
- 相关概念: [[concepts/modular-hints]], [[concepts/lwe-hints-framework]]
- 参见: [[topics/lattice-reduction-attacks-on-lwe]]

## 引用来源
- [1] [[raw/paper-li2025-hertzbleed-hints]] — Hertzbleed 在格基密码中的应用
- [2] [WPH+22] Hertzbleed 原始论文
- [3] [YCY+24] CHES 2024 NTT Hertzbleed 攻击

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-li2025-hertzbleed-hints]]
