# 变更日志

## 2026-08-05

### Ingest: 论文 "Defeating Low-Cost Countermeasures against SCA in Lattice-based Encryption" (TCHES 2024)

- ✨ 新增: [[raw/paper-ravi2024-defeating-lcc]] — 论文原始资料摘要页
- ✨ 新增: [[entities/kyber-kem]] — CRYSTALS-Kyber KEM 实体页
- ✨ 新增: [[entities/ravi-research-group]] — 研究团队实体页
- ✨ 新增: [[entities/pqm4-library]] — pqm4/mkm4 库实体页
- ✨ 新增: [[concepts/sca-classification-kc-vs-cc]] — KC-SCA vs CC-SCA 概念页
- ✨ 新增: [[concepts/oracle-attacks-pc-fd-df]] — PC/FD/DF Oracle 攻击概念页
- ✨ 新增: [[concepts/ciphertext-sanity-check]] — 密文完整性检查概念页
- ✨ 新增: [[concepts/decapsulation-failure-check]] — 解封装失败检查概念页
- ✨ 新增: [[concepts/greedy-solver]] — 贪心求解器概念页
- ✨ 新增: [[concepts/masking-and-shuffling]] — 掩码与洗牌防护概念页
- ✨ 新增: [[topics/sca-countermeasures-for-lattice-pqc]] — 格基 PQC SCA 防护全景综述
- ✨ 新增: [[topics/comparison-ravi2024-vs-prior-work]] — 与已有工作对比分析
- 🔗 链接: [[entities/kyber-kem]] ↔ [[concepts/sca-classification-kc-vs-cc]]
- 🔗 链接: [[entities/kyber-kem]] ↔ [[concepts/oracle-attacks-pc-fd-df]]
- 🔗 链接: [[concepts/ciphertext-sanity-check]] ↔ [[concepts/oracle-attacks-pc-fd-df]]
- 🔗 链接: [[concepts/decapsulation-failure-check]] ↔ [[concepts/greedy-solver]]
- 🔗 链接: [[concepts/masking-and-shuffling]] ↔ [[concepts/greedy-solver]]

### 知识库初始化
- ✨ 新增: SCHEMA.md — Wiki 规则配置文件
- ✨ 新增: wiki/index.md — 内容目录索引
- ✨ 新增: wiki/log.md — 变更时间线日志（本文件）

### Ingest: 4 篇新论文（格约减攻击路线）

- ✨ 新增: [[raw/paper-hermelink2025-generic-framework]] — "A Generic Framework for SCAs against LWE-based Cryptosystems" (Hermelink 2025)
- ✨ 新增: [[raw/paper-li2025-hertzbleed-hints]] — "Improved Attacks Against Lattice-Based KEMs Using Hints From Hertzbleed" (Li, TCHES 2025)
- ✨ 新增: [[raw/paper-cao2025-refined-attack]] — "Refined Attack on LWE with Hints" (Cao, CRYPTO 2025)
- ✨ 新增: [[raw/paper-may2023-too-many-hints]] — "Too Many Hints – When LLL Breaks LWE" (May, Asiacrypt 2023)
- ✨ 新增: [[entities/dilithium]] — CRYSTALS-Dilithium (ML-DSA) 签名方案实体页
- ✨ 新增: [[entities/nttru]] — NTTRU 加密方案实体页
- ✨ 新增: [[entities/hertzbleed]] — Hertzbleed DVFS 频率侧信道攻击实体页
- ✨ 新增: [[concepts/lwe-hints-framework]] — LWE with Hints 框架概念页（DDGR→MN→Cao 演进）
- ✨ 新增: [[concepts/modular-hints]] — 模提示概念页
- ✨ 新增: [[concepts/lattice-reduction]] — 格约减攻击 LLL/BKZ 概念页
- ✨ 新增: [[concepts/distribution-hints]] — 分布提示概念页
- ✨ 新增: [[topics/lattice-reduction-attacks-on-lwe]] — 格约减攻击 LWE with Hints 全景综述
- 📝 更新: [[entities/kyber-kem]] — 添加 4 篇新论文交叉引用（格约减攻击路线）
- 📝 更新: [[concepts/greedy-solver]] — 添加 Hermelink 2025 理论统一分析
- 📝 更新: [[topics/sca-countermeasures-for-lattice-pqc]] — 扩展为两条攻击路线的交叉视角
- 📝 更新: wiki/index.md — 更新索引至 18 页面
- 🔗 链接: [[entities/kyber-kem]] ↔ [[entities/dilithium]], [[entities/nttru]], [[entities/hertzbleed]]
- 🔗 链接: [[concepts/greedy-solver]] ↔ [[concepts/distribution-hints]] (理论统一)
- 🔗 链接: [[concepts/lwe-hints-framework]] ↔ [[concepts/modular-hints]], [[concepts/lattice-reduction]], [[concepts/distribution-hints]]
- 🔗 链接: [[entities/hertzbleed]] ↔ [[concepts/modular-hints]] (DVFS→模提示)
- ⚠️ 矛盾: [[concepts/greedy-solver]] — Ravi 2024 称贪心优于 BP vs Hermelink 2025 称贪心是 BP 近似（已标注调和）
- ⚠️ 矛盾: [[concepts/distribution-hints]] — 同上矛盾标注

### Ingest: 2 篇奠基论文（DDGR CRYPTO 2020 + 几何视角 CRYPTO 2023）

