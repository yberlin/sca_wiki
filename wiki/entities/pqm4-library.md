# pqm4 库

> **类型**: entity
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05
> **来源**: [[raw/paper-ravi2024-defeating-lcc]]

## 摘要

pqm4 是面向 ARM Cortex-M4 微控制器的后量子密码测试和基准库，由 Kannwischer 等人维护，是格基 PQC 侧信道攻击研究的主要实验平台。

## 详情

- **仓库**: https://github.com/mupq/pqm4
- **目标平台**: STM32F407 (ARM Cortex-M4)
- **包含实现**: Kyber512/768/1024 (参考实现 + 汇编优化实现), Dilithium 等
- **参考实现 [ABD+20]**: C 语言实现，O3 优化级别
- **汇编优化实现 [HZZ+22]**: Junhao Huang 等人手写汇编优化，使用 SIMD 指令 (usub16, ldmia, stmia) 同时处理 10 个系数

### 在 SCA 研究中的角色
- 提供标准的 Kyber 解密/解封装目标代码
- 本文在其上验证了合法密文 CC-SCA：参考实现需 ≈325 迹，汇编优化实现需 ≈7800 迹

### mkm4 库
- **一阶掩码 Kyber 实现** [HKL+22]
- 由 Heinz, Kannwischer, Land, Pöppelmann, Schwabe, Sprenkels 开发
- 本文在其上验证掩码实现攻击：HW 分类器准确率 94%

## 关联
- 相关实体: [[entities/kyber-kem]]
- 相关概念: [[concepts/sca-classification-kc-vs-cc]]

## 引用来源
- [1] [[raw/paper-ravi2024-defeating-lcc]] — 实验平台描述
- [2] [KRSS] mupq/pqm4 仓库
- [3] [HKL+22] mkm4 掩码实现

## 变更记录
- 2026-08-05: 初始创建，来源 [[raw/paper-ravi2024-defeating-lcc]]
