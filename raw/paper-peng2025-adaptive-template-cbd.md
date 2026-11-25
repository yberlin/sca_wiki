# 自适应模板攻击 Kyber 二项式分布采样器（Adaptive Template Attacks on Kyber's Binomial Sampler）

> **作者**: Eric Chun-Yu Peng, Markus G. Kuhn（剑桥大学）
> **发表**: IACR TCHES 2025
> **URL**: https://tches.iacr.org/（TCHES 2025）
> **类型**: Kyber SCA — CBD 采样器跨设备自适应模板攻击（密钥生成阶段）

## 摘要

针对 Kyber 二项式分布（CBD）采样器的模板攻击长期受制于跨设备/跨操作场景的模板移植难题。本文提出**自适应模板攻击**，利用 EM 算法解决模板在设备间的迁移，锁定**随机数据缓冲区**为最佳攻击点。复杂环境下仅凭**单条功耗波形**即可高效恢复密钥或随机数。这继 Fouque 2025（Avengers，AdaBoost 攻击 CBD 采样器）之后，进一步确认：**密钥生成阶段的采样器是 Kyber 最脆弱的攻击面之一**——无需解封装 oracle、无需选择密文，密钥生成一次性的泄漏即致命。

## 核心贡献

### 1. EM 算法自适应模板
- 解决跨设备/跨操作场景下模板分布不匹配问题
- 模板可从一台设备迁移到另一台

### 2. 随机数据缓冲区攻击点
- CBD 采样中间随机位在缓冲区驻留 → 最佳泄漏窗口
- 先前工作多攻击采样累加指令，本文锁定数据缓冲

### 3. 单迹密钥/随机数恢复
- 复杂环境下单条功耗波形恢复
- 攻击对象既可是长期密钥也可是会话随机数

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击目标 | Kyber CBD 采样器（密钥生成阶段） |
| 方法 | 自适应模板攻击（EM 算法） |
| 攻击点 | 随机数据缓冲区 |
| 迹数 | 单条 |
| 场景 | 跨设备/跨操作（模板自适应） |
| 恢复对象 | 密钥或随机数 |

## 与已有工作的关系

- **Avengers 直系后续**: Fouque 2025 [[raw/paper-fouque2025-avengers]] 用 AdaBoost 分类器单迹攻击 CBD 采样器（68% 系数+格约减），本文用自适应模板+EM 算法解决其未覆盖的**跨设备模板迁移**问题——CBD 采样器攻击工具箱持续扩充
- **密钥生成攻击面**: 知识库已记录"密钥生成阶段新攻击面"（Avengers ingest 时发现），本文强化该路线：KG 一次性执行、无 oracle、防护常被忽略 [[concepts/lwe-hints-framework]]
- **模板攻击演进**: 与 Primas 2017 多变量模板（10⁶ 模板）[[raw/paper-primas2017-single-trace-lattice]] 相比，自适应模板+单迹将模板攻击的可移植性推到新高度 [[concepts/deep-learning-sca]]

## 关联
- CBD 采样器攻击: [[raw/paper-fouque2025-avengers]]
- NTT 单迹模板奠基: [[raw/paper-primas2017-single-trace-lattice]]
- Kyber 实体: [[entities/kyber-kem]]
- 深度学习 SCA（分类器对比）: [[concepts/deep-learning-sca]]
- LWE Hints 框架: [[concepts/lwe-hints-framework]]
- 防护综述: [[topics/sca-countermeasures-for-lattice-pqc]]
