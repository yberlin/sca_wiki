# XMSS FPGA RTL Implementation

## 项目概述

本项目在FPGA上实现XMSS（eXtended Merkle Signature Scheme）后量子数字签名算法的RTL硬件加速器，基于RFC 8391和NIST SP 800-208标准。全部代码使用 **Verilog-2001** 标准编写，不使用任何SystemVerilog特性。

### 核心特性

- **可配置工作模式**：密钥生成（KeyGen）、签名（Sign）、验签（Verify）
- **可选哈希函数**：SHA-256（SHA2）或 SHAKE128/SHAKE256（SHA3）
- **支持全部参数集**：RFC 8391全部12组 + NIST SP 800-208新增6组 = 共18组
- **纯RTL实现**：哈希引擎、WOTS+、Merkle树全部用RTL描述，不依赖特定FPGA厂商IP
- **Verilog-2001标准**：不使用SystemVerilog，兼容所有主流仿真器和综合工具
- **黄金测试向量**：基于RFC 8391参考算法的Python实现生成，覆盖哈希、WOTS+、树结构各层级

## 目录结构

```
xmss_fpga/
├── rtl/                    # RTL源代码 (Verilog-2001)
│   ├── xmss_params.vh           # 参数定义头文件（所有参数集OID和宏）
│   ├── sha256_core.v            # SHA-256核心（纯RTL）
│   ├── keccak_round.v          # Keccak-f[1600]置换（纯RTL）
│   ├── shake_core.v            # SHAKE128/256海绵构造（纯RTL）
│   ├── hash_engine.v           # 哈希引擎抽象层
│   ├── xmss_address.v          # 256位地址管理器
│   ├── wots_plus.v             # WOTS+一次性签名核心
│   ├── xmss_tree.v             # XMSS Merkle树引擎
│   ├── xmss_top.v              # 顶层模块（控制FSM + 参数解析）
│   ├── xmss_bram.v             # BRAM封装（RTL推断）
│   └── xmss_fifo.v             # FIFO（RTL推断）
├── tb/                     # 测试平台 (Verilog-2001)
│   ├── tb_xmss_hash.v           # 哈希引擎测试
│   ├── tb_xmss_wots.v           # WOTS+核心测试
│   └── tb_xmss_top.v           # 顶层全流程测试
├── sw/                     # 软件工具
│   └── generate_golden_vectors.py  # 黄金测试向量生成器
├── sim/                    # 仿真输出
│   ├── golden_vectors.json       # JSON格式黄金向量
│   └── hex/                      # $readmemh可用的hex文件
└── docs/                   # 文档
```

## 与SystemVerilog版本的主要区别

| 特性 | SystemVerilog (旧) | Verilog-2001 (当前) |
|------|-------------------|-------------------|
| 文件后缀 | .sv / .svh | .v / .vh |
| 数据类型 | `logic` | `reg` / `wire` |
| 时序块 | `always_ff` | `always @(posedge clk)` |
| 组合块 | `always_comb` | `always @(*)` |
| 参数包 | `package` / `import` | `define` 宏 + `include` |
| 枚举 | `enum` | `localparam` 常量 |
| 结构体 | `struct packed` | 展开为独立端口信号 |
| 函数 | `automatic function` | `function` |
| 模块参数 | `parameter int` | `parameter` |

## 支持的参数集

### RFC 8391参数集

| 参数集名称 | OID | n | w | h | 哈希函数 | WOTS+ len |
|-----------|-----|---|---|---|---------|-----------|
| XMSS-SHA2_10_256 | 0x01 | 32 | 16 | 10 | SHA-256 | 67 |
| XMSS-SHA2_16_256 | 0x02 | 32 | 16 | 16 | SHA-256 | 67 |
| XMSS-SHA2_20_256 | 0x03 | 32 | 16 | 20 | SHA-256 | 67 |
| XMSS-SHA2_10_512 | 0x04 | 64 | 16 | 10 | SHA-512 | 131 |
| XMSS-SHA2_16_512 | 0x05 | 64 | 16 | 16 | SHA-512 | 131 |
| XMSS-SHA2_20_512 | 0x06 | 64 | 16 | 20 | SHA-512 | 131 |
| XMSS-SHAKE_10_256 | 0x07 | 32 | 16 | 10 | SHAKE128 | 67 |
| XMSS-SHAKE_16_256 | 0x08 | 32 | 16 | 16 | SHAKE128 | 67 |
| XMSS-SHAKE_20_256 | 0x09 | 32 | 16 | 20 | SHAKE128 | 67 |
| XMSS-SHAKE_10_512 | 0x0a | 64 | 16 | 10 | SHAKE256 | 131 |
| XMSS-SHAKE_16_512 | 0x0b | 64 | 16 | 16 | SHAKE256 | 131 |
| XMSS-SHAKE_20_512 | 0x0c | 64 | 16 | 20 | SHAKE256 | 131 |

