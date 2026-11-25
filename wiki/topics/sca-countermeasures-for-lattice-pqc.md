# 主题综述：格基 PQC 的侧信道防护全景

> **类型**: topic
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ravi2024-defeating-lcc]]

## 摘要

本文档综合分析后量子格基密码（以 Kyber KEM 为代表）面临的侧信道攻击威胁及防护措施全景，涵盖从攻击分类到防护评估的完整图景。

## 攻击全景

```
                    Kyber KEM 解封装 SCA
                           │
              ┌────────────┴────────────┐
           KC-SCA                    CC-SCA
           (合法密文)               (选择密文)
              │                        │
    ┌─────────┴────────┐     ┌────────┬────────┬────────┐
    │                  │     │        │        │        │
  模板攻击           CPA   PC Oracle FD Oracle DF Oracle 合法密文CC
  (INTT/逐点乘)     (多迹)  (二进制区分)(≈10迹)(6500-7000)(本文·新颖)
```

## 防护全景

| 防护类型 | 防护对象 | 成本 | 本文结论 |
|---------|---------|------|---------|
| 掩码 (Masking) | 多项式乘法泄漏 | 高 | 增加成本但不阻止 |
| 洗牌 (Shuffling) | 操作顺序 | 中 | 增加成本但不阻止 |
| 密文完整性检查 | 低熵恶意密文 | ≈5% | ✓ 可被公钥掩码绕过 |
| 解封装失败检查 | 无效密文 | 极低 | ✓ 可被合法密文 CC-SCA 绕过 |
| 掩码+洗牌组合 | 综合 | 很高 | 增加成本但不阻止 |

## 核心问题：低成本检测型防护的脆弱性

### 设计者视角
- 标准防护（掩码+洗牌）成本高昂，资源受限平台难以承受
- 低成本检测型防护（完整性检查、失败检查）看似经济高效
- 但本文证明它们不能提供独立防护

### 攻击者视角
- 公钥掩码：几乎零成本绕过完整性检查（成功率 57.8%，平均 1.73 次）
- 合法密文攻击：从根本上绕过失败检查
- 贪心求解器：使不等式密钥恢复效率翻倍

### 关键研究空白
1. ~~**Dilithium 签名方案的类似分析**~~: **已填补** — 见下方 Dilithium SCA/FIA 攻击面
2. **更强检测型防护**：如何设计能抵抗公钥掩码的完整性检查？
3. **合法密文攻击的扩展**：是否还有其他操作可被合法密文攻击利用？
4. **硬件实现分析**：Raj 2024 已实现 ML-DSA 硬件掩码 [[raw/paper-raj2024-mldsa-hardware-masking]]
5. **组合防护的最优配置**：检测+掩码+洗牌的成本-安全最优组合？

## 本文在知识库中的位置

本文是**低成本防护措施安全性分析**的里程碑工作：
- 首次系统分析检测型防护 vs CC-SCA
- 首个合法密文 CC-SCA（模糊 KC/CC 边界）
- 新型贪心求解器（超越 BP 范式）

## 更新：格约减攻击路线（2026-08-05 增量）

知识库新增 4 篇论文后，防护全景需扩展为两条攻击路线的交叉视角：

### 贝叶斯更新路线（本文 Ravi 2024 所属）
- **求解器演进**: BP [PP21, Del22] → 贪心 [Ravi 2024] → 统一框架 [Hermelink 2025]
- **关键修正**: Hermelink 2025 证明贪心是 BP 的近似（非简单优于），两者互补
- **最新改进**: Hermelink 的分布提示框架可将 Ravi 攻击的信息需求减少 >2×

### 格约减路线（新增）
- **框架演进**: DDGR [CRYPTO 2020] → MN "too many hints" [Asiacrypt 2023] → Cao 高斯消元 [CRYPTO 2025]
- **直接低维格**: Li 2025 用 Hertzbleed 模提示直接构造低维格，400 秒恢复简化 Kyber 密钥
- **攻击门槛**: mod-q 需 0.9n 提示，perfect 需 n/2 提示即可用 LLL 恢复
- 详见 [[topics/lattice-reduction-attacks-on-lwe]]

