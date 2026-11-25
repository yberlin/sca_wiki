# When Randomness Isn't Random: Practical Fault Attack on Post-Quantum Lattice Standards

> **作者**: Hariprasad Kelassery Valsaraj, Prasanna Ravi, Shivam Bhasin
> **发表**: IACR ePrint 2025/2009 (2025)
> **URL**: https://eprint.iacr.org/2025/2009
> **类型**: ML-KEM+ML-DSA FI — 随机种子指针攻击

## 摘要

ML-KEM 和 ML-DSA 的理论基础虽然稳健，但本文识别出两者在实现层面的关键漏洞：多项式采样中使用的随机种子指针是一个单点故障。通过破坏此指针，攻击者可以确定性地危害整个方案，绕过标准防护措施。使用激光故障注入在 STM32H7 微控制器上验证，实现了 ML-KEM 的完整密钥和消息恢复以及 ML-DSA 的签名伪造，成功率高达 100%。

## 核心贡献

### 1. 随机种子指针攻击
- 识别多项式采样中随机种子指针的单点故障
- 破坏指针 → 确定性危害整个方案
- 绕过标准防护措施

### 2. ML-KEM + ML-DSA 双目标
- ML-KEM: 完整密钥和消息恢复
- ML-DSA: 签名伪造
- 绕过标准防护

### 3. 激光故障注入验证
- STM32H7 微控制器
- 激光故障注入 (LFI)
- 成功率高达 **100%**

### 4. 广泛影响
- 漏洞存在于广泛使用的公开库: PQM4, LibOQS, PQClean, WolfSSL
- 提出有效防护措施

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击目标 | 随机种子指针（多项式采样） |
| 故障方法 | 激光故障注入 (LFI) |
| 目标方案 | ML-KEM + ML-DSA |
| 成功率 | 高达 100% |
| 平台 | STM32H7 |
| 影响库 | PQM4, LibOQS, PQClean, WolfSSL |
| ML-KEM 效果 | 完整密钥和消息恢复 |
| ML-DSA 效果 | 签名伪造 |

## 与已有工作的关系

- **同一团队**: Ravi 团队 [[entities/ravi-research-group]] — 综述 [[raw/paper-ravi2022-sca-fia-survey]]、NTT FI [[raw/paper-ravi2022-fiddling-twiddle-ntt]]、盲 SCA [[raw/paper-ravi2024-blind-sca-kyber]]
- **Keccak FI 关联**: Wang 2024 [[raw/paper-wang2024-keccak-fault]] 也攻击随机数生成，但目标是 Keccak 而非种子指针
- **Hedged FI**: Jendral 2024 [[raw/paper-jendral2024-hedged-dilithium-fi]] 也攻击种子计算，但用电压故障

## 关联
- Ravi 团队: [[entities/ravi-research-group]]
- Keccak FI: [[raw/paper-wang2024-keccak-fault]]
- Hedged FI: [[raw/paper-jendral2024-hedged-dilithium-fi]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- Kyber 实体: [[entities/kyber-kem]]
- Dilithium 实体: [[entities/dilithium]]
- 故障概念: [[concepts/fault-injection]]
