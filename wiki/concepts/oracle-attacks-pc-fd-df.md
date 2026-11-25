# 三种 Oracle 攻击：PC / FD / DF

> **类型**: concept
> **创建时间**: 2026-08-05
> **最后更新**: 2026-11-25
> **来源**: [[raw/paper-ravi2024-defeating-lcc]]

## 摘要

CC-based SCA 利用特制恶意密文，使解密后的消息与秘密密钥相关联，从而将整个 FO 变换的泄漏作为密钥恢复的 oracle。分为三种类型：明文检查（PC）oracle、全解密（FD）oracle 和解密失败（DF）oracle。

## 详情

### 1. Plaintext Checking (PC) Oracle Attack
- **文献**: [RRCB20, UXT+22, TUX+23, RRD+23]
- **原理**: 构造密文使消息比特 `m[i]` 仅依赖于某个秘密系数 `s[j]`，通过侧信道泄漏判断 `m[i]` 的值，从而恢复 `s[j]`
- **密文特征**: 低熵、稀疏（大部分系数为 0），如 `u_atk = [y, 0, 0]`, `v_atk = z`
- **典型参数** (Kyber768): y=208, z∈{624, 832, 1040, 1248} 对应 s[0][0]∈{-2,-1,0,1,2}
- **迹数**: 数百个选择密文查询
- **防护**: 可被密文完整性检查拦截（低熵检测）

### 2. Full-Decryption (FD) Oracle Attack
- **文献**: [XPRO20, RBRC20]
- **原理**: 构造密文使整个解密消息泄漏更多密钥信息，利用完整的解密过程泄漏
- **密文特征**: 同样为低熵稀疏密文
- **迹数**: ≈10 迹（非常高效）
- **防护**: 可被密文完整性检查拦截

### 3. Decryption-Failure (DF) Oracle Attack
- **文献**: [BDH+21, PP21, HPP21, Del22]
- **原理**: 利用均匀随机但无效的密文引发解密失败，通过侧信道观察失败/成功模式恢复密钥
- **密文特征**: 均匀随机（但无效），天然绕过密文完整性检查
- **迹数**: ≈6500-7000 密文查询 (Kyber768)
- **求解器**: 基于置信传播（Belief Propagation）[PP21, Del22]
- **防护**: 可被解封装失败检查拦截（单次失败即刷新密钥）
- **2026 效率翻案**: [[raw/paper-2026-ldpc-df-oracle]] 用 LDPC 信念传播+自适应查询设计，ML-KEM-768（95% 准确 oracle）仅需 **2950 次查询**（香农下界之比 1.35），**首次超越 SOTA 二进制 PC 攻击**——DF oracle 从"最差 oracle"跃升为效率之最；实例化 GoFetch 微架构泄漏后迹数再降一个数量级

### 时序型 Oracle：KyberSlash（2025 实现级警示）
- **文献**: [[raw/paper-bernstein2025-kyberslash]] (TCHES 2025)
- **原理**: 并非算法层 oracle，而是 `poly_frommsg`/`poly_compress` 中秘密依赖除法指令的变时执行——远程计时即可逐位恢复密钥（KyberSlash2 分钟级）
- **启示**: oracle 攻击分类（PC/FD/DF）之外，**实现层"意外 oracle"**（除法时序、分支差异）同样致命；检测需 Valgrind 变时指令扫描或形式化验证，而非仅靠代码审查

### 本论文对三者的影响

| Oracle 类型 | 完整性检查 | 失败检查 | 本文绕过方法 |
|------------|----------|---------|------------|
| PC | 原本被拦截 | 原本被拦截 | 公钥掩码绕过完整性检查 |
| FD | 原本被拦截 | 原本被拦截 | 公钥掩码绕过完整性检查 |
| DF | 天然绕过 | 原本被拦截 | 新型合法密文 CC-SCA 绕过失败检查 |

## 关联
- 相关实体: [[entities/kyber-kem]]
- 相关概念: [[concepts/sca-classification-kc-vs-cc]], [[concepts/ciphertext-sanity-check]], [[concepts/decapsulation-failure-check]]
- 参见: [[topics/sca-countermeasures-for-lattice-pqc]]

## 引用来源
- [1] [[raw/paper-ravi2024-defeating-lcc]] — Oracle 攻击分类与对比
- [2] [[raw/paper-2026-ldpc-df-oracle]] — DF oracle LDPC 信念传播效率翻案 (ePrint 2026/070)
- [3] [[raw/paper-bernstein2025-kyberslash]] — 实现级时序 oracle（KyberSlash）

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-ravi2024-defeating-lcc]]
- 2026-11-25: 更新——新增 DF oracle 效率翻案（LDPC 攻击 2950 查询超越 PC oracle）与 KyberSlash 实现级时序 oracle 小节
