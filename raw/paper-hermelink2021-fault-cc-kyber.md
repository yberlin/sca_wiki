# Fault-Enabled Chosen-Ciphertext Attacks on Kyber

> **作者**: Julius Hermelink, Peter Pessl, Thomas Pöppelmann
> **发表**: INDOCRYPT 2021 (IACR ePrint 2021/1222)
> **URL**: https://eprint.iacr.org/2021/1222
> **类型**: Kyber FI — 故障+选择密文组合攻击

## 摘要

本文展示了故障注入与选择密文攻击的组合对 Kyber 实现构成重大威胁。攻击将密文操纵（翻转有效密文的单个比特）与解封装期间"纠正"密文的故障相结合。通过将 FO 变换用作 oracle（观察解封装是否失败），推导涉及秘密数据的不等式，从中恢复私钥。

## 核心贡献

### 1. 故障+选择密文组合攻击
- 密文操纵: 翻转有效密文的单个比特
- 故障"纠正": 解封装期间注入故障"纠正"密文
- FO oracle: 观察解封装是否失败 → 推导不等式

### 2. 突破多种防护
- 不被时间洗牌击败
- 不被布尔掩码击败
- 故障可在大的执行时间间隔内多处引入

### 3. 改进的恢复技术
- 改进已知恢复技术
- 从更少不等式中高效恢复私钥
- 相比 Pessl & Prokop 2021 需要更少的不等式

### 4. 攻击面扩展
- 从 Pessl & Prokop 的解码过程扩展到重加密过程
- 攻击面更大，故障引入更灵活

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击类型 | FI + CC-SCA 组合 |
| 目标 | FO 变换重加密检查 |
| 密文操纵 | 翻转单个比特 |
| 故障模型 | 比特翻转"纠正"密文 |
| 信息提取 | FO oracle (成败) → 不等式 |
| 防护突破 | 洗牌, 布尔掩码 |

## 与已有工作的关系

- **直接前身**: Pessl & Prokop 2021 [[raw/paper-pessl2021-fault-cca-kem]] — 扩展其攻击面和恢复效率
- **后续 Roulette**: Delvaux 2022 [[raw/paper-delvaux2022-roulette]] 进一步放宽故障模型和攻击面
- **贪心求解器**: 不等式恢复方法与 Ravi 2024 贪心求解器 [[concepts/greedy-solver]] 相关
- **同一作者**: Hermelink 也是 BP 洗牌突破 [[raw/paper-hermelink2022-bp-shuffling-ntt]] 和分布提示框架 [[raw/paper-hermelink2025-generic-framework]] 的作者

## 关联
- 前身: [[raw/paper-pessl2021-fault-cca-kem]]
- 后续: [[raw/paper-delvaux2022-roulette]]
- 作者相关: [[raw/paper-hermelink2022-bp-shuffling-ntt]], [[raw/paper-hermelink2025-generic-framework]]
- Kyber 实体: [[entities/kyber-kem]]
- 故障概念: [[concepts/fault-injection]]
- 贪心求解器: [[concepts/greedy-solver]]
- 分类概念: [[concepts/sca-classification-kc-vs-cc]]
