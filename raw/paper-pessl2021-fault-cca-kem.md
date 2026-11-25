# Fault Attacks on CCA-secure Lattice KEMs

> **作者**: Peter Pessl, Lukas Prokop
> **发表**: TCHES 2021(2), pp. 37-60
> **URL**: https://tches.iacr.org/index.php/TCHES/article/view/8787
> **类型**: Kyber FI 奠基 — 首个格 KEM 故障攻击

## 摘要

NIST 后量子标准化进入最终轮。格 KEM 使用 FO 变换实现 CCA2 安全，后者涉及重新加密和密文等价性测试。这对应于计算逆运算的经典防护，可阻止许多故障攻击。本文证明尽管有此固有保护，实际故障攻击仍然可行。

## 核心贡献

### 1. 首个格 KEM 故障攻击
- 首个针对格 KEM 的实际故障攻击
- 目标: Kyber, NewHope（以及可能的 Saber）
- 攻击 FO 变换的重新加密检查

### 2. 指令跳过故障
- 在解封装的解码过程中注入单条指令跳过故障
- 观察故障是否改变了结果（有效故障 vs 无效故障）
- 从有效/无效判断中建立关于密钥系数的线性不等式

### 3. 突破检测型防护
- 仅需区分有效和无效故障
- 可绕过多种基于检测的防护，包括多种双执行形式
- 6500 次故障解封装可恢复 Kyber512 完整密钥

### 4. 实际验证
- 时钟故障攻击 Cortex-M4 上的 Kyber
- 证明 FO 变换的故障威慑不可依赖

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击目标 | FO 变换解码过程 |
| 故障类型 | 单指令跳过 |
| 信息提取 | 有效/无效故障 → 线性不等式 |
| Kyber512 迹数 | 6,500 |
| 平台 | ARM Cortex-M4 |
| 故障方法 | 时钟故障 |

## 历史意义

本文是**格 KEM 故障注入攻击的奠基性工作**，首次证明 FO 变换不能提供足够的故障防护。直接启发了后续的 Hermelink 2021 [[raw/paper-hermelink2021-fault-cc-kyber]] 和 Delvaux 2022 [[raw/paper-delvaux2022-roulette]]。

## 与已有工作的关系

- **后续扩展**: Hermelink 2021 加入选择密文 [[raw/paper-hermelink2021-fault-cc-kyber]]
- **进一步改进**: Delvaux 2022 Roulette 放宽故障模型 [[raw/paper-delvaux2022-roulette]]
- **同一作者**: Pessl 也是 Dilithium DFA [[raw/paper-bruinderink2018-dfa-deterministic-lattice]] 和 NTT SCA [[raw/paper-primas2017-single-trace-lattice]] 的作者
- **贪心求解器关联**: 不等式求解方法与 Ravi 2024 的贪心求解器 [[concepts/greedy-solver]] 相关

## 关联
- 后续扩展: [[raw/paper-hermelink2021-fault-cc-kyber]], [[raw/paper-delvaux2022-roulette]]
- Dilithium DFA: [[raw/paper-bruinderink2018-dfa-deterministic-lattice]]
- NTT SCA: [[raw/paper-primas2017-single-trace-lattice]]
- Kyber 实体: [[entities/kyber-kem]]
- 故障概念: [[concepts/fault-injection]]
- 贪心求解器: [[concepts/greedy-solver]]
