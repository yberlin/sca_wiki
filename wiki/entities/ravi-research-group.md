# Prasanna Ravi 研究团队

> **类型**: entity
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ravi2024-defeating-lcc]]

## 摘要

由 Prasanna Ravi（南洋理工大学 Temasek Laboratories）领衔的侧信道与格基密码研究团队，活跃于后量子密码的侧信道攻击与防护研究，在 TCHES 等顶级期刊发表多篇关于 Kyber KEM SCA 的工作。

## 详情

### 核心成员
- **Prasanna Ravi** — Temasek Laboratories, Nanyang Technological University, Singapore
- **Thales Paiva** — Fundep, Belo Horizonte, Brazil; CASNAV, Rio de Janeiro, Brazil
- **Dirmanto Jap** — Temasek Laboratories, NTU Singapore
- **Jan-Pieter D'Anvers** — imec-COSIC, KU Leuven, Belgium (FWO 博士后)
- **Shivam Bhasin** — Temasek Laboratories, NTU Singapore

### 主要研究贡献

1. **低成本防护措施分析** [RCDB22]: 首次系统综述格基 PQC（Kyber, Dilithium）的 SCA 与故障注入攻击
2. **CC-based SCA 攻击** [RRCB20]: 通用 CC-SCA 框架，PC oracle 攻击
3. **公钥掩码绕过完整性检查** [本论文]: 用公钥掩码绕过密文熵检测
4. **合法密文 CC-SCA** [本论文]: 首个仅用合法密文的 CC-SCA
5. **贪心求解器** [本论文]: 优于 BP 的线性不等式密钥恢复求解器
6. **SCA/FIA 综述** [[raw/paper-ravi2022-sca-fia-survey]]: 格基 PQC SCA/FIA 最全面综述 (ACM TECS 2024)
7. **NTT 故障注入** [[raw/paper-ravi2022-fiddling-twiddle-ntt]]: 首个 NTT EMFI 分析 (2022)
8. **盲 SCA** [[raw/paper-ravi2024-blind-sca-kyber]]: 首个无需密文的 Kyber SCA (ICCAD 2023)
9. **ML-DSA 硬件掩码** [[raw/paper-raj2024-mldsa-hardware-masking]]: 首个受保护 ML-DSA 硬件 (2024)

### 相关论文链
- [RRCB20] Generic side-channel attacks on CCA-secure lattice-based PKE and KEMs (TCHES 2020)
- [RCDB22] Side-channel and fault-injection attacks over lattice-based post-quantum schemes (ACM TECS 2022)
- [RRD+23] Pushing the limits of generic SCA on LWE-based KEMs (TCHES 2023)
- [本论文] Defeating low-cost countermeasures (TCHES 2024)
- [[raw/paper-ravi2022-sca-fia-survey]] SCA/FIA 综述 (ePrint 2022/737)
- [[raw/paper-ravi2022-fiddling-twiddle-ntt]] NTT 故障注入 (ePrint 2022/824)
- [[raw/paper-ravi2024-blind-sca-kyber]] 盲 SCA (ePrint 2024/169)
- [[raw/paper-raj2024-mldsa-hardware-masking]] ML-DSA 硬件掩码 (ePrint 2024/1817)

### 开源工具
- https://github.com/thalespaiva/sca_on_kyber_lcc — 本文攻击软件

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/dilithium]], [[entities/pqm4-library]]
- 相关概念: [[concepts/sca-classification-kc-vs-cc]], [[concepts/oracle-attacks-pc-fd-df]], [[concepts/ntt-side-channel-attacks]], [[concepts/fault-injection]]
- 参见: [[topics/sca-countermeasures-for-lattice-pqc]]

## 引用来源
- [1] [[raw/paper-ravi2024-defeating-lcc]] — 作者信息与研究贡献
- [2] [[raw/paper-ravi2022-sca-fia-survey]] — SCA/FIA 综述
- [3] [[raw/paper-ravi2022-fiddling-twiddle-ntt]] — NTT 故障注入
- [4] [[raw/paper-ravi2024-blind-sca-kyber]] — 盲 SCA
- [5] [[raw/paper-raj2024-mldsa-hardware-masking]] — ML-DSA 硬件掩码

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-ravi2024-defeating-lcc]]
- 2026-08-06: 大幅更新——添加 Ravi 团队 4 篇新论文（综述、NTT FI、盲 SCA、硬件掩码），扩展研究贡献至 9 项
