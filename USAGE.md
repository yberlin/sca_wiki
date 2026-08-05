# Lattice-SCA Wiki 使用指南

> 本文件指导你如何将这个知识库迁移到其他计算机上，并让大语言模型（LLM）使用它。

## 1. 知识库结构概览

```
lattice-sca-wiki/           ← 整个知识库根目录（可打包迁移）
├── SCHEMA.md               ← Wiki 规则配置（页面模板、命名规范、矛盾标注规则）
├── USAGE.md                ← 本文件
├── analysis-report.md      ← 初始论文分析报告
├── raw/                    ← 第一层：原始资料（只读）
│   ├── *.pdf               ← 9 篇论文原始 PDF（31MB）
│   └── paper-*.md          ← 9 篇论文的结构化摘要（68KB）
└── wiki/                   ← 第二层：LLM 编译的知识层（132KB）
    ├── index.md            ← 内容目录索引（总页面数、分类列表）
    ├── log.md              ← 变更时间线日志（4 轮 ingest + 1 次 lint）
    ├── entities/           ← 实体页面（6 个：Kyber, Dilithium, NTTRU, Hertzbleed, Ravi 团队, pqm4）
    ├── concepts/           ← 概念页面（12 个：提示框架、格约减、DBDD、稀疏秘密等）
    └── topics/             ← 主题综述页面（3 个：防护全景、格约减攻击、对比分析）
```

**关键数字**：34 个文件，纯文本内容约 200KB，含 PDF 共 31MB。

---

## 2. 迁移方式

### 方式 A：完整打包（推荐）

将整个 `lattice-sca-wiki/` 目录打包为 zip：

```bash
# 在源机器上
cd C:\Users\pseclab\WorkBuddy\2026-08-05-10-26-49\
zip -r lattice-sca-wiki.zip lattice-sca-wiki/

# 或用 7z
7z a lattice-sca-wiki.zip lattice-sca-wiki/
```

拷贝到目标机器后解压即可。**31MB，U 盘/网盘秒传。**

### 方式 B：仅文本内容（更轻量）

如果不需要原始 PDF（LLM 已有摘要），可以只打包文本：

```bash
# 仅打包 .md 文件，约 200KB
find lattice-sca-wiki/ -name "*.md" | zip lattice-sca-wiki-text.zip -@
```

---

## 3. 让大模型使用知识库

### 3.1 对话式使用（最简单）

将以下 Prompt 模板粘贴到任何支持文件上传或长上下文的 LLM 对话中：

```
你是一个 LLM Wiki 知识管理专家。我提供了一个关于"侧信道攻击 + 格约减算法分析后量子格基密码"的结构化知识库。

知识库结构：
- raw/ 目录包含 9 篇论文的结构化摘要（只读，不修改）
- wiki/ 目录包含 LLM 编译的知识页面：
  - wiki/index.md 是内容目录索引
  - wiki/log.md 是变更日志
  - wiki/entities/ 是实体页（Kyber, Dilithium 等）
  - wiki/concepts/ 是概念页（LWE Hints 框架, 格约减, DBDD 等）
  - wiki/topics/ 是主题综述页
- SCHEMA.md 定义了页面模板和规则

使用规则：
1. 回答问题前先读 wiki/index.md 找到相关页面
2. 读取相关页面后综合回答，标注来源 [[raw/xxx]] 或 [[concepts/xxx]]
3. 如果回答产生了有价值的新洞察，提议归档为新 Wiki 页面
4. 发现矛盾时用 ⚠️ 矛盾标注 标记
5. raw/ 目录只读——永远不修改原始资料

[上传知识库所有 .md 文件，或粘贴关键页面内容]
```

### 3.2 文件挂载式使用（Claude / GPT 等）

**Claude (Anthropic)**:
1. 创建一个 Project
2. 上传 `lattice-sca-wiki/` 下的所有 `.md` 文件
3. 设置 System Prompt 为上面的模板
4. 对话中直接提问，Claude 会自动检索上传的文件

**GPT (OpenAI)**:
1. 创建一个 GPT
2. 上传所有 `.md` 文件为 Knowledge Base
3. Instructions 中粘贴上面的 Prompt 模板

**本地 LLM (Ollama / LM Studio 等)**:
1. 将知识库放在本地目录
2. 使用支持文件读取的 Agent 框架（如 LlamaIndex, LangChain）
3. 构建简单的 RAG pipeline：
   ```python
   from llama_index.core import SimpleDirectoryReader, VectorStoreIndex
   documents = SimpleDirectoryReader("lattice-sca-wiki/").load_data()
   index = VectorStoreIndex.from_documents(documents)
   query_engine = index.as_query_engine()
   response = query_engine.query("Kyber 的侧信道攻击有哪些类型？")
   ```

### 3.3 命令行式使用（配合 Claude Code / Aider 等）

```bash
# 将知识库放到项目目录
cp -r lattice-sca-wiki/ ~/my-project/

# 在对话中引用
# "请读取 lattice-sca-wiki/wiki/index.md 了解知识库结构，
#  然后回答我的问题：..."
```

---

## 4. 典型查询示例

| 你想问的问题 | LLM 应该读取的页面 |
|------------|-----------------|
| "Kyber 有哪些侧信道攻击？" | index.md → entities/kyber-kem, concepts/sca-classification-kc-vs-cc, topics/sca-countermeasures |
| "LWE with Hints 框架怎么演进的？" | concepts/lwe-hints-framework |
| "格约减和贝叶斯更新两条路线有什么区别？" | topics/lattice-reduction-attacks-on-lwe |
| "贪心和 BP 到底谁更好？" | concepts/greedy-solver, concepts/distribution-hints（注意矛盾标注） |
| "Avengers 攻击是怎么工作的？" | raw/paper-fouque2025-avengers |
| "稀疏秘密为什么能用更少提示恢复？" | concepts/sparse-secret-lwe, raw/paper-hhan2025-perfect-to-approx |
| "各方案用 LLL 恢复需要多少提示？" | concepts/lattice-reduction |

---

## 5. 持续维护

### 添加新论文
1. 将 PDF 放入 `raw/` 目录
2. 让 LLM 提取全文并创建 `raw/paper-*.md` 摘要页
3. 更新相关 entity/concept/topic 页面添加交叉引用
4. 更新 `wiki/index.md` 和 `wiki/log.md`

### 健康巡检
定期让 LLM 执行 lint：
- 检查断裂链接（`[[xxx]]` 指向不存在的文件）
- 检查孤立页面（没有被任何页面引用）
- 检查矛盾标注是否完整
- 检查 index.md 是否列出所有页面

### 页面模板
参见 `SCHEMA.md` 中的标准页面模板。每个页面包含：
- 类型/创建时间/来源 元数据
- 摘要（一段话概括）
- 详情（多个子标题）
- 关联（双向链接）
- 引用来源
- 变更记录

---

## 6. 当前知识库统计

| 指标 | 数值 |
|------|------|
| 论文数 | 9 篇 |
| wiki 页面总数 | 25 (6 实体 + 12 概念 + 3 主题 + 4 索引/日志/Schema/分析) |
| 总文件数 | 34 |
| 纯文本大小 | ~200KB |
| 含 PDF 大小 | ~31MB |
| 交叉引用数 | 150+ |
| 矛盾标注 | 1 (greedy vs BP，已调和) |
| 断裂链接 | 0 |
| 孤立页面 | 0 |

最后更新: 2026-08-05
