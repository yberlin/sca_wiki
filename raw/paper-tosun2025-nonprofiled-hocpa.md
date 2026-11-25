# Non-Profiled Higher-Order Side-Channel Attacks against Lattice-Based Post-Quantum Cryptography

> **作者**: Tolun Tosun, Elisabeth Oswald, Erkay Savaş
> **发表**: IACR Communications in Cryptology 2(3) (2025)
> **URL**: https://eprint.iacr.org/2025/xxx（博士论文: Sabancı University 2025）
> **类型**: ML-KEM+ML-DSA SCA — 高阶非剖析攻击（突破高阶掩码）

## 摘要

本文提出针对格基密码（ML-DSA、ML-KEM）的**高阶非剖析侧信道攻击**方法，覆盖两种场景：设备泄漏符合汉明重量模型（已知泄漏）与未知泄漏。已知泄漏场景下开发高效高阶 CPA（HOCPA），关键在于**最优预测函数**的高效递归计算（格基密码中无闭式公式）；并引入 sin/cos 预测函数，证明其对二阶及以上掩码防护的 HOCPA 最优。在 Arm Cortex-M4 开源掩码实现上的实测：**二阶/三阶掩码 Dilithium 仅需 700/2400 条迹、Kyber 仅需 2200/14500 条迹即可完全恢复密钥**。未知泄漏场景下提出组合通用区分器与格约减的两步攻击（预测数从 q² 降至 q，运行时加速最高 23490 倍），首次实现对高阶掩码格实现的非剖析攻击。另有发现：**带符号算术引入符号依赖泄漏**这一独特脆弱性。

## 核心贡献

### 1. 最优预测函数高效计算
- 格基密码掩码（算术掩码+模约减）导致 HOCPA 最优预测函数无闭式解
- 提出递归计算方法；围绕零点中心化带符号模约减时有显式公式

### 2. sin/cos 预测函数
- 证明对二阶及以上掩码防护的 HOCPA 攻击最优
- 简洁且高效

### 3. 高阶掩码实现首次非剖析攻破
- 二阶掩码 Dilithium: 700 迹；三阶: 2400 迹
- 二阶掩码 Kyber: 2200 迹；三阶: 14500 迹
- 均在 Arm Cortex-M4 开源掩码实现上实测

### 4. 未知泄漏两步攻击
- 通用区分器 + 格约减结合
- 预测数 q² → q；实验显示比特丢弃（bit-dropping）对受保护格实现基本无效
- 运行时加速最高 23490×

### 5. 带符号算术脆弱性
- 带符号模约减使中间值符号与泄漏强相关——实现层面的新泄漏源

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击类别 | 非剖析（non-profiled，无需克隆设备）高阶 CPA |
| 目标防护 | 二阶/三阶算术掩码 |
| Dilithium 迹数 | 700（二阶）/ 2400（三阶） |
| Kyber 迹数 | 2200（二阶）/ 14500（三阶） |
| 平台 | Arm Cortex-M4 开源掩码实现 |
| 未知泄漏处理 | 通用区分器+格约减两步法 |
| bit-dropping 结论 | 对受保护实现基本无效 |

## 与已有工作的关系

- **掩码防护评估**: 知识库掩码页 [[concepts/masking-and-shuffling]] 记录一阶掩码被 Ravi 2024/Zhang 2025 等攻破；本文将打击面扩至**三阶掩码**且无需剖析——掩码阶数提升的边际防护价值被重新定价
- **格约减+SCA 组合**: 与 Qiao 2023 NTT+SIS [[raw/paper-qiao2023-ntt-meets-sis]] 同属"部分泄漏+格后处理"路线，本文扩展到未知泄漏模型
- **剖析攻击对比**: Wang/Jendral/Zhang 系列 [[concepts/deep-learning-sca]] 全部需要模板/克隆设备；本文+PTA(Zhao 2026) [[raw/paper-zhao2026-rejection-matters]] 代表 2025-2026"去剖析化"新趋势
- **Dilithium 高阶掩码成本**: Coron 2023 gadgets [[raw/paper-coron2023-masked-dilithium-gadgets]] 给出高阶掩码 gadget，本文实测三阶掩码 2400 迹即破——gadget 安全证明 ≠ 实现整体安全

## 关联
- 掩码防护概念: [[concepts/masking-and-shuffling]]
- Dilithium 实体: [[entities/dilithium]]
- Kyber 实体: [[entities/kyber-kem]]
- 格约减: [[concepts/lattice-reduction]]
- 深度学习 SCA（剖析路线对比）: [[concepts/deep-learning-sca]]
- 防护综述: [[topics/sca-countermeasures-for-lattice-pqc]]
