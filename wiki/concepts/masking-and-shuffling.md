# 掩码与洗牌防护（Masking & Shuffling）

> **类型**: concept
> **创建时间**: 2026-08-05
> **最后更新**: 2026-11-25
> **来源**: [[raw/paper-ravi2024-defeating-lcc]]

## 摘要

掩码和洗牌是针对 CC-SCA 的标准（高成本）防护措施。掩码将敏感中间值拆分为多个算术共享；洗牌随机化操作顺序。两者均可增加攻击复杂度，但本论文证明它们不能完全阻止合法密文 CC-SCA。

## 详情

### 掩码（Masking）
- **原理**: 将 m' 加性掩码为 d 个独立算术共享 (d-1 阶掩码)
- **实现**: mkm4 库 [HKL+22] 的一阶掩码 Kyber768
- **本文攻击适配**:
  - CPA 可检测到所有算术共享的系数泄漏
  - HW 分类器准确率 94%（甚至高于无掩码的 91.1%）
  - 构建 17×17 max/min 表（HW_share0 × HW_share1），无需 SCA
  - 将表转换为不等式输入贪心求解器
- **结论**: 掩码显著增加所需密文数（模拟评估数十万级），但不能阻止攻击

### 洗牌（Shuffling）
- **原理**: 随机化 m' 系数的处理顺序
- **挑战**: 攻击者不知何时处理零消息比特
- **本文攻击适配**:
  - 用克隆设备（已知排列）构建模板
  - 选择只有少量零比特的消息（θ=4 个零比特）
  - 观察到极端 HW 值（≤1 或 ≥15）时关联到零比特位置
  - 约 16% 不等式可能错误，但贪心求解器仍可容忍
- **结果**: 假设完美分类，300,000 不等式（~800 万密文）可恢复密钥
- **结论**: 洗牌大幅增加攻击成本，但概念验证证明仍可行

### 成本对比

| 防护措施 | 运行时开销 | 防护强度 | 本文是否可绕过 |
|---------|----------|---------|-------------|
| 密文完整性检查 | ≈5% | 低 | ✓ (公钥掩码) |
| 解封装失败检查 | 极低 | 中 | ✓ (合法密文 CC-SCA) |
| 一阶掩码 | 高（数倍） | 中高 | ✓ (共享 HW 表) |
| 洗牌 | 中 | 中 | ✓ (极端 HW 关联) |
| 掩码 + 洗牌组合 | 很高 | 高 | ✓ (但迹数大幅增加) |

### 高阶掩码的攻防动态（2025-2026 更新）

高阶掩码曾被认为能显著抬升攻击成本，但 2025-2026 年两条战线同时告急：

1. **非剖析高阶攻击**: Tosun 2025 [[raw/paper-tosun2025-nonprofiled-hocpa]] 用 HOCPA + sin/cos 最优预测函数，在 Cortex-M4 上以 700/2400 迹攻破二阶/三阶掩码 Dilithium、2200/14500 迹攻破二阶/三阶掩码 Kyber——**无需克隆设备**，且证明 bit-dropping 等通用对策对受保护格实现基本无效。
2. **最薄弱环节转移**: Hermelink 2025 [[raw/paper-hermelink2025-masked-mldsa-attack]] 已证明掩码 ML-DSA 中 y 多项式是最薄弱环节（CRYPTO 2025）。
3. **防护设计要点**: 掩码阶数提升的边际防护价值需重新评估——每加一阶约线性增加开销，但非剖析攻击所需迹数增幅有限（Dilithium 二阶→三阶仅 700→2400 迹）。带符号算术的符号依赖泄漏是实现层需规避的新泄漏源（Tosun 2025 发现）。

### 设计启示
- 低成本检测型防护**不能**提供独立防护
- 标准防护（掩码+洗牌）增加成本但**不阻止**攻击
- 最佳策略: 多层防护组合（检测 + 掩码 + 洗牌）
- **新增**: 掩码需与泄漏模型审计（如 KyberSlash 式变时指令扫描、Valgrind 补丁/形式化工具）配合，防止"掩码未破而实现先漏"

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/dilithium]], [[entities/pqm4-library]]
- 相关概念: [[concepts/ciphertext-sanity-check]], [[concepts/decapsulation-failure-check]], [[concepts/greedy-solver]], [[concepts/ntt-side-channel-attacks]], [[concepts/fault-injection]]
- 参见: [[topics/sca-countermeasures-for-lattice-pqc]]

## 引用来源
- [1] [[raw/paper-ravi2024-defeating-lcc]] — 掩码和洗牌攻击适配
- [2] [BGR+21] 掩码 Kyber 实现
- [3] [HKL+22] mkm4 一阶掩码库
- [4] [[raw/paper-hermelink2022-bp-shuffling-ntt]] — BP 突破洗牌（shuffle node）
- [5] [[raw/paper-jendral2023-single-trace-masked-kyber]] — VFI 绕过洗牌 + DL 消息恢复
- [6] [[raw/paper-bock2023-breaking-dpa-kyber]] — 模板攻击突破掩码（pair-pointwise mult）
- [7] [[raw/paper-zhang2025-cc-sca-shuffled-kyber]] — CC-SCA 突破洗牌（MLP 分类器）
- [8] [[raw/paper-coron2023-masked-dilithium-gadgets]] — Dilithium 高阶掩码 gadgets
- [9] [[raw/paper-raj2024-mldsa-hardware-masking]] — ML-DSA 硬件一阶掩码
- [10] [[raw/paper-hermelink2025-masked-mldsa-attack]] — 掩码 ML-DSA 最薄弱环节
- [11] [[raw/paper-ravi2022-sca-fia-survey]] — SCA/FIA 综述及定制防护
- [12] [[raw/paper-tosun2025-nonprofiled-hocpa]] — 高阶非剖析攻击突破二阶/三阶掩码（IACR CiC 2025）
- [13] [[raw/paper-bernstein2025-kyberslash]] — 变时除法漏洞（掩码之外的实现级泄漏警示）

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-ravi2024-defeating-lcc]]
- 2026-08-06: 大幅更新——添加 7 篇掩码/洗牌攻击与防护论文（BP 突破洗牌、VFI 绕过、模板攻击、CC-SCA 突破、Dilithium 掩码 gadgets、硬件掩码、掩码 ML-DSA 攻击）
- 2026-11-25: 更新——新增高阶掩码攻防动态（Tosun 2025 非剖析 HOCPA 攻破三阶掩码、KyberSlash 实现级泄漏警示）