- ✨ 新增: [[raw/paper-ddgr2020-lwe-side-info]] — "LWE with Side Information" (DDGR, CRYPTO 2020) — **LWE with Hints 框架奠基论文**
- ✨ 新增: [[raw/paper-dachman2023-geometric]] — "Revisiting Security Estimation from a Geometric Perspective" (CRYPTO 2023)
- ✨ 新增: [[concepts/dbdd]] — DBDD（畸变有界距离解码）概念页
- 📝 更新: [[concepts/lwe-hints-framework]] — 添加 DDGR raw 页面引用、几何视角扩展、不等式提示、DBDD 链接
- 📝 更新: [[concepts/lattice-reduction]] — 添加 DDGR 来源、DBDD 链接、Sage 工具说明
- 📝 更新: [[concepts/modular-hints]] — 添加 DDGR raw 页面引用（原始模提示定义）
- 📝 更新: [[concepts/distribution-hints]] — 添加几何视角论文来源（不等式提示起源）
- 📝 更新: [[topics/lattice-reduction-attacks-on-lwe]] — 添加 DDGR/几何来源、DBDD 链接、组合提示、SCA+DF 组合泄漏
- 📝 更新: [[topics/sca-countermeasures-for-lattice-pqc]] — 添加两篇奠基论文来源
- 📝 更新: [[entities/kyber-kem]] — 添加 DDGR 和几何视角引用
- 📝 更新: wiki/index.md — 更新索引至 22 页面（7 raw + 6 实体 + 10 概念 + 3 主题 = 26... 实际 wiki 页面 19+3=22）
- 🔗 链接: [[concepts/dbdd]] ↔ [[concepts/lwe-hints-framework]], [[concepts/lattice-reduction]], [[concepts/modular-hints]]
- 🔗 链接: [[raw/paper-ddgr2020-lwe-side-info]] ↔ 所有格约减路线页面（奠基引用）
- 🔗 链接: [[raw/paper-dachman2023-geometric]] ↔ [[concepts/distribution-hints]]（不等式提示起源）
- 📝 知识图谱完善: DDGR [CRYPTO 2020] 此前仅作为 [4] 占位引用存在于 lwe-hints-framework 中，现已建立完整 raw 页面和 DBDD 概念页，使知识库的引用链从"占位符→实际页面"升级为"全链接"

### Lint: 健康巡检（第三轮后）

- 🔧 修复: [[entities/kyber-kem]] — 将 3 个占位链接(mlwe-problem, fo-transform, side-channel-attack)替换为实际页面链接(sca-classification-kc-vs-cc, oracle-attacks-pc-fd-df)
- 🔧 修复: [[entities/pqm4-library]] — 将 side-channel-attack 占位链接替换为 sca-classification-kc-vs-cc
- 🔧 修复: [[entities/ravi-research-group]] — 将 2 个占位链接(cc-based-sca, pc-oracle-attack)替换为实际页面链接(sca-classification-kc-vs-cc, oracle-attacks-pc-fd-df)
- 🔧 修复: [[concepts/sca-classification-kc-vs-cc]] — 将 3 个子类占位链接(pc/fd/df-oracle-attack)合并为 oracle-attacks-pc-fd-df 单链接
- ✅ 索引完整性: index.md 列出全部 22 个 wiki 页面 + 7 个 raw 页面，无遗漏
- ✅ 断裂链接: 修复后 0 个断裂链接（排除别名语法后全部有效）
- ✅ 孤立页面: 0 个孤立页面（所有 wiki 页面均被至少 1 个其他页面引用）
- ✅ 矛盾标注: 1 个矛盾（greedy-solver vs distribution-hints，已调和），在 greedy-solver.md + distribution-hints.md + log.md 三处标注
- ✅ 来源引用: 所有 7 个 raw 页面均被 wiki 页面引用，无孤立原始资料

### Ingest: 2 篇新论文（Avengers TCHES 2025 + Perfect-to-Approx S&P 2026）

- ✨ 新增: [[raw/paper-fouque2025-avengers]] — "Avengers assemble! Supervised learning meets lattice reduction" (TCHES 2025)
- ✨ 新增: [[raw/paper-hhan2025-perfect-to-approx]] — "From Perfect to Approximate Hints" (IEEE S&P 2026)
- ✨ 新增: [[concepts/sparse-secret-lwe]] — 稀疏三值秘密 LWE 概念页（O(h log²h) 阈值）
- 📝 更新: [[concepts/lwe-hints-framework]] — 添加 Fouque "way too many hints" 制度和 Hhan O(h log²h) 路线
- 📝 更新: [[concepts/lattice-reduction]] — 添加 Avengers 实际 BKZ 实验数据、新制度阈值
- 📝 更新: [[topics/lattice-reduction-attacks-on-lwe]] — 添加 2 条新路线、CBD/OpenFHE 泄漏源、新增 2 行求解器对比
- 📝 更新: [[topics/sca-countermeasures-for-lattice-pqc]] — 添加 CBD 采样器和 FHE 稀疏秘密来源
- 📝 更新: [[entities/kyber-kem]] — 添加 Avengers 和 Hhan 引用
- 📝 更新: wiki/index.md — 更新索引至 25 页面（7 实体+概念 + 9 raw + ... 总 wiki 页面 25）
- 🔗 链接: [[concepts/sparse-secret-lwe]] ↔ [[concepts/lwe-hints-framework]], [[concepts/lattice-reduction]], [[topics/lattice-reduction-attacks-on-lwe]]
- 🔗 链接: [[raw/paper-fouque2025-avengers]] ↔ [[entities/kyber-kem]] (CBD 攻击面), [[concepts/lwe-hints-framework]] (way too many hints)
- 🔗 链接: [[raw/paper-hhan2025-perfect-to-approx]] ↔ [[concepts/sparse-secret-lwe]], [[concepts/lwe-hints-framework]]
- 📝 关键发现: Fouque 开辟密钥生成阶段新攻击面（CBD 采样器），Hhan 将 FHE 稀疏秘密的提示阈值从 O(n) 降至 O(h log²h)