### NIST SP 800-208参数集

| 参数集名称 | OID | n | w | h | 哈希函数 | WOTS+ len | 安全等级 |
|-----------|-----|---|---|---|---------|-----------|---------|
| XMSS-SHA2_10_192 | 0x0d | 24 | 16 | 10 | SHA-256/192 | 51 | L1 |
| XMSS-SHA2_16_192 | 0x0e | 24 | 16 | 16 | SHA-256/192 | 51 | L1 |
| XMSS-SHA2_20_192 | 0x0f | 24 | 16 | 20 | SHA-256/192 | 51 | L1 |
| XMSS-SHAKE256_10_256 | 0x10 | 32 | 16 | 10 | SHAKE256 | 67 | L5 |
| XMSS-SHAKE256_16_256 | 0x11 | 32 | 16 | 16 | SHAKE256 | 67 | L5 |
| XMSS-SHAKE256_20_256 | 0x12 | 32 | 16 | 20 | SHAKE256 | 67 | L5 |
| XMSS-SHAKE256_10_192 | 0x13 | 24 | 16 | 10 | SHAKE256/192 | 51 | L3 |
| XMSS-SHAKE256_16_192 | 0x14 | 24 | 16 | 16 | SHAKE256/192 | 51 | L3 |
| XMSS-SHAKE256_20_192 | 0x15 | 24 | 16 | 20 | SHAKE256/192 | 51 | L3 |

## IP使用说明

### 纯RTL模块（无IP依赖）

以下模块完全用Verilog-2001 RTL描述，不使用任何FPGA厂商IP：

| 模块 | 说明 |
|------|------|
| `sha256_core.v` | SHA-256压缩函数，64轮迭代 |
| `keccak_round.v` | Keccak-f[1600] 24轮置换 |
| `shake_core.v` | SHAKE海绵构造 |
| `hash_engine.v` | 哈希抽象层（F/H/H_msg/PRF） |
| `wots_plus.v` | WOTS+签名核心 |
| `xmss_tree.v` | Merkle树构建 |
| `xmss_address.v` | 地址管理 |
| `xmss_top.v` | 顶层控制FSM |

### 可能需要IP的模块

以下模块使用RTL推断的存储结构。综合工具通常会自动推断为BRAM/FIFO。
如果需要使用厂商IP，可以替换这些模块的实例：

| 模块 | 替换说明 |
|------|---------|
| `xmss_bram.v` | 简单双端口RAM。可替换为Xilinx BRAM IP或Intel altsyncram |
| `xmss_fifo.v` | 标准FIFO。可替换为Xilinx FIFO Generator或Intel scfifo |

## 仿真运行

### 使用iverilog

```bash
iverilog -o sim_hash \
  rtl/xmss_params.vh rtl/sha256_core.v rtl/keccak_round.v \
  rtl/shake_core.v rtl/hash_engine.v rtl/xmss_address.v \
  rtl/xmss_bram.v rtl/xmss_fifo.v \
  tb/tb_xmss_hash.v
vvp sim_hash
```

### 使用Verilator

```bash
verilator --cc --exe --build \
  -Irtl \
  rtl/sha256_core.v rtl/keccak_round.v rtl/shake_core.v \
  rtl/hash_engine.v rtl/xmss_address.v \
  tb/tb_xmss_hash.v
```

### 使用VCS/Xcelium

```bash
vcs -sverilog -f filelist.f  # Note: -sverilog not needed for pure Verilog
# or
xrun -verilog -f filelist.f
```

## 黄金测试向量

### 生成方式

```bash
cd sw/
python generate_golden_vectors.py
```

### 覆盖范围

| 测试类别 | 覆盖内容 | 数量 |
|---------|---------|------|
| 哈希函数 | F, H, H_msg, PRF x SHA2/SHAKE128/SHAKE256 x n=24/32/64 | 7组 |
| WOTS+ | genSK, genPK, chain, sign, pkFromSig | 5组 |
| XMSS树 | L-tree, leaf computation | 2组 |
