# 侧信道攻击分类：KC-SCA vs CC-SCA

> **类型**: concept
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ravi2024-defeating-lcc]]

## 摘要

针对 Kyber KEM 解封装过程的侧信道攻击分为两大类：已知密文攻击（KC-SCA）和选择密文攻击（CC-SCA）。CC-SCA 更强大，是防护设计的主要对手模型。

## 详情

### Known Ciphertext (KC) based SCA
- **攻击者能力**: 仅需知道输入给解封装的密文
- **攻击目标**: 多项式乘法操作 `⟨s, u⟩` (CPAPKE.Dec Line 3)
- **攻击方法**:
  - 单迹模板攻击: 针对 INTT [PPM17, PP19] 和逐点乘法 [YRZ+23, BBB+23]
  - 多迹 CPA: ≈200 迹恢复密钥 [MWK+22]
- **局限**: 攻击面窄，只能针对秘密密钥直接操作的部分
- **优势**: 使用合法密文，天然绕过解封装失败检查

### Chosen Ciphertext (CC) based SCA
- **攻击者能力**: 可控制输入给解封装的密文
- **攻击面**: 整个解封装过程（FO 变换的全部泄漏）
- **子类**:
  1. **Plaintext Checking (PC) Oracle**: [RRCB20, UXT+22, TUX+23]
  2. **Full-Decryption (FD) Oracle**: [XPRO20]
  3. **Decryption-Failure (DF) Oracle**: [BDH+21]
- **优势**: 攻击面大，更强大
- **代价**: 需要恶意密文，可被检测型防护拦截（但本文证明可绕过）

### 对比

| 维度 | KC-SCA | CC-SCA |
|-----|--------|--------|
| 攻击者能力 | 知道密文 | 控制密文 |
| 攻击目标 | 多项式乘法 | 整个解封装 |
| 密文类型 | 合法 | 通常恶意/无效 |
| 防护成本 | 较低 | 较高（需掩码+洗牌） |
| 典型迹数 | ≈200 (CPA) | ≈10 (FD) ~ 数千 (PC/DF) |

### 本论文的创新位置
本文提出的合法密文 CC-SCA 模糊了 KC/CC 的传统边界：既拥有 CC 的攻击面优势，又使用合法密文（类似 KC），从而绕过所有检测型防护。

### 扩展攻击模型

| 攻击模型 | 描述 | 代表论文 |
|---------|------|---------|
| **盲 SCA** | 攻击者无法获取密文 | [[raw/paper-ravi2024-blind-sca-kyber]] (Kyber pointwise mult) |
| **单迹 SCA** | 仅需一条迹线 | [[raw/paper-primas2017-single-trace-lattice]], [[raw/paper-pessl2019-practical-ntt]] |
| **CC-SCA + 洗牌突破** | 构造恶意密文诱导 HW 分布变化 | [[raw/paper-zhang2025-cc-sca-shuffled-kyber]] |
| **FI + SCA 组合** | 故障绕过防护 + SCA 恢复 | [[raw/paper-jendral2023-single-trace-masked-kyber]] |

## 关联
- 相关实体: [[entities/kyber-kem]], [[entities/dilithium]]
- 相关概念: [[concepts/oracle-attacks-pc-fd-df]], [[concepts/ntt-side-channel-attacks]], [[concepts/fault-injection]], [[concepts/deep-learning-sca]]
- 参见: [[topics/sca-countermeasures-for-lattice-pqc]]

## 引用来源
- [1] [[raw/paper-ravi2024-defeating-lcc]] — SCA 分类与对比
- [2] [[raw/paper-ravi2022-sca-fia-survey]] — 系统性 SCA/FIA 分类综述
- [3] [[raw/paper-ravi2024-blind-sca-kyber]] — 盲 SCA 新模型
- [4] [[raw/paper-zhang2025-cc-sca-shuffled-kyber]] — CC-SCA 突破洗牌
- [5] [[raw/paper-jendral2023-single-trace-masked-kyber]] — FI+SCA 组合

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-ravi2024-defeating-lcc]]
- 2026-08-06: 更新——添加扩展攻击模型（盲 SCA、FI+SCA 组合），4 篇新引用
