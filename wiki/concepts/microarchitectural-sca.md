# 微架构侧信道攻击（Microarchitectural SCA）

> **类型**: concept
> **创建时间**: 2026-11-25
> **最后更新**: 2026-11-25
> **来源**: [[raw/paper-chen2024-gofetch]], [[raw/paper-bernstein2025-kyberslash]], [[entities/hertzbleed]]

## 摘要

微架构侧信道攻击利用处理器硬件实现（预取器、DVFS、除法器、分支预测器）的物理行为泄漏秘密，其共同特点是**打破"常时间实现 = 安全"的工程假设**。对格基 PQC 而言，2024-2025 年三条路线相继落地：Apple DMP 预取器（GoFetch）端到端攻破常时间 Kyber/Dilithium；秘密依赖除法时序（KyberSlash）远程分钟级恢复 ML-KEM 密钥；DVFS 功率-频率转换（Hertzbleed）将功耗泄漏转化为远程可测的频率泄漏。攻击者模型从"物理接触"扩展到"同机进程/远程计时"，是 PQC 部署时代最现实的威胁类别之一。

## 三大攻击面

### 1. DMP 数据内存依赖预取器（GoFetch, USENIX Security 2024）
- **硬件行为**: Apple M 系列将缓存中"像指针"的数据自动预取 → 秘密值被动成为地址
- **攻击**: 选择输入使 NTT 中间值落入 DMP 判定窗口 → 缓存计时逐系数提取 → 格约减恢复
- **效果**: Kyber-512 约 54 分钟、Dilithium-2 约 10 小时（同集群普通权限进程）
- **不可修补**: 硅片级缺陷，软件缓解（盲化等）算法相关且开销大
- 详见 [[raw/paper-chen2024-gofetch]]

### 2. 秘密依赖除法时序（KyberSlash, TCHES 2025）
- **硬件行为**: CPU 除法指令周期数随操作数变化（Arm Cortex-A7/M4 均有）
- **漏洞位置**: `poly_frommsg`（KyberSlash1）、`poly_compress`（KyberSlash2）
- **效果**: 远程计时，KyberSlash2 分钟级恢复密钥
- **可修补**: 已负责任披露并修复；检测手段 = Valgrind 变时指令扫描 + 形式化验证
- 详见 [[raw/paper-bernstein2025-kyberslash]]

### 3. DVFS 功率-频率转换（Hertzbleed, ISCA 2022 → Li 2025 格攻击）
- **硬件行为**: DVFS 根据负载动态调频，功耗差异映射为频率差异 → 远程可测
- **攻击链**: Hertzbleed 泄漏 → mod-q 提示 → 低维格构造 → 400 秒恢复简化 Kyber 密钥
- 详见 [[entities/hertzbleed]], [[raw/paper-li2025-hertzbleed-hints]]

## 与传统 SCA 的本质区别

| 维度 | 传统 SCA（功耗/EM/模板） | 微架构 SCA |
|------|------------------------|------------|
| 测量手段 | 示波器/近场探头（物理接触） | 计时/缓存探测（同机进程甚至远程） |
| 攻击门槛 | 高（设备+技能） | 低（软件即可） |
| 恒时实现是否免疫 | 部分免疫 | **不免疫**（DMP/DVFS/除法器在硬件层泄漏） |
| 防护手段 | 掩码/洗牌/隐藏 | 盲化/算法重写/硬件更换，代价高昂 |
| 与格约减结合 | Hints 框架（模/分布提示） | 同样可用 Hints 框架（GoFetch/Li 2025 后处理） |

## 与 LWE Hints 框架的映射

微架构泄漏的后处理与物理泄漏共用 [[concepts/lwe-hints-framework]]：
- GoFetch 逐系数泄漏 → 类完美/模提示 → 格约减
- Hertzbleed 位级泄漏 → mod-q 提示 → 低维格直接构造（Li 2025）
- DMP/时序 oracle 实例化 DF oracle → LDPC 信念传播（2026/070，无需格约减）

## 防护启示

1. **恒时性不充分**: 常时间编码规则（秘密不作地址）被 DMP 推翻；需叠加掩码/盲化
2. **实现级审计工具化**: Valgrind 变时指令扫描（SUPERCOP 1000+ 实现已扫描）、形式化验证是部署前必需
3. **算法-硬件协同**: KyberSlash 表明"标准算法描述"与"安全实现"间存在翻译缝隙——除法、浮点、表查找均为高危指令类别
4. **威胁模型分层**: 云/移动场景（同机攻击者）必须考虑微架构泄漏；隔离 enclave 不能幸免
5. **检测型防护需升级**: 传统完整性/失败检查对微架构攻击无感，需在实现层加入运行时一致性校验

## 关联
- 相关实体: [[entities/hertzbleed]], [[entities/kyber-kem]], [[entities/dilithium]]
- 相关概念: [[concepts/lwe-hints-framework]], [[concepts/ntt-side-channel-attacks]], [[concepts/oracle-attacks-pc-fd-df]]
- 参见: [[topics/sca-countermeasures-for-lattice-pqc]]
- 原始资料: [[raw/paper-chen2024-gofetch]], [[raw/paper-bernstein2025-kyberslash]], [[raw/paper-li2025-hertzbleed-hints]], [[raw/paper-2026-ldpc-df-oracle]]

## 引用来源
- [1] [[raw/paper-chen2024-gofetch]] — GoFetch DMP 攻击 (USENIX Security 2024)
- [2] [[raw/paper-bernstein2025-kyberslash]] — KyberSlash 除法时序 (TCHES 2025)
- [3] [[raw/paper-li2025-hertzbleed-hints]] — Hertzbleed 泄漏格攻击 (TCHES 2025)
- [4] [[raw/paper-2026-ldpc-df-oracle]] — DF oracle LDPC 攻击实例化微架构泄漏 (ePrint 2026/070)

## 变更记录
- 2026-11-25: 初始创建——整合 GoFetch/KyberSlash/Hertzbleed 三大微架构攻击路线，填补知识库"非物理接触类攻击"空白
