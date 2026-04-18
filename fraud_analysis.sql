SELECT COUNT(*) AS total_transactions
FROM transactions;

SELECT COUNT(*) FROM transactions;

SELECT COUNT(*) AS fraud_transactions
FROM transactions
WHERE Class = 1;

SELECT 
    COUNT(*) AS total,
    SUM(Class) AS fraud,
    (SUM(Class) * 100.0) / COUNT(*) AS fraud_percentage
FROM transactions;
/*Fraud transactions are extremely rare (~0.17%), 
indicating a highly imbalanced dataset 
where detecting fraud is challenging.*/

SELECT 
    Class,
    COUNT(*) AS total_transactions,
    AVG(Amount) AS avg_amount,
    MAX(Amount) AS max_amount,
    MIN(Amount) AS min_amount
FROM transactions
GROUP BY Class;
/*Fraudulent transactions tend to have a higher 
average transaction value (~122) compared to normal 
transactions (~88), indicating that fraudsters 
often attempt higher-value transactions.*/

SELECT *
FROM transactions
WHERE Amount > (
    SELECT AVG(Amount) FROM transactions
)
AND Class = 1;


--fast fraud--
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