### 两条路线的交叉影响
- 格约减路线的**确定性提示**（完美、模）可通过格约减高效处理
- 贝叶斯路线的**概率性提示**（分布、HW 泄漏）需 BP/贪心
- Hermelink 2025 提出 BP 输出可集成到 primal attack 格——**两条路线可结合**
- **防护启示**: 需同时防御确定性泄漏（防止格约减攻击）和概率性泄漏（防止贝叶斯攻击）

## 更新：NTT/Dilithium/故障注入攻击路线（2026-08-06 增量）

知识库新增 16 篇 SCA/FIA 论文后，防护全景进一步扩展：

### NTT 攻击演进路线
- **奠基** [[raw/paper-primas2017-single-trace-lattice]]: 首个 NTT 单迹攻击 (CHES 2017)
- **实用化** [[raw/paper-pessl2019-practical-ntt]]: 常时间实现，213 模板 (LATINCRYPT 2019)
- **洗牌突破** [[raw/paper-hermelink2022-bp-shuffling-ntt]]: shuffle node + BP (TCHES 2023)
- **不完整 NTT 弱点** [[raw/paper-bock2023-breaking-dpa-kyber]]: pair-pointwise mult (ACNS 2024)
- **SIS 辅助** [[raw/paper-qiao2023-ntt-meets-sis]]: 32-64 系数即可恢复 (2023)
- **盲 SCA** [[raw/paper-ravi2024-blind-sca-kyber]]: 无需密文 (ICCAD 2023)
- **CC-SCA + 洗牌突破** [[raw/paper-zhang2025-cc-sca-shuffled-kyber]]: MLP 97% 分类 (2025)
- 详见 [[concepts/ntt-side-channel-attacks]]

### Dilithium SCA/FIA 路线（填补知识空白）
- **单迹 DL 攻击** [[raw/paper-wang2023-single-trace-dilithium]]: DL 辅助模板，9% 单迹 (2023)
- **高效单迹** [[raw/paper-wang2024-single-trace-dilithium]]: CNN+线性回归，60% 单迹 (2024)
- **掩码 ML-DSA 攻击** [[raw/paper-hermelink2025-masked-mldsa-attack]]: y 是最薄弱环节 (CRYPTO 2025)
- **高阶掩码 gadgets** [[raw/paper-coron2023-masked-dilithium-gadgets]]: ShiftMod+布尔转换 (TCHES 2023)
- **硬件掩码** [[raw/paper-raj2024-mldsa-hardware-masking]]: 首个 ML-DSA 硬件 (2024)
- **NTT 故障** [[raw/paper-ravi2022-fiddling-twiddle-ntt]]: twiddle 常数 EMFI (2022)
- **Keccak 故障** [[raw/paper-wang2024-keccak-fault]]: SHA-3 循环中止 (2024)

### 故障注入路线
- **NTT FI** [[raw/paper-ravi2022-fiddling-twiddle-ntt]]: EMFI 修改 twiddle 常数
- **洗牌绕过** [[raw/paper-jendral2023-single-trace-masked-kyber]]: VFI + DL 组合
- **Keccak FI** [[raw/paper-wang2024-keccak-fault]]: 循环中止故障，6 策略→8+7 攻击
- 详见 [[concepts/fault-injection]]

### 深度学习 SCA 路线
- **CNN 模板** [[raw/paper-wang2024-single-trace-dilithium]]: cs1 恢复 74%
- **MLP 分类** [[raw/paper-zhang2025-cc-sca-shuffled-kyber]]: HW 分类 97.11%
- **DL+VFI 组合** [[raw/paper-jendral2023-single-trace-masked-kyber]]: 突破掩码+洗牌
- **AdaBoost** [[raw/paper-fouque2025-avengers]]: CBD 采样器系数恢复
- 详见 [[concepts/deep-learning-sca]]

