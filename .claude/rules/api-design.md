---
paths:
  - "**/*.py"
---

# API 設計規範（RESTful）

- 路徑用名詞複數代表資源，不用動詞：`/orders` 而非 `/getOrders`
- HTTP 動詞代表操作：`GET` 查詢、`POST` 新增、`PUT` 全量更新、`DELETE` 刪除
- 過濾條件用 query string：`/subcategories/top?n=5`
- 回傳格式統一：`{ "data": ... }` 或 `{ "error": "..." }`

## 範例

```python
# ✅ 資源導向
GET  /sales/by-region
GET  /subcategories/top?n=5
GET  /orders/unprofitable
POST /data/upload

# ❌ 動作導向（避免）
GET  /getSalesByRegion
GET  /top
GET  /loss
```
