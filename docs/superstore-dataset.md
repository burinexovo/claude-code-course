# Superstore Dataset

Sample retail sales dataset widely used for BI demos and analytics practice.

## 基本資訊

| 項目 | 值 |
|---|---|
| 檔案 | `data/Superstore.csv` |
| 編碼 | Latin-1 |
| 資料筆數 | 9,994 筆（每筆 = 一個訂單明細列） |
| 欄位數 | 21 |
| 時間範圍 | 2014–2017（日期格式：MM-DD-YYYY） |
| 地區 | 美國（US）4 大區域 |

## 欄位說明

### 識別欄位

| 欄位名稱 | 型別 | 說明 |
|---|---|---|
| `Row ID` | int | 資料列流水號（1 起） |
| `Order ID` | string | 訂單編號，格式 `CA-YYYY-XXXXXX` |
| `Customer ID` | string | 客戶編號，格式 `XX-XXXXX` |
| `Product ID` | string | 商品編號 |

### 時間欄位

| 欄位名稱 | 型別 | 說明 |
|---|---|---|
| `Order Date` | string (MM-DD-YYYY) | 下單日期 |
| `Ship Date` | string (MM-DD-YYYY) | 出貨日期 |

### 物流欄位

| 欄位名稱 | 型別 | 可能值 |
|---|---|---|
| `Ship Mode` | string | `First Class` / `Same Day` / `Second Class` / `Standard Class` |

### 客戶欄位

| 欄位名稱 | 型別 | 說明 |
|---|---|---|
| `Customer Name` | string | 客戶姓名 |
| `Segment` | string | `Consumer` / `Corporate` / `Home Office` |

### 地理欄位

| 欄位名稱 | 型別 | 說明 |
|---|---|---|
| `Country` | string | 固定為 `United States` |
| `City` | string | 城市 |
| `State` | string | 州 |
| `Postal Code` | int | 郵遞區號 |
| `Region` | string | `Central` / `East` / `South` / `West` |

### 商品欄位

| 欄位名稱 | 型別 | 說明 |
|---|---|---|
| `Product Name` | string | 商品完整名稱 |
| `Category` | string | `Furniture` / `Office Supplies` / `Technology` |
| `Sub-Category` | string | 17 個子類別（見下方） |

Sub-Category 列表：`Accessories`, `Appliances`, `Art`, `Binders`, `Bookcases`, `Chairs`, `Copiers`, `Envelopes`, `Fasteners`, `Furnishings`, `Labels`, `Machines`, `Paper`, `Phones`, `Storage`, `Supplies`, `Tables`

### 交易欄位

| 欄位名稱 | 型別 | 說明 |
|---|---|---|
| `Sales` | float | 銷售金額（含折扣後），範圍 $0.44 – $22,638 |
| `Quantity` | int | 數量，範圍 1 – 14 |
| `Discount` | float | 折扣率，0.0 – 0.8（共 12 個離散值） |
| `Profit` | float | 利潤，範圍 -$6,600 – $8,400（可為負） |

## 關鍵基數

| 維度 | 唯一值數量 |
|---|---|
| 訂單數 (`Order ID`) | 5,009 |
| 客戶數 (`Customer ID`) | 793 |
| 商品數 (`Product ID`) | 1,862 |

## 注意事項

- **編碼**：檔案為 Latin-1，用 `pd.read_csv(..., encoding='latin-1')` 讀取，否則會報 `UnicodeDecodeError`
- **Profit 可為負**：折扣過高時利潤為負，分析虧損訂單時以 `Profit < 0` 篩選
- **Sales 已含折扣**：`Sales = List Price × Quantity × (1 - Discount)`，不需自行換算
- **同一 Order ID 可能對應多列**：一筆訂單可包含多個商品明細
