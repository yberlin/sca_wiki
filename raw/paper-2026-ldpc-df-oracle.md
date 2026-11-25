# Unlocking the True Potential of Decryption Failure Oracles: Hybrid Adaptive LDPC Attack against ML-KEM

> **作者**: (ePrint 2026/070, 2026)
> **URL**: https://eprint.iacr.org/2026/070
> **类型**: ML-KEM CC-SCA — DF oracle + LDPC 信念传播混合攻击

## 摘要

本文重新审视利用**解密失败（DF）预言机**对 ML-KEM 的选择密文侧信道攻击。DF oracle 传统上被认为不如二进制 PC oracle 高效，本文证明其全部潜力尚未挖掘：提出将**自适应查询生成**与**低密度奇偶校验码（LDPC）信念传播**相结合的新攻击框架，在多个秘密系数上精心设计平衡的奇偶校验，最大化每次 oracle 查询提取的香农信息，且对大量噪声鲁棒。对于准确率 95% 的 ML-KEM-768，仅需 2950 次查询即可完全密钥恢复（与香农下界之比仅 1.35），**效率超越最先进的二进制 PC 攻击**。框架应用于 GoFetch 微架构侧信道场景后，所需测量迹数降低一个数量级以上，并消除昂贵的格约减后处理，使此前难以处理的更高安全级别方案也可被完全攻破。

## 核心贡献

### 1. DF oracle 效率翻案
- 传统认知：DF oracle < PC oracle（格方案中）
- 本文：精心设计的 LDPC 奇偶校验 + 自适应查询 → **超越 SOTA 二进制 PC 攻击**

### 2. 接近香农界
- ML-KEM-768（oracle 准确率 95%）：2950 次查询完全恢复，查询数/香农下界 = 1.35
- 多系数平衡奇偶校验：每次查询榨取最多信息

### 3. 噪声鲁棒性
- oracle 有大量错误（如微架构场景低 SNR）时依然有效
- LDPC BP 天然纠错

### 4. 实例化 GoFetch
- 微架构侧信道（Apple DMP）→ DF oracle 实例化
- 迹数需求 ↓ 一个数量级以上，去除格约减后处理
- 高安全级别方案（此前难处理）也被完全攻破

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击框架 | 自适应查询生成 + LDPC 信念传播 |
| oracle 类型 | 解密失败（DF）预言机 |
| ML-KEM-768 查询数 | 2950（95% 准确 oracle） |
| 香农效率 | 比率 1.35（接近理论下界） |
| 噪声容忍 | 高（LDPC 纠错） |
| 实例化 | GoFetch DMP 微架构泄漏 |
| 后处理 | 无需格约减（对比先前方法） |

## 与已有工作的关系

- **DF oracle 演进**: 知识库 oracle 概念页 [[concepts/oracle-attacks-pc-fd-df]] 记录 DF oracle 曾需 6500-7000 迹（Ravi 2024 实测），本文以信息论最优设计将其压至 2950 并反超 PC oracle——DF oracle 效率史首次登顶
- **BP 家族会师**: Hermelink 2022 的 Belief Propagation [[raw/paper-hermelink2022-bp-shuffling-ntt]] 用于 NTT 洗牌攻击，本文 LDPC BP 用于 oracle 查询设计——BP 从"求解器"扩展为"查询编码器"
- **GoFetch 实例化**: 将 [[raw/paper-chen2024-gofetch]] 的 DMP 泄漏从"逐系数提取+格约减"升级为"DF oracle+LDPC"，攻防两端都推向信息论极限
- **贪心 vs BP 矛盾调和**: 知识库已有"贪心 vs BP"矛盾标注 [[concepts/greedy-solver]]——本文再次证明 BP 家族在噪声场景的结构性优势（LDPC 纠错）
- **密钥不匹配攻击关联**: Guo 2024 (CIC 1(3)) 的自适应并行 mismatch 攻击与后处理格约减结合思路相通，均以"少量 oracle + 格后处理"压查询复杂度

## 关联
- Oracle 攻击概念: [[concepts/oracle-attacks-pc-fd-df]]
- GoFetch: [[raw/paper-chen2024-gofetch]]
- 贪心求解器（BP 对比）: [[concepts/greedy-solver]]
- LWE Hints 框架（后处理对比）: [[concepts/lwe-hints-framework]]
- 防护综述: [[topics/sca-countermeasures-for-lattice-pqc]]
- Kyber 实体: [[entities/kyber-kem]]
