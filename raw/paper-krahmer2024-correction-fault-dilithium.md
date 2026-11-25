# Correction Fault Attacks on Randomized CRYSTALS-Dilithium

> **作者**: Elisabeth Krahmer, Peter Pessl, Georg Land, Tim Güneysu
> **发表**: TCHES 2024(3), pp. 174-199
> **URL**: https://tches.iacr.org/index.php/TCHES/article/view/11673
> **类型**: Dilithium FI — 校正故障攻击随机化模式

## 摘要

NIST 选择 Dilithium 作为主要后量子签名标准。确定性的实现攻击导致 NIST 选择随机化（hedged）签名模式作为默认。本文提出两种新的针对随机化/hedged Dilithium 的密钥恢复故障攻击。两种攻击都基于签名后校正故障签名的思路。成功校正产生携带密钥信息的秘密中间值。收集足够多的故障签名和校正值后，可通过简单线性代数或格约减技术求解签名密钥。

## 核心贡献

### 1. 校正故障攻击范式
- 签名后校正故障签名
- 校正产生携带密钥信息的秘密中间值
- 收集足够多故障签名 → 线性代数或格约减求解密钥

### 2. 两种攻击方法
- **攻击 1**: 扩展已有的指令跳过故障攻击到随机化设置
  - Dilithium2: 1024 次故障签名
- **攻击 2**: 在公钥矩阵 A 中注入故障
  - A 不是侧信道敏感的 → 此前未分析
  - Dilithium2: 512 次故障签名

### 3. 突破防护
- 展示如何适配攻击以绕过多种常见故障防护
- 适度增加计算运行时间和所需故障签名数
- 模拟故障和 ARM 微控制器时钟故障验证

### 4. 攻击面扩展
- 故障目标不限于侧信道敏感操作
- 公钥矩阵 A 也可被故障攻击
- 许多其他操作可能也易受攻击

## 关键技术细节

| 维度 | 攻击 1 (指令跳过) | 攻击 2 (矩阵 A 故障) |
|------|-------------------|---------------------|
| 故障目标 | 签名计算指令跳过 | 公钥矩阵 A |
| 签名数 | 1024 | 512 |
| 侧信道敏感 | 是 | 否 |
| 恢复方法 | 线性代数/格约减 | 线性代数/格约减 |
| 故障模型 | 单次定向故障 | 单次定向故障 |
| 验证 | 模拟 + 时钟故障 | 模拟 + 时钟故障 |
| 平台 | ARM 微控制器 | ARM 微控制器 |

## 与已有工作的关系

- **DFA 前身**: Bruinderink 2018 [[raw/paper-bruinderink2018-dfa-deterministic-lattice]] — 扩展到随机化模式
- **同期 hedged 攻击**: Jendral 2024 [[raw/paper-jendral2024-hedged-dilithium-fi]] — 不同方法攻击 hedged 模式
- **MLWE→RLWE**: ElGhamrawy 2023 [[raw/paper-elghamrawy2023-mlwe-to-rlwe]] — 另一种随机化 Dilithium 攻击
- **同一作者**: Pessl 也是 DFA [[raw/paper-bruinderink2018-dfa-deterministic-lattice]]、FO 故障 [[raw/paper-pessl2021-fault-cca-kem]] 和 NTT SCA [[raw/paper-primas2017-single-trace-lattice]] 的作者

## 关联
- DFA 前身: [[raw/paper-bruinderink2018-dfa-deterministic-lattice]]
- 同期 hedged: [[raw/paper-jendral2024-hedged-dilithium-fi]]
- MLWE→RLWE: [[raw/paper-elghamrawy2023-mlwe-to-rlwe]]
- FO 故障: [[raw/paper-pessl2021-fault-cca-kem]]
- Dilithium 实体: [[entities/dilithium]]
- 故障概念: [[concepts/fault-injection]]
- 格约减概念: [[concepts/lattice-reduction]]
