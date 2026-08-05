# Defeating Low-Cost Countermeasures against SCA in Lattice-based Encryption

> **原始资料类型**: 学术论文
> **标题**: Defeating Low-Cost Countermeasures against Side-Channel Attacks in Lattice-based Encryption — A Case Study on Crystals-Kyber
> **作者**: Prasanna Ravi, Thales Paiva, Dirmanto Jap, Jan-Pieter D'Anvers, Shivam Bhasin
> **机构**: Temasek Laboratories (NTU Singapore), Fundep (Brazil), CASNAV (Brazil), imec-COSIC KU Leuven (Belgium)
> **发表期刊**: IACR Transactions on Cryptographic Hardware and Embedded Systems (TCHES), 2024, Vol. 2024, No. 2, pp. 795-818
> **DOI**: 10.46586/tches.v2024.i2.795-818
> **接收日期**: 2023-10-15 | **接受日期**: 2023-12-15 | **发表日期**: 2024-03-12
> **关键词**: Lattice-based cryptography, Side-Channel Attack, Kyber, KEM, Chosen Ciphertext Attack

## 论文核心摘要

本文针对后量子格基密码（以 CRYSTALS-Kyber 为案例）中的两类低成本检测型防护措施——**密文完整性检查（Ciphertext Sanity Check）** 和 **解封装失败检查（Decapsulation Failure Check）**——进行了首次安全性分析，并提出了能够攻破这两类防护的新型选择密文侧信道攻击方法。

## 三大贡献

### 贡献 1a：攻破密文完整性检查（Ciphertext Sanity Check）
- **方法**: 将恶意低熵密文与公钥相加进行"掩码"，使其看起来均匀随机，从而绕过基于均值/方差的熵检测
- **原理**: `(u_atk + A, v_atk + b)` 的解密结果仍为 `v_atk - u_atk·s + e`，即原始攻击方程加上一个小误差
- **成功率**: 随机选择一个掩码，单次完整密钥恢复成功率为 57.8%；预期平均 1.73 次尝试即可成功
- **优势**: 掩码后攻击策略与无防护时完全相同；可适配 PC oracle 和 FD oracle 攻击

### 贡献 1b：攻破解封装失败检查（Decapsulation Failure Check）
- **方法**: 提出首个仅依赖**合法密文**（valid ciphertexts）的 CC-SCA，使攻击不会触发解封装失败
- **攻击目标**: 解密过程中的噪声消息多项式 `m'` 的系数汉明重量（HW）泄漏
- **三步攻击流程**:
  1. **Step 1**: 通过侧信道（CPA/模板攻击）恢复 `HW(m'[i])`
  2. **Step 2**: 利用 `m[i]=0` 时 HW 分布偏置，构建关于 `Δm[i]` 符号的线性不等式
  3. **Step 3**: 用新提出的贪心求解器从线性不等式组中恢复秘密密钥 `s` 和错误 `e`

### 贡献 2：新型贪心求解器（Greedy Solver）
- **改进对象**: Pessel & Prokop [PP21] 和 Delvaux [Del22] 基于置信传播（Belief Propagation, BP）的方法
- **优势**: 更简单易懂、计算复杂度更低、所需不等式数量不到 BP 方法的一半
- **性能**: σ=0.5 时 BP 需 10+ 分钟，贪心求解器仅需 20 秒
- **算法**: 贪心搜索，每轮迭代选择使违反不等式惩罚最小的操作

## 实验验证

| 实现类型 | HW分类器准确率 | 恢复密钥所需迹数 |
|---------|-------------|---------------|
| 参考实现 (O3-ref) | 91.1% | ≈325 迹（模拟） / ≈5200 迹（实测，仅利用 8 个零比特） |
| 汇编优化实现 | 32.0% | ≈7800 迹 |
| 洗牌实现 (Shuffled) | 假设完美分类 | ≈800 万密文（概念验证） |
| 一阶掩码实现 (Masked) | 94% | 模拟评估，显著增加 |

- **实验平台**: STM32F407 微控制器 (24 MHz), pqm4 库, Langer RF-U 5-2 近场 EM 探针, Lecroy 610Zi 示波器 (1.25 GSa/s)
- **目标算法**: Kyber768

## 核心结论

1. 低成本检测型防护措施**不能提供独立的防护**，面对新型 CC-SCA 时完全无效
2. 仅依赖合法密文的 CC-SCA 是可行的，这从根本上挑战了"解封装失败检查"的设计前提
3. 新型贪心求解器显著优于 BP 方法，且对噪声更鲁棒
4. 洗牌和掩码会增加攻击者复杂度但**不能阻止攻击**

## 与已有工作的对比

| 维度 | 本文方法 | PC Oracle [RRCB20] | FD Oracle [XPRO20] | DF Oracle [BDH+21] | BP Solver [PP21,Del22] |
|-----|---------|-------------------|-------------------|-------------------|---------------------|
| 密文类型 | 合法密文 (新颖) | 恶意低熵 | 恶意低熵 | 随机无效 | — |
| 绕过完整性检查 | ✓ (公钥掩码) | ✗ | ✗ | ✓ | — |
| 绕过失败检查 | ✓ | ✗ | ✗ | ✗ | — |
| 密钥恢复迹数 | 325-7800 | 数百 | ≈10 | 6500-7000 | — |
| 求解器 | 贪心搜索 | — | — | BP | BP |
| 不等式需求 | <2× (少于BP一半) | — | — | 基准 | 基准 |

## 开源代码

https://github.com/thalespaiva/sca_on_kyber_lcc
