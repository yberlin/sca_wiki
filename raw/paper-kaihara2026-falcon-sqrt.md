# Square Root of All Evil: The Dangers of Falcon's Superfluous Square Roots

> **作者**: Hiroto Kaihara, Calvin Abou Haidar, Mehdi Tibouchi, Masayuki Abe
> **发表**: ePrint 2026（LightSec 2026 / CHES 2026 affiliated event）
> **URL**: https://eprint.iacr.org/2026/xxx
> **类型**: Falcon FI — 平方根计算故障攻击（迄今最强 Falcon 故障攻击）

## 摘要

Falcon 以紧凑高效著称，但因其依赖浮点运算（尤其平方根计算）而以难实现、难防护闻名。本文首先指出这些平方根计算**完全可以省略**——算法可改写为无平方根版本，实现同样快甚至略快；进而观察到它们构成物理攻击的**异常敏感目标**：在 ARM Cortex-M4 上注入**单次故障**于一次平方根计算，再以未受扰动的签名算法生成**约一百万个签名**，即可 100% 成功率完全恢复密钥，且故障签名与正常签名难以区分。对比此前攻击需要数亿签名样本、多次注入或可轻易区分的故障签名，这是**迄今对 Falcon 破坏性最强的故障攻击**。文中还讨论了平方根计算在依赖管理与供应链安全方面的风险。

## 核心贡献

### 1. 平方根冗余性发现
- Falcon 规范依赖的浮点平方根计算可完全去除
- 无平方根重写版同等快甚至略快 → 防护建议：直接删除该攻击面

### 2. 单故障完全密钥恢复
- 单次故障注入（一次平方根计算 glitch）
- 约 10⁶ 个正常签名收集
- 100% 密钥恢复成功率
- 故障签名不可区分 → 无法检测过滤

### 3. 与既往攻击对比
| 指标 | 既往攻击 | 本文 |
|------|---------|------|
| 注入次数 | 多次 | **单次** |
| 签名样本 | 数亿 | **约百万** |
| 故障签名可检测性 | 易区分 | **难区分** |
| 成功率 | 部分 | **100%** |

### 4. 供应链风险
- 平方根例程通常由平台 math 库提供
- 依赖管理/供应链层面构成单点信任风险

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击目标 | Falcon 签名中的浮点平方根计算 |
| 故障方法 | 单次 glitch（ARM Cortex-M4 实测） |
| 签名需求 | ~1,000,000 个正常签名 |
| 成功率 | 100% |
| 可检测性 | 故障签名与正常签名难区分 |
| 消除方案 | 改写算法去除平方根（不损失性能） |

## 与已有工作的关系

- **Crowhammer 姊妹篇**: 同为 Abou Haidar/Tibouchi 团队针对 Falcon [[raw/paper-abouhaidar2025-crowhammer]]——Crowhammer 用 Rowhammer 偏斜 RCDT（需数亿签名），本文用单次 glitch 破坏平方根（约百万签名）且不可检测，攻击效率再上一个台阶
- **Falcon 验证绕过**: Bauer 2025 [[raw/paper-bauer2025-forging-dilithium-falcon]] 攻击 Falcon/Dilithium 验证阶段；本文攻击签名阶段密钥材料——Falcon 签名/验证两端均有单故障攻击
- **浮点泄漏传统**: Falcon 高斯采样 FFT 的浮点运算一直是 SCA 重点（时序/功耗），本文证明其**故障**脆弱性同样致命 [[concepts/fault-injection]]
- **"实现复杂度即攻击面"**: 与知识库 FN-DSA 跟踪一致——Falcon 实现难度（浮点、采样器、恒时性）每一项都被证明可利用

## 关联
- Falcon 相关验证绕过: [[raw/paper-bauer2025-forging-dilithium-falcon]]
- Crowhammer: [[raw/paper-abouhaidar2025-crowhammer]]
- 故障注入概念: [[concepts/fault-injection]]
- 防护综述: [[topics/sca-countermeasures-for-lattice-pqc]]
