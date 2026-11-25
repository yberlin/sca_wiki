# Wiki 索引

> 总页面数: 28 | 最后更新: 2026-11-24

## 按类型

### 实体 (6)
- [[entities/kyber-kem]] — CRYSTALS-Kyber KEM (ML-KEM)，NIST 标准化的后量子密钥封装机制
- [[entities/dilithium]] — CRYSTALS-Dilithium (ML-DSA)，基于 MLWE 的后量子签名方案
- [[entities/nttru]] — NTTRU，基于 NTRU 假设的 NTT 友好加密方案
- [[entities/hertzbleed]] — Hertzbleed，将功率侧信道转化为远程频率侧信道的攻击方法
- [[entities/ravi-research-group]] — Prasanna Ravi 领衔的格基密码 SCA 研究团队
- [[entities/pqm4-library]] — ARM Cortex-M4 上的后量子密码实现库

### 概念 (15)
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
- [[concepts/ntt-side-channel-attacks]] — NTT 侧信道攻击：从 Primas 2017 到 Zhang 2025 的演进
- [[concepts/fault-injection]] — 故障注入攻击：8 大类分类（FO 变换/NTT/Keccak/验证/随机数/洗牌/DFA/Hedged）
- [[concepts/deep-learning-sca]] — 深度学习侧信道攻击：CNN/MLP/AdaBoost 方法

### 主题 (3)
- [[topics/sca-countermeasures-for-lattice-pqc]] — 格基 PQC 的侧信道防护全景综述
- [[topics/comparison-ravi2024-vs-prior-work]] — Ravi 2024 与已有 CC-SCA 工作的对比分析
- [[topics/lattice-reduction-attacks-on-lwe]] — 格约减攻击 LWE with Hints 全景

## 按来源

### 原始资料 (36)
#### 格约减攻击路线 (9)
- [[raw/paper-ddgr2020-lwe-side-info]] — "LWE with Side Information" (CRYPTO 2020) — **奠基论文**
- [[raw/paper-dachman2023-geometric]] — "Revisiting Security Estimation for LWE with Hints from a Geometric Perspective" (CRYPTO 2023)
- [[raw/paper-ravi2024-defeating-lcc]] — "Defeating Low-Cost Countermeasures against SCA in Lattice-based Encryption" (TCHES 2024)
- [[raw/paper-hermelink2025-generic-framework]] — "A Generic Framework for SCAs against LWE-based Cryptosystems" (2025)
- [[raw/paper-li2025-hertzbleed-hints]] — "Improved Attacks Against Lattice-Based KEMs Using Hints From Hertzbleed" (TCHES 2025)
- [[raw/paper-cao2025-refined-attack]] — "Refined Attack on LWE with Hints" (CRYPTO 2025)
- [[raw/paper-may2023-too-many-hints]] — "Too Many Hints – When LLL Breaks LWE" (Asiacrypt 2023)
- [[raw/paper-fouque2025-avengers]] — "Avengers assemble! Supervised learning meets lattice reduction" (TCHES 2025) — **CBD 采样器攻击**
- [[raw/paper-hhan2025-perfect-to-approx]] — "From Perfect to Approximate Hints" (IEEE S&P 2026) — **稀疏秘密 O(h log²h)**

#### NTT 侧信道攻击路线 (7)
- [[raw/paper-primas2017-single-trace-lattice]] — "Single-Trace SCA on Masked Lattice-Based Encryption" (CHES 2017) — **NTT 单迹攻击奠基**
- [[raw/paper-pessl2019-practical-ntt]] — "More Practical Single-Trace Attacks on the NTT" (LATINCRYPT 2019)
- [[raw/paper-hermelink2022-bp-shuffling-ntt]] — "Adapting BP to Counter Shuffling of NTTs" (TCHES 2023)
- [[raw/paper-bock2023-breaking-dpa-kyber]] — "Breaking DPA-Protected Kyber via Pair-Pointwise Multiplication" (ACNS 2024)
- [[raw/paper-qiao2023-ntt-meets-sis]] — "When NTT Meets SIS: Efficient SCA on Dilithium and Kyber" (2023)
- [[raw/paper-ravi2024-blind-sca-kyber]] — "ML-based Blind SCA on PQC-based KEMs" (ICCAD 2023)
- [[raw/paper-zhang2025-cc-sca-shuffled-kyber]] — "CC-SCA on Shuffled CRYSTALS-Kyber" (2025)

