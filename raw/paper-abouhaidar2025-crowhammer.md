# Crowhammer: Full Key Recovery Attack on Falcon with a Single Rowhammer Bit Flip

> **作者**: Calvin Abou Haidar, Quentin Payet, Mehdi Tibouchi
> **发表**: CRYPTO 2025 (ePrint 2025/1042)
> **URL**: https://eprint.iacr.org/2025/1042
> **类型**: Falcon FI — Rowhammer 持久故障攻击（软件层故障注入）

## 摘要

Crowhammer 首次证明 Falcon 签名方案可被 **Rowhammer**（纯软件故障注入，无需物理接触）完全攻破。Falcon 官方实现为抗时序攻击使用硬编码的逆累积分布表（RCDT）进行高斯采样。攻击者用 Rowhammer 在 RCDT 中触发**单个针对性比特翻转**，使采样分布产生可检测的偏斜；采集数亿量级签名后，结合主成分分析（PCA）改进的 Nguyen–Regev 平行六面体学习攻击即可完全恢复签名密钥。比特翻转越多所需签名越少。该漏洞同样可由光学故障等其他持久性内存故障触发。低成本对策：拒绝异常短的签名。

## 核心贡献

### 1. 软件层故障注入攻击 PQC 签名
- Rowhammer 完全在软件层触发持久比特翻转，无需电压/时钟/激光等物理注入设备
- 大幅扩展攻击面：远程无物理访问攻击者即可实施

### 2. Falcon 高斯采样器 RCDT 攻击
- 官方实现依赖 RCDT 抗时序攻击 → RCDT 本身成为持久故障目标
- 单比特翻转 → 采样分布偏斜 → 数亿签名 → PCA + Nguyen–Regev 攻击 → 完全密钥恢复
- 经典 Nguyen–Regev 攻击在少量翻转下不直接适用，需 PCA 增强才能提取偏斜方向

### 3. 低成本对策
- 拒绝异常短签名（检查签名范数）即可大幅缓解
- 印证"检测型防护"思路在持久故障场景的价值

## 关键技术细节

| 维度 | 详情 |
|------|------|
| 攻击目标 | Falcon 官方实现的高斯采样器 RCDT（硬编码表） |
| 故障方法 | Rowhammer（软件层持久比特翻转），单比特即可 |
| 采样需求 | 数亿量级签名（单比特翻转时）；更多翻转 → 更少签名 |
| 后处理 | PCA 增强的 Nguyen–Regev 平行六面体学习攻击 |
| 攻击模型 | 无物理访问的软件攻击者 |
| 对策 | 拒绝异常短签名（范数检查） |
| 姊妹工作 | SLasH-DSA（对 SLH-DSA 的同类 Rowhammer 攻击，OpenSSL 3.5.1 全安全级别） |

## 与已有工作的关系

- **持久故障分析 (PFA) 范式**: 与 SLasH-DSA (ePrint 2025, arXiv:2509.13048，SWAGE 框架攻击 OpenSSL SLH-DSA，8 小时 Rowhammer + 36 秒后处理实现 256f 通用伪造) 同属"Rowhammer/持久故障 → 系统性密钥恢复"路线，PQC 时代故障攻击正从物理注入向软件层迁移
- **Falcon SCA 传统**: 之前 Falcon 攻击集中在浮点运算/高斯采样的功耗与时序泄漏（如 Primas/Karabulut 系列），Crowhammer 开辟**持久内存故障**新维度 [[concepts/fault-injection]]
- **验证绕过对比**: Bauer 2025 的单故障验证绕过 [[raw/paper-bauer2025-forging-dilithium-falcon]] 是"验证阶段一次性故障"，Crowhammer 是"签名阶段持久分布偏斜"，一急性一慢性
- **Tibouchi 团队**: 同团队 2026 年 LightSec 论文"Square Root of All Evil"进一步证明 Falcon 平方根计算既不必要又极危险（单次故障+百万签名=100% 密钥恢复，故障签名难与正常签名区分）——Falcon 实现安全连续第二年恶化

## 关联
- 故障注入概念: [[concepts/fault-injection]]（新增"持久故障/软件层故障"类别）
- Falcon 验证绕过: [[raw/paper-bauer2025-forging-dilithium-falcon]]
- 防护综述: [[topics/sca-countermeasures-for-lattice-pqc]]
- 格约减: [[concepts/lattice-reduction]]（Nguyen–Regev 学习攻击属格分析后处理）
