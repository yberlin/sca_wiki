# GoFetch: Breaking Constant-Time Cryptographic Implementations Using Data Memory-Dependent Prefetchers

> **作者**: Boru Chen, Yingchen Wang, Pradyumna Shome, Christopher W. Fletcher, David Kohlbrenner, Riccardo Paccagnella, Daniel Genkin
> **发表**: USENIX Security 2024（Pwnie Award 最佳密码攻击奖）
> **URL**: https://eprint.iacr.org/2023/xxx / https://gofetch.fail / https://www.usenix.org/conference/usenixsecurity24/presentation/chen-boru
> **类型**: 微架构侧信道 — DMP 预取器对 Kyber/Dilithium 的选择输入攻击

## 摘要

GoFetch 利用 Apple M 系列芯片的**数据内存依赖预取器**（DMP）攻破"常时间"密码实现。DMP 会主动将缓存中"像指针"的数据当作地址预取，打破了"不将秘密作为地址使用即安全"的常时间安全基石。攻击者构造选择输入，使 Kyber/Dilithium 的 NTT 内部中间值（看起来像指针）被 DMP 预取，通过缓存计时逐系数提取，再用格约减恢复完整密钥。在同一性能核集群内普通用户权限即可运行：Kyber-512 约 54 分钟、Dilithium-2 约 10 小时提取所需材料（另有离线格约减时间）。DMP 缺陷无法通过微码修补，是硅片级不可修复漏洞。

## 核心贡献

### 1. DMP 攻击面重新定义
- 之前 Augury (S&P 2022) 认为 DMP 泄漏对恒时代码无威胁
- GoFetch 证明 Apple DMP 比想象激进得多：**任何从内存加载的值都可能被解引用**
- 常时间编程的第一原则（秘密不作地址）被硬件层推翻

### 2. 端到端密钥提取
- 选择输入攻击精心构造 NTT 输入，使中间值落入 DMP"指针"判定窗口
- 受害目标: OpenSSL DH、Go RSA、CRYSTALS-Kyber、CRYSTALS-Dilithium
- Kyber-512: 54 分钟在线; Dilithium-2: 约 10 小时在线 + 离线格约减

### 3. 缓解代价高昂
- 硅片不可修补，只能软件缓解
- 密文盲化等对策算法相关且开销大（某些场景资源翻倍）

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 泄漏源 | Apple DMP 数据内存依赖预取器 (M1/M2/M3/A14) |
| 攻击模型 | 同性能集群普通用户权限进程，无需 root |
| 受害方案 | Kyber (ML-KEM), Dilithium (ML-DSA), RSA, DH |
| 恢复后处理 | 格约减（离线） |
| Kyber-512 用时 | ~54 分钟 |
| Dilithium-2 用时 | ~10 小时 |
| 可修补性 | 不可（硅片级） |
| Intel 对比 | Raptor Lake DMP 功能受限，未能复现 |

## 与已有工作的关系

- **格约减后处理**: 提取每个系数 1-2 bit 泄漏后用格约减恢复，呼应 LWE with Hints 框架的"modular hints"集成 [[concepts/lwe-hints-framework]]
- **Hertzbleed 对比**: Hertzbleed 是 DVFS 功率→频率转换（被动、慢），GoFetch 是 DMP 缓存计时（主动、快），两者都打破"恒时=安全"的迷思 [[entities/hertzbleed]]
- **Li 2025 Hertzbleed+Hints**: 知识库已有的 Hertzbleed 格攻击路线 [[raw/paper-li2025-hertzbleed-hints]] 与 GoFetch 构成"微架构泄漏→格约减"的姊妹工作
- **后续发展**: LDPC/DF 预言机混合攻击框架（ePrint 2026/070）将 GoFetch 实例化为 DF oracle，所需迹数降低一个数量级以上
- **防护启示**: 掩码/洗牌对此类微架构攻击有效（破坏选择输入控制），但盲化开销大——见防护综述 [[topics/sca-countermeasures-for-lattice-pqc]]

## 关联
- Kyber 实体: [[entities/kyber-kem]]
- Dilithium 实体: [[entities/dilithium]]
- Hertzbleed 实体: [[entities/hertzbleed]]（同为微架构/频率类泄漏）
- LWE Hints 框架: [[concepts/lwe-hints-framework]]（后处理格约减）
- 格约减: [[concepts/lattice-reduction]]
- 防护综述: [[topics/sca-countermeasures-for-lattice-pqc]]
- 微架构攻击概念: [[concepts/microarchitectural-sca]]
