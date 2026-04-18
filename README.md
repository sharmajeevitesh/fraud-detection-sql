# 🔍 Fraud Detection using SQL

A structured SQL-based exploratory analysis for detecting fraudulent credit card transactions using statistical comparisons, time-gap analysis, and a rule-based fraud scoring system.

---

## 📁 Project Structure

```
├── fraud_analysis.sql   # All SQL queries for fraud detection analysis
└── README.md
```

---

## 📊 Dataset

This project assumes a `transactions` table with the following key columns:

| Column  | Description |
|---------|-------------|
| `Time`  | Seconds elapsed since the first transaction |
| `Amount`| Transaction amount in USD |
| `Class` | Label — `1` = Fraud, `0` = Legitimate |
| `V1`–`V28` | PCA-transformed anonymized features |

> The dataset used is the [Kaggle Credit Card Fraud Detection dataset](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud), which is highly imbalanced — fraud accounts for only **~0.17%** of all transactions.

---

## 🧠 Analysis Breakdown

### 1. Dataset Overview
```sql
SELECT COUNT(*) AS total_transactions FROM transactions;
```
- Gets the total number of transactions in the dataset.

---

### 2. Fraud Transaction Count
```sql
SELECT COUNT(*) AS fraud_transactions FROM transactions WHERE Class = 1;
```
- Isolates and counts confirmed fraud cases.

---

### 3. Fraud Percentage
```sql
SELECT COUNT(*), SUM(Class), (SUM(Class) * 100.0) / COUNT(*) AS fraud_percentage
FROM transactions;
```
- Calculates the overall fraud rate.
- Result: Fraud is extremely rare (~0.17%), making this a classic **imbalanced classification** problem.

---

### 4. Fraud vs. Legitimate — Amount Comparison
```sql
SELECT Class, COUNT(*), AVG(Amount), MAX(Amount), MIN(Amount)
FROM transactions GROUP BY Class;
```
- Compares transaction amounts between fraud and legitimate classes.
- **Insight:** Fraudulent transactions tend to have a **higher average amount** than legitimate ones.

---

### 5. High-Value Fraud Transactions
```sql
SELECT * FROM transactions
WHERE Amount > (SELECT AVG(Amount) FROM transactions) AND Class = 1;
```
- Filters fraud transactions that are **above the overall average amount** — a useful high-risk subset.

---

### 6. Fast Fraud Detection (Time-Gap Analysis)
```sql
SELECT * FROM (
    SELECT Time, Amount, Class,
    Time - LAG(Time) OVER (ORDER BY Time, Amount) AS time_diff
    FROM transactions
) t
WHERE Class = 1 AND time_diff < 10;
```
- Uses a **window function** (`LAG`) to calculate time between consecutive transactions.
- Flags fraud transactions that occur **within 10 seconds** of the previous one — a behavioral pattern common in rapid card testing or automated fraud.

---

### 7. Rule-Based Fraud Scoring
```sql
SELECT *,
    CASE WHEN Amount > 100 THEN 2 ELSE 0 END +
    CASE WHEN time_diff < 10 AND time_diff IS NOT NULL THEN 3 ELSE 0 END
AS fraud_score
FROM (...) t;
```
- Assigns a **fraud risk score** to every transaction based on:
  - `+2` if amount exceeds $100
  - `+3` if the time gap to the previous transaction is under 10 seconds
- **Higher score = Higher fraud risk**

| Score | Risk Level |
|-------|------------|
| 0     | Low        |
| 2     | Moderate   |
| 3     | High       |
| 5     | Very High  |

---

## 💡 Key Findings

- Fraud is **extremely rare** (~0.17%) — standard accuracy metrics can be misleading.
- Fraudulent transactions tend to involve **higher amounts** on average.
- **Rapid successive transactions** (< 10 seconds apart) are a strong behavioral fraud signal.
- A simple rule-based scoring system can flag high-risk transactions without any ML model.

---

## 🚀 How to Use

1. Load your transactions data into a SQL-compatible database (PostgreSQL, MySQL, SQLite, etc.)
2. Create the `transactions` table with the appropriate schema.
3. Run the queries in `fraud_analysis.sql` sequentially or individually.
4. Use the `fraud_score` output to prioritize transactions for manual review or downstream ML pipelines.

---

## 🛠️ Requirements

- Any SQL environment: **PostgreSQL**, **MySQL 8+**, **SQLite**, **BigQuery**, or similar.
- The `LAG()` window function requires a database that supports **SQL window functions** (MySQL 8+, PostgreSQL, SQLite 3.25+).

---

## 📌 Future Improvements

- Add PCA feature (`V1`–`V28`) analysis to identify anomalous patterns.
- Integrate with Python (pandas + SQLAlchemy) for visualization.
- Build an ML model (Logistic Regression, Isolation Forest) on top of this EDA.
- Add index optimization for large-scale transaction datasets.