### 综述参考
- [[raw/paper-ravi2022-sca-fia-survey]]: 最全面的 SCA/FIA 系统性综述 (ACM TECS 2024)

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/ravi-research-group]], [[entities/pqm4-library]], [[entities/dilithium]], [[entities/nttru]], [[entities/hertzbleed]]
- 相关概念: [[concepts/sca-classification-kc-vs-cc]], [[concepts/oracle-attacks-pc-fd-df]], [[concepts/ciphertext-sanity-check]], [[concepts/decapsulation-failure-check]], [[concepts/greedy-solver]], [[concepts/masking-and-shuffling]], [[concepts/lwe-hints-framework]], [[concepts/lattice-reduction]], [[concepts/modular-hints]], [[concepts/distribution-hints]], [[concepts/ntt-side-channel-attacks]], [[concepts/fault-injection]], [[concepts/deep-learning-sca]]
- 参见: [[topics/comparison-ravi2024-vs-prior-work]], [[topics/lattice-reduction-attacks-on-lwe]]

## 引用来源
- [1] [[raw/paper-ravi2024-defeating-lcc]] — 综述基础
- [2] [RCDB22] 防护措施综述
- [3] [BGR+21] 掩码 Kyber
- [4] [HKL+22] mkm4 掩码库
- [5] [[raw/paper-hermelink2025-generic-framework]] — 分布提示统一框架（贪心/BP 互补）
- [6] [[raw/paper-may2023-too-many-hints]] — 格约减攻击门槛
- [7] [[raw/paper-cao2025-refined-attack]] — 高斯消元改进
- [8] [[raw/paper-li2025-hertzbleed-hints]] — Hertzbleed + 低维格
- [9] [[raw/paper-ddgr2020-lwe-side-info]] — LWE with Hints 奠基框架
- [10] [[raw/paper-dachman2023-geometric]] — 几何视角扩展
- [11] [[raw/paper-fouque2025-avengers]] — CBD 采样器攻击（密钥生成阶段新攻击面）
- [12] [[raw/paper-hhan2025-perfect-to-approx]] — 稀疏秘密 O(h log²h) 阈值（FHE 防护启示）
- [13] [[raw/paper-primas2017-single-trace-lattice]] — NTT 单迹攻击奠基 (CHES 2017)
- [14] [[raw/paper-pessl2019-practical-ntt]] — 实用化 NTT 攻击 (LATINCRYPT 2019)
- [15] [[raw/paper-hermelink2022-bp-shuffling-ntt]] — BP 突破洗牌 (TCHES 2023)
- [16] [[raw/paper-ravi2022-sca-fia-survey]] — SCA/FIA 综述 (ACM TECS 2024)
- [17] [[raw/paper-ravi2022-fiddling-twiddle-ntt]] — NTT 故障注入 (2022)
- [18] [[raw/paper-bock2023-breaking-dpa-kyber]] — 不完整 NTT 弱点 (ACNS 2024)
- [19] [[raw/paper-jendral2023-single-trace-masked-kyber]] — VFI+DL 组合 (HOST 2024)
- [20] [[raw/paper-qiao2023-ntt-meets-sis]] — SIS 辅助恢复 (2023)
- [21] [[raw/paper-ravi2024-blind-sca-kyber]] — 盲 SCA (ICCAD 2023)
- [22] [[raw/paper-zhang2025-cc-sca-shuffled-kyber]] — CC-SCA 突破洗牌 (2025)
- [23] [[raw/paper-wang2023-single-trace-dilithium]] — Dilithium DL 单迹 (2023)
- [24] [[raw/paper-wang2024-single-trace-dilithium]] — Dilithium 高效单迹 (2024)
- [25] [[raw/paper-hermelink2025-masked-mldsa-attack]] — 掩码 ML-DSA 攻击 (CRYPTO 2025)
- [26] [[raw/paper-coron2023-masked-dilithium-gadgets]] — Dilithium 掩码 gadgets (TCHES 2023)
- [27] [[raw/paper-raj2024-mldsa-hardware-masking]] — ML-DSA 硬件掩码 (2024)
- [28] [[raw/paper-wang2024-keccak-fault]] — Keccak 故障攻击 (2024)

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-ravi2024-defeating-lcc]]
- 2026-08-05: 更新——添加 DDGR 和几何视角两篇奠基论文来源
- 2026-08-05: 更新——添加 Fouque (CBD 采样器新攻击面) 和 Hhan (FHE 稀疏秘密) 来源
- 2026-08-06: 大幅更新——添加 16 篇 SCA/FIA 论文，新增 NTT 攻击/Dilithium SCA/故障注入/DL SCA 四条攻击路线，填补 Dilithium 知识空白
