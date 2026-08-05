# SCHEMA — Wiki 规则配置文件

> **知识库主题**: 结合侧信道攻击（SCA）与格约减算法分析后量子格基密码（Kyber、Dilithium 等）
> **创建时间**: 2026-08-05
> **最后更新**: 2026-08-05

## 目录结构

```
lattice-sca-wiki/
├── raw/              ← 第一层：原始资料（只读，用户投放）
│   ├── paper-xxx.md  ← 论文摘要/笔记
│   └── ...
├── wiki/             ← 第二层：LLM 编译维护的知识层
│   ├── index.md      ← 内容目录索引
│   ├── log.md        ← 变更时间线日志
│   ├── entities/     ← 实体页面（算法、团队、库）
│   ├── concepts/     ← 概念页面（攻击类型、防护机制、数学方法）
│   └── topics/       ← 主题综述页面
└── SCHEMA.md         ← 本文件
```

## 页面命名规则

- 使用 `kebab-case`，如 `kyber-kem.md`、`pc-oracle-attack.md`
- Wiki 链接使用 `[[relative-path]]` 格式，如 `[[entities/kyber-kem]]`

## 页面模板

每个 Wiki 页面必须包含以下结构：

```markdown
# {标题}

> **类型**: entity | concept | topic | comparison
> **创建时间**: YYYY-MM-DD
> **最后更新**: YYYY-MM-DD
> **来源**: [[raw/source-file]]

## 摘要
{一段话概括}

## 详情
{详细内容}

## 关联
- 相关实体: [[entities/xxx]]
- 相关概念: [[concepts/xxx]]

## 引用来源
- [1] [[raw/xxx]] — {说明}

## 变更记录
- YYYY-MM-DD: 初始创建
```

## 矛盾标注规则

当不同来源对同一问题有不同说法时，使用引用块格式：
```
> ⚠️ 矛盾标注: {来源A} 称 {说法A}，而 {来源B} 称 {说法B}。需进一步验证。
```

## 操作纪律

- `raw/` 目录只读——永远不修改原始资料
- 每次 ingest 完成后必须更新 `index.md` 和 `log.md`
- 更新已有页面时保留历史内容，追加新内容
- 所有知识点必须标注来源 `[[raw/xxx]]`
