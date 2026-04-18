-- total number of transactions
SELECT COUNT(*) AS total_transactions
FROM transactions;

-- total fraud transactions
SELECT COUNT(*) AS fraud_transactions
FROM transactions
WHERE Class = 1;

-- fraud percentage in dataset
SELECT 
    COUNT(*) AS total,
    SUM(Class) AS fraud,
    (SUM(Class) * 100.0) / COUNT(*) AS fraud_percentage
FROM transactions;

-- fraud is very rare (~0.17%)

--------------------------------------------------

-- comparing fraud vs non-fraud transactions
SELECT 
    Class,
    COUNT(*) AS total_transactions,
    AVG(Amount) AS avg_amount,
    MAX(Amount) AS max_amount,
    MIN(Amount) AS min_amount
FROM transactions
GROUP BY Class;

-- fraud transactions usually have higher average amount

--------------------------------------------------

-- finding fraud transactions above average amount
SELECT *
FROM transactions
WHERE Amount > (
    SELECT AVG(Amount) FROM transactions
)
AND Class = 1;

--------------------------------------------------

-- checking fast fraud (transactions happening quickly)
SELECT *
FROM (
    SELECT 
        Time,
        Amount,
        Class,
        Time - LAG(Time) OVER (ORDER BY Time, Amount) AS time_diff
    FROM transactions
) t
WHERE Class = 1
AND time_diff < 10;

--------------------------------------------------

-- simple fraud scoring based on amount and time gap
SELECT *,
    CASE WHEN Amount > 100 THEN 2 ELSE 0 END +
    CASE WHEN time_diff < 10 AND time_diff IS NOT NULL THEN 3 ELSE 0 END
AS fraud_score
FROM (
    SELECT 
        Time,
        Amount,
        Class,
        LAG(Time) OVER (ORDER BY Time, Amount) AS prev_time,
        Time - LAG(Time) OVER (ORDER BY Time, Amount) AS time_diff
    FROM transactions
) t;

-- higher score = higher risk


