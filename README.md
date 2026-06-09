# Claude Code 實戰課程

Claude Code CLI 入門課程的實作 Repo。

## 課程目標

透過實際動手操作，學會用 Claude Code 作為開發副駕駛，從需求釐清到產出可運行的程式，體驗 AI 輔助開發的完整流程。

## 課程中會學到

- 🛠️ 在 WSL 裝好完整開發環境
- ⌨️ Claude Code CLI 基本操作
- 📁 搞懂 `.claude/` 目錄與 `CLAUDE.md`
- 🚀 用工作流跑出 Flask API + Dashboard
- 🤖 SubAgent 怎麼幫你平行處理

## Repo 結構

```
claude-code-course/
├── .claude/
│   ├── agents/                 ← SubAgent 定義（engineer / executive / user-researcher）
│   └── rules/                  ← Coding rules（api-design / python-style）
├── data/
│   └── Superstore.csv          ← 課程資料集（美國零售銷售資料，~10K 筆）
├── docs/
│   └── superstore-dataset.md  ← 欄位說明文件
├── meeting-notes/              ← 模擬會議記錄（需求情境素材）
├── prds/
│   └── Carls-PRD.md           ← PRD 模板範例
├── script/                     ← 輔助腳本
├── app.py                      ← 課堂產出：Flask API（空白，課堂現場建立）
├── dashboard.html              ← 課堂產出：視覺化 Dashboard（空白，課堂現場建立）
└── todo.html                   ← 課堂產出：TODO List（空白，課堂現場建立）
```

## 課堂會產出的三個東西

| 檔案             | 說明                  |
| ---------------- | --------------------- |
| `todo.html`      | 簡易 TODO List 前端   |
| `dashboard.html` | Superstore 銷售視覺化 |
| `app.py`         | Flask REST API        |

## 環境需求

- Python 3.11+
- [uv](https://docs.astral.sh/uv/) 套件管理

```bash
uv run flask --app app run --port 5001
```

## 資料集

`data/Superstore.csv` 為美國零售銷售模擬資料，涵蓋 2014–2017 年，共 9,994 筆訂單明細。詳細欄位說明見 `docs/superstore-dataset.md`。
