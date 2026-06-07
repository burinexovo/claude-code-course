---
paths:
  - "**/*.py"
---

# Python 程式碼風格

- 函式的參數與回傳值加上 type hints
- 每個函式只做一件事，保持簡短
- 字串格式化使用 f-string
- 簡單情境優先用 list comprehension，不用 `map()`/`filter()`
- 不寫多餘的註解，讓變數名稱自己說明

## 註解規則

- 每個函式加 Google-style docstring：第一行說用途，再依需要加 `Args:` / `Returns:` / `Raises:`
- 第一行用祈使句（Return、Load、Fetch），不加主詞
- 只列「看 type hint 猜不到」的參數說明；顯而易見的可省略

## 範例

```python
def get_top_products(df: pd.DataFrame, n: int = 5) -> list[str]:
    """Return top N products by total sales.

    Args:
        df: Sales dataframe with 'Product Name' and 'Sales' columns.
        n: Number of top products to return.

    Returns:
        List of product name strings.
    """
    return df.groupby("Product Name")["Sales"].sum().nlargest(n).index.tolist()
```
