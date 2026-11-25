# KyberSlash: Exploiting secret-dependent division timings in Kyber implementations

> **作者**: Daniel J. Bernstein, Karthikeyan Bhargavan, Shivam Bhasin, Anupam Chattopadhyay, Tee Kiah Chia, Matthias J. Kannwischer, Franziskus Kiefer, Thales B. Paiva, Prasanna Ravi, Goutam Tamvada
> **发表**: IACR TCHES 2025(2), pp.209-234 (2025)
> **URL**: https://tches.iacr.org/index.php/TCHES/article/view/12046 / ePrint 2024/xxx
> **类型**: ML-KEM 时序攻击 — 秘密依赖除法时序（实现级漏洞）

## 摘要

本文披露 KyberSlash1 和 KyberSlash2 两个时序漏洞：多个 Kyber 实现（包括官方参考代码）在解密消息解码（`poly_frommsg` 中的 `t = (((t << 1) + KYBER_Q/2)/KYBER_Q) & 1`）和密文压缩（`poly_compress`/`polyvec_compress`）中使用了秘密依赖的除法指令。除法的 CPU 周期数随输入变化，攻击者通过精确计时即可逐位恢复私钥。在树莓派 2（Cortex-A7）和 Cortex-M4 上验证：KyberSlash2 数分钟内可靠恢复密钥，KyberSlash1 数小时。漏洞已负责任披露并被各库修补。这是 ML-KEM 标准化后影响最广的实现级远程可利用漏洞之一，证明"常时间实现"仅靠代码审查无法保证。

## 核心贡献

### 1. 两个实现级时序漏洞
- **KyberSlash1**: 消息解码 `poly_frommsg` 中的除法，被除数含秘密值 t
- **KyberSlash2**: 密文压缩 `poly_compress` 中的除法，重加密场景中输出为秘密相关

### 2. 实际可利用性验证
- 平台: 树莓派 2 (Arm Cortex-A7) + Arm Cortex-M4
- KyberSlash2: **数分钟**内可靠恢复密钥
- KyberSlash1: **数小时**内恢复
- 远程可利用（无需物理接触，仅需计时测量）

### 3. 系统性检测方法
- **动态分析**: 修改 Valgrind 检测秘密数据上的变时指令，扫描 SUPERCOP 中 1000+ 密码实现，发现多个类似问题
- **形式化方法**: 提出更严格的保证方案，用形式化验证排除变时指令

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 漏洞类型 | 秘密依赖除法时序 |
| 漏洞位置 | poly_frommsg / poly_compress / polyvec_compress |
| 影响实现 | 官方参考代码 + 多个第三方库（含 Signal 使用的 libpqcrypto） |
| 攻击平台 | Raspberry Pi 2 (Cortex-A7), Cortex-M4 |
| 恢复时间 | KyberSlash2: 分钟级; KyberSlash1: 小时级 |
| 攻击模型 | 远程/本地计时，无需物理接触 |
| 状态 | 已负责任披露，各库已修补 |

## 与已有工作的关系

- **M4 时序预言机**: 与 CC-SCA 中利用解封装失败分支时间差的攻击原理相通，但 KyberSlash 是**纯实现缺陷**而非算法流程特性 [[concepts/oracle-attacks-pc-fd-df]]
- **FO 变换时序**: FO 变换本身不背锅——问题出在开发者用非恒时除法实现 [[topics/sca-countermeasures-for-lattice-pqc]]
- **常时间运动**: 与 Hertzbleed（频率侧信道）互补：Hertzbleed 证明即使恒时代码也有功耗泄漏，KyberSlash 证明很多"恒时"代码根本不恒时 [[entities/hertzbleed]]
- **检测工具**: Valgrind 补丁 + 形式化验证，为知识库"防护检测工具链"空白提供了关键补充

## 关联
- Kyber 实体: [[entities/kyber-kem]]
- 时序/Oracle 概念: [[concepts/oracle-attacks-pc-fd-df]], [[concepts/sca-classification-kc-vs-cc]]
- 防护综述: [[topics/sca-countermeasures-for-lattice-pqc]]
- Hertzbleed 对比: [[entities/hertzbleed]]
- Ravi 团队: [[entities/ravi-research-group]] (Ravi/Bhasin 参与本文)
