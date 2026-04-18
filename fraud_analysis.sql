-- total number of transactions
SELECT COUNT(*) AS total_transactions
FROM transactions;

-- number of fraud transactions
SELECT COUNT(*) AS fraud_transactions
FROM transactions
WHERE Class = 1;

-- overall fraud percentage
SELECT 
    COUNT(*) AS total,
    SUM(Class) AS fraud,
    (SUM(Class) * 100.0) / COUNT(*) AS fraud_percentage
FROM transactions;

-- observation: fraud transactions are very rare (~0.17%)

-------------------------------------------------------

-- comparing fraud vs non-fraud transactions
SELECT 
    Class,
    COUNT(*) AS total_transactions,
    AVG(Amount) AS avg_amount,
    MAX(Amount) AS max_amount,
    MIN(Amount) AS min_amount
FROM transactions
GROUP BY Class;

-- observation: fraud transactions tend to have higher average amount

-------------------------------------------------------

-- finding fraud transactions above average amount
SELECT *
FROM transactions
WHERE Amount > (SELECT AVG(Amount) FROM transactions)
AND Class = 1;

-------------------------------------------------------

-- checking time gap between transactions (possible fast fraud)
SELECT *
FROM (
    SELECT 
        Time,
        Amount,
        Class,
        Time - LAG(Time) OVER (ORDER BY Time) AS time_diff
    FROM transactions
) t
WHERE Class = 1
AND time_diff < 10;

-- observation: fraud often occurs in short time intervals

-------------------------------------------------------

-- creating a simple fraud scoring system
SELECT *,
    CASE WHEN Amount > 100 THEN 2 ELSE 0 END +
    CASE WHEN time_diff < 10 AND time_diff IS NOT NULL THEN 3 ELSE 0 END
AS fraud_score
FROM (
    SELECT 
        Time,
        Amount,
        Class,
        Time - LAG(Time) OVER (ORDER BY Time) AS time_diff
    FROM transactions
) t;

-- higher score = higher risk



