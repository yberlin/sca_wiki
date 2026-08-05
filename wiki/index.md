# Wiki 索引

> 总页面数: 25 | 最后更新: 2026-08-05

## 按类型

### 实体 (6)
- [[entities/kyber-kem]] — CRYSTALS-Kyber KEM (ML-KEM)，NIST 标准化的后量子密钥封装机制
- [[entities/dilithium]] — CRYSTALS-Dilithium (ML-DSA)，基于 MLWE 的后量子签名方案
- [[entities/nttru]] — NTTRU，基于 NTRU 假设的 NTT 友好加密方案
- [[entities/hertzbleed]] — Hertzbleed，将功率侧信道转化为远程频率侧信道的攻击方法
- [[entities/ravi-research-group]] — Prasanna Ravi 领衔的格基密码 SCA 研究团队
- [[entities/pqm4-library]] — ARM Cortex-M4 上的后量子密码实现库

### 概念 (12)
- [[concepts/sca-classification-kc-vs-cc]] — 侧信道攻击分类：已知密文 vs 选择密文
- [[concepts/oracle-attacks-pc-fd-df]] — 三种 Oracle 攻击：PC / FD / DF
- [[concepts/ciphertext-sanity-check]] — 密文完整性检查防护
- [[concepts/decapsulation-failure-check]] — 解封装失败检查防护
- [[concepts/greedy-solver]] — 贪心求解器用于线性不等式密钥恢复
- [[concepts/masking-and-shuffling]] — 掩码与洗牌防护
- [[concepts/lwe-hints-framework]] — LWE with Hints 框架：DDGR → 几何扩展 → MN → Cao → Fouque → Hhan 演进
- [[concepts/modular-hints]] — 模提示：mod-q 提示的线性代数降维
- [[concepts/lattice-reduction]] — 格约减攻击：LLL 与 BKZ
- [[concepts/distribution-hints]] — 分布提示：统一概率信息的提示类型
- [[concepts/dbdd]] — DBDD（畸变有界距离解码）：LWE→uSVP 的中间问题
- [[concepts/sparse-secret-lwe]] — 稀疏三值秘密 LWE：O(h log²h) 提示恢复阈值

### 主题 (3)
- [[topics/sca-countermeasures-for-lattice-pqc]] — 格基 PQC 的侧信道防护全景综述
- [[topics/comparison-ravi2024-vs-prior-work]] — Ravi 2024 与已有 CC-SCA 工作的对比分析
- [[topics/lattice-reduction-attacks-on-lwe]] — 格约减攻击 LWE with Hints 全景

## 按来源

### 原始资料 (9)
- [[raw/paper-ddgr2020-lwe-side-info]] — "LWE with Side Information: Attacks and Concrete Security Estimation" (CRYPTO 2020) — **奠基论文**
- [[raw/paper-dachman2023-geometric]] — "Revisiting Security Estimation for LWE with Hints from a Geometric Perspective" (CRYPTO 2023)
- [[raw/paper-ravi2024-defeating-lcc]] — "Defeating Low-Cost Countermeasures against SCA in Lattice-based Encryption" (TCHES 2024)
- [[raw/paper-hermelink2025-generic-framework]] — "A Generic Framework for SCAs against LWE-based Cryptosystems" (2025)
- [[raw/paper-li2025-hertzbleed-hints]] — "Improved Attacks Against Lattice-Based KEMs Using Hints From Hertzbleed" (TCHES 2025)
- [[raw/paper-cao2025-refined-attack]] — "Refined Attack on LWE with Hints" (CRYPTO 2025)
- [[raw/paper-may2023-too-many-hints]] — "Too Many Hints – When LLL Breaks LWE" (Asiacrypt 2023)
- [[raw/paper-fouque2025-avengers]] — "Avengers assemble! Supervised learning meets lattice reduction" (TCHES 2025) — **CBD 采样器攻击**
- [[raw/paper-hhan2025-perfect-to-approx]] — "From Perfect to Approximate Hints: Efficient LWE Secret Recovery Leveraging Low Hamming Weight" (IEEE S&P 2026) — **稀疏秘密 O(h log²h)**
