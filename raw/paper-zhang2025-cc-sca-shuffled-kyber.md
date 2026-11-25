# A Chosen-Ciphertext Side-Channel Attack on Shuffled CRYSTALS-Kyber

> **作者**: Hao Zhang, Zewen Ye, Teng Wang, Yuanming Zhang, Tianyu Wang, Chengxuan Wang, Kejie Huang
> **发表**: IACR ePrint 2025/1956 (预印本)
> **URL**: https://eprint.iacr.org/2025/1956
> **类型**: Kyber SCA — 突破洗牌的 CC-SCA

## 摘要

本文提出了一种针对使用 Fisher-Yates 洗牌多项式规约的 CRYSTALS-Kyber 实现的新型选择密文侧信道攻击。通过构造恶意密文，诱导中间多项式系数的汉明权重分布变化（洗牌多项式规约在解封装过程中的输出），从而恢复秘密密钥系数。

## 核心贡献

### 1. 恶意密文构造
- 通过构造恶意密文诱导汉明权重分布变化
- 利用洗牌多项式规约的输出
- 从分布变化中恢复私钥系数

### 2. 容错密钥恢复算法
- 高效且容错的密钥恢复算法
- 利用 HW 分类器行为约束和缩小校正搜索空间
- 即使分类器精度较低或低 SNR 环境下也有效

### 3. MLP 分类器
- 多层感知器（MLP）从侧信道迹线进行 HW 分类
- 97.11% 准确率

### 4. 统计分析+可解释深度学习
- 结合统计分析进行精确迹线分割预处理
- 可解释深度学习辅助

### 5. 攻击效果
| 维度 | 详情 |
|------|------|
| 密文查询 | 10 + 354×3 = 1072 |
| 成功率 | 97.98% |
| 对抗成本降低 | 95.36% (vs 比特翻转技术) |
| MLP 准确率 | 97.11% |

## 关键技术细节

- **攻击类型**: CC-SCA（选择密文侧信道攻击）
- **目标**: Fisher-Yates 洗牌多项式规约
- **ML 分类器**: MLP (多层感知器)
- **泄露**: 汉明权重分布
- **预处理**: 统计分析 + 可解释深度学习

## 与已有工作的关系

- **突破洗牌**: Hermelink 2022 从 BP 角度突破洗牌 [[raw/paper-hermelink2022-bp-shuffling-ntt]]，Jendral 2023 从故障角度突破 [[raw/paper-jendral2023-single-trace-masked-kyber]]，本文从 CC-SCA 角度突破
- **安全启示**: 统计特征在洗牌后仍然存在并泄露
- **ML 应用**: 与 Wang 2023/2024 的深度学习 Dilithium 攻击类似，但目标和方法不同

## 关联
- 洗牌突破: [[raw/paper-hermelink2022-bp-shuffling-ntt]], [[raw/paper-jendral2023-single-trace-masked-kyber]]
- 分类概念: [[concepts/sca-classification-kc-vs-cc]], [[concepts/masking-and-shuffling]]
- 综述: [[raw/paper-ravi2022-sca-fia-survey]]
- Kyber 实体: [[entities/kyber-kem]]