#### Dilithium SCA 与防护 (4)
- [[raw/paper-wang2023-single-trace-dilithium]] — "Single-Trace SCA on CRYSTALS-Dilithium: Myth or Reality?" (2023)
- [[raw/paper-wang2024-single-trace-dilithium]] — "Single Trace is All It Takes: Efficient SCA on Dilithium" (2024)
- [[raw/paper-hermelink2025-masked-mldsa-attack]] — "Finding and Protecting the Weakest Link in Masked ML-DSA" (CRYPTO 2025)
- [[raw/paper-coron2023-masked-dilithium-gadgets]] — "Improved Gadgets for High-Order Masking of Dilithium" (TCHES 2023)

#### 故障注入攻击 (14)
- [[raw/paper-bruinderink2018-dfa-deterministic-lattice]] — "Differential Fault Attacks on Deterministic Lattice Signatures" (TCHES 2018) — **格签名 FI 奠基**
- [[raw/paper-pessl2021-fault-cca-kem]] — "Fault Attacks on CCA-secure Lattice KEMs" (TCHES 2021) — **格 KEM FI 奠基**
- [[raw/paper-hermelink2021-fault-cc-kyber]] — "Fault-Enabled CC Attacks on Kyber" (INDOCRYPT 2021) — **FI+CC 组合**
- [[raw/paper-delvaux2022-roulette]] — "Roulette: Diverse Fault Attacks on Masked Kyber" (TCHES 2022) — **掩码反直觉**
- [[raw/paper-ravi2022-fiddling-twiddle-ntt]] — "Fiddling the Twiddle Constants — NTT FI" (2022) — **NTT FI**
- [[raw/paper-jendral2023-single-trace-masked-kyber]] — "Single-Trace on Masked+Shuffled Kyber" (HOST 2024) — **FI+DL 组合**
- [[raw/paper-elghamrawy2023-mlwe-to-rlwe]] — "From MLWE to RLWE: DFA on Dilithium" (TCHES 2023) — **MLWE→RLWE 降维**
- [[raw/paper-wang2024-keccak-fault]] — "Beware of Keccak: Fault Attacks on SHA-3" (2024) — **Keccak FI**
- [[raw/paper-bauer2024-fault-resistant-ntt]] — "A Fault-Resistant NTT" (TCHES 2024) — **NTT FI 防护**
- [[raw/paper-krahmer2024-correction-fault-dilithium]] — "Correction Fault Attacks on Randomized Dilithium" (TCHES 2024) — **校正故障**
- [[raw/paper-jendral2024-hedged-dilithium-fi]] — "Single Trace FI on Hedged Dilithium" (FDTC 2024) — **Hedged 单迹**
- [[raw/paper-mishra2024-probabilistic-fault-countermeasure]] — "Probabilistic Algorithms for Countering FI" (2024) — **概率化防护**
- [[raw/paper-bauer2025-forging-dilithium-falcon]] — "Forging Dilithium and Falcon by Single FI" (FDTC 2023) — **验证绕过**
- [[raw/paper-valsaraj2025-randomness-fault-pqc]] — "When Randomness Isn't Random: FI on PQ Standards" (2025) — **种子指针**

#### 综述与硬件 (2)
- [[raw/paper-ravi2022-sca-fia-survey]] — "SCA and FIA over Lattice-based PQC (Kyber, Dilithium): Survey" (ACM TECS 2024) — **最全面综述**
- [[raw/paper-raj2024-mldsa-hardware-masking]] — "Improved ML-DSA Hardware with First-Order Masking" (2024)
