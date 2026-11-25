# Adapting Belief Propagation to Counter Shuffling of NTTs

> **作者**: Julius Hermelink, Silvan Streit, Emanuele Strieder, Katharina Thieme
> **发表**: TCHES 2023 (IACR ePrint 2022/555)
> **URL**: https://eprint.iacr.org/2022/555
> **类型**: Kyber SCA — 突破洗牌防护

## 摘要

数论变换（NTT）是最近引入的格后量子密码中的主要构建块。NTT 已成为多项基于信念传播（BP）的侧信道攻击的目标。Ravi 等人最近提出了多项对抗这些攻击的防护措施。Hamburg 等人在 2021 年提出了改进的侧信道攻击，本文以其为起点。

## 核心贡献

### 1. Shuffle Node — 突破洗牌防护
- 引入新的因子节点类型：**shuffle node**
- 在 BP 运行中迭代学习细粒度洗牌的置换
- 将洗牌信息融入因子图

### 2. 匹配算法
- 基于洗牌测量的层间连接匹配算法
- 双重随机混合矩阵：根据混合先验分布
- 精确置换提取与层的精确反向匹配

### 3. 子图推理
- 减少不确定性
- 改善蝴蝶网络的反向洗牌
- 评估洗牌防护措施的有效性

### 4. 安全性评估结论
> Ravi 等人提出的防护措施虽然强大，能对抗 Hamburg 等人的攻击，但可能导致**虚假的安全感**——强大的对手仍可发起成功攻击。

## 关键技术细节

- **攻击目标**: NTT 中的洗牌防护
- **攻击框架**: 信念传播（BP）
- **防护评估对象**: Ravi 等人提出的洗牌防护
- **基础攻击**: Hamburg 2021 的选择密文 SCA
- **关键词**: Kyber, NTT, BP, SASCA, 机器学习, 防护措施

## 与已有工作的关系

- **继承**: Hamburg 2021 选择密文 SCA + Primas 2017/Pessl 2019 NTT 攻击
- **对抗**: Ravi 等人的洗牌防护措施
- **后续关联**: Hermelink 2025 分布提示框架 [[raw/paper-hermelink2025-generic-framework]] — 同一作者后续统一了 BP 框架

## 关联
- 前身: [[raw/paper-primas2017-single-trace-lattice]], [[raw/paper-pessl2019-practical-ntt]]
- 作者后续工作: [[raw/paper-hermelink2025-generic-framework]]
- 防护对象: [[raw/paper-ravi2022-sca-fia-survey]] (Ravi 的洗牌防护)
- 综述引用: [[raw/paper-ravi2022-sca-fia-survey]]
- 相关概念: [[concepts/greedy-solver]], [[concepts/sca-classification-kc-vs-cc]], [[concepts/masking-and-shuffling]]
