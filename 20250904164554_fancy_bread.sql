/*
  # Cohort Retention Analysis
  
  This script analyzes customer retention patterns using cohort analysis to understand:
  1. Customer retention rates over time
  2. Revenue retention by cohort
  3. Cohort performance comparison
  4. Seasonal retention patterns
  
  ## Required tables:
  - transactions: customer_id, transaction_date, amount
  
  ## Output:
  - Monthly cohort retention rates
  - Revenue retention analysis
  - Cohort performance metrics
*/

-- Step 1: Identify customer cohorts based on first purchase month
WITH customer_cohorts AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(transaction_date)) as cohort_month,
        MIN(transaction_date) as first_purchase_date
    FROM transactions
    WHERE amount > 0
    GROUP BY customer_id
),

-- Step 2: Get all customer transaction months
customer_activities AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', transaction_date) as transaction_month,
        SUM(amount) as monthly_revenue,
        COUNT(*) as monthly_transactions
    FROM transactions
    WHERE amount > 0
    GROUP BY customer_id, DATE_TRUNC('month', transaction_date)
),

-- Step 3: Combine cohort info with monthly activities
cohort_table AS (
    SELECT 
        c.customer_id,
        c.cohort_month,
        a.transaction_month,
        a.monthly_revenue,
        a.monthly_transactions,
        -- Calculate months since first purchase
        (EXTRACT(YEAR FROM a.transaction_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12 
        + (EXTRACT(MONTH FROM a.transaction_month) - EXTRACT(MONTH FROM c.cohort_month)) as period_number
    FROM customer_cohorts c
    LEFT JOIN customer_activities a ON c.customer_id = a.customer_id
    WHERE a.transaction_month IS NOT NULL
),

-- Step 4: Calculate cohort sizes
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) as total_customers
    FROM customer_cohorts
    GROUP BY cohort_month
),

-- Step 5: Calculate retention rates
retention_rates AS (
    SELECT 
        c.cohort_month,
        c.period_number,
        COUNT(DISTINCT c.customer_id) as active_customers,
        s.total_customers,
        ROUND(COUNT(DISTINCT c.customer_id) * 100.0 / s.total_customers, 2) as retention_rate
    FROM cohort_table c
    JOIN cohort_sizes s ON c.cohort_month = s.cohort_month
    WHERE c.period_number >= 0
    GROUP BY c.cohort_month, c.period_number, s.total_customers
)

-- Main retention rate table
SELECT 
    cohort_month,
    total_customers as cohort_size,
    period_number,
    active_customers,
    retention_rate
FROM retention_rates
ORDER BY cohort_month, period_number;

-- Pivot retention rates for easy analysis (showing first 12 months)
WITH retention_pivot_base AS (
    SELECT 
        cohort_month,
        total_customers,
        MAX(CASE WHEN period_number = 0 THEN retention_rate END) as month_0,
        MAX(CASE WHEN period_number = 1 THEN retention_rate END) as month_1,
        MAX(CASE WHEN period_number = 2 THEN retention_rate END) as month_2,
        MAX(CASE WHEN period_number = 3 THEN retention_rate END) as month_3,
        MAX(CASE WHEN period_number = 4 THEN retention_rate END) as month_4,
        MAX(CASE WHEN period_number = 5 THEN retention_rate END) as month_5,
        MAX(CASE WHEN period_number = 6 THEN retention_rate END) as month_6,
        MAX(CASE WHEN period_number = 7 THEN retention_rate END) as month_7,
        MAX(CASE WHEN period_number = 8 THEN retention_rate END) as month_8,
        MAX(CASE WHEN period_number = 9 THEN retention_rate END) as month_9,
        MAX(CASE WHEN period_number = 10 THEN retention_rate END) as month_10,
        MAX(CASE WHEN period_number = 11 THEN retention_rate END) as month_11
    FROM retention_rates
    GROUP BY cohort_month, total_customers
)

SELECT * FROM retention_pivot_base
ORDER BY cohort_month;

-- Average retention rates across all cohorts
WITH avg_retention AS (
    SELECT 
        period_number,
        ROUND(AVG(retention_rate), 2) as avg_retention_rate,
        COUNT(DISTINCT cohort_month) as cohorts_included
    FROM retention_rates
    WHERE period_number <= 12
    GROUP BY period_number
)

SELECT 
    period_number as months_after_first_purchase,
    avg_retention_rate,
    cohorts_included,
    -- Calculate retention drop-off
    LAG(avg_retention_rate) OVER (ORDER BY period_number) - avg_retention_rate as retention_drop
FROM avg_retention
ORDER BY period_number;

-- Revenue retention analysis
WITH revenue_cohorts AS (
    SELECT 
        c.cohort_month,
        c.period_number,
        SUM(c.monthly_revenue) as cohort_revenue,
        s.total_customers,
        -- Revenue per customer in cohort for this period
        ROUND(SUM(c.monthly_revenue) / s.total_customers, 2) as revenue_per_original_customer
    FROM cohort_table c
    JOIN cohort_sizes s ON c.cohort_month = s.cohort_month
    WHERE c.period_number >= 0
    GROUP BY c.cohort_month, c.period_number, s.total_customers
),

-- Calculate revenue retention compared to first month
revenue_retention AS (
    SELECT 
        cohort_month,
        period_number,
        cohort_revenue,
        revenue_per_original_customer,
        -- Compare to first month revenue to see retention
        FIRST_VALUE(revenue_per_original_customer) OVER (
            PARTITION BY cohort_month 
            ORDER BY period_number 
            ROWS UNBOUNDED PRECEDING
        ) as first_month_revenue_per_customer,
        ROUND(
            revenue_per_original_customer * 100.0 / 
            FIRST_VALUE(revenue_per_original_customer) OVER (
                PARTITION BY cohort_month 
                ORDER BY period_number 
                ROWS UNBOUNDED PRECEDING
            ), 2
        ) as revenue_retention_rate
    FROM revenue_cohorts
)

SELECT 
    cohort_month,
    period_number,
    cohort_revenue,
    revenue_per_original_customer,
    first_month_revenue_per_customer,
    revenue_retention_rate
FROM revenue_retention
WHERE period_number <= 12
ORDER BY cohort_month, period_number;

-- Cohort performance comparison
WITH cohort_performance AS (
    SELECT 
        c.cohort_month,
        s.total_customers,
        -- 3-month retention
        MAX(CASE WHEN c.period_number = 3 THEN c.retention_rate END) as retention_3m,
        -- 6-month retention  
        MAX(CASE WHEN c.period_number = 6 THEN c.retention_rate END) as retention_6m,
        -- 12-month retention
        MAX(CASE WHEN c.period_number = 12 THEN c.retention_rate END) as retention_12m,
        -- Total revenue generated by cohort
        ROUND(SUM(ct.monthly_revenue), 2) as total_cohort_revenue,
        -- Average revenue per customer
        ROUND(SUM(ct.monthly_revenue) / s.total_customers, 2) as avg_revenue_per_customer
    FROM retention_rates c
    JOIN cohort_sizes s ON c.cohort_month = s.cohort_month
    LEFT JOIN cohort_table ct ON c.cohort_month = ct.cohort_month
    GROUP BY c.cohort_month, s.total_customers
)

SELECT 
    cohort_month,
    total_customers,
    retention_3m,
    retention_6m, 
    retention_12m,
    total_cohort_revenue,
    avg_revenue_per_customer,
    -- Rank cohorts by performance
    RANK() OVER (ORDER BY retention_6m DESC) as retention_rank,
    RANK() OVER (ORDER BY avg_revenue_per_customer DESC) as revenue_rank
FROM cohort_performance
WHERE retention_3m IS NOT NULL
ORDER BY cohort_month;

-- Seasonal retention patterns
WITH seasonal_retention AS (
    SELECT 
        EXTRACT(QUARTER FROM cohort_month) as cohort_quarter,
        EXTRACT(MONTH FROM cohort_month) as cohort_month_num,
        period_number,
        AVG(retention_rate) as avg_retention_rate
    FROM retention_rates
    WHERE period_number IN (1, 3, 6, 12)
    GROUP BY 
        EXTRACT(QUARTER FROM cohort_month),
        EXTRACT(MONTH FROM cohort_month),
        period_number
)

SELECT 
    cohort_quarter,
    cohort_month_num,
    MAX(CASE WHEN period_number = 1 THEN avg_retention_rate END) as retention_1m,
    MAX(CASE WHEN period_number = 3 THEN avg_retention_rate END) as retention_3m,
    MAX(CASE WHEN period_number = 6 THEN avg_retention_rate END) as retention_6m,
    MAX(CASE WHEN period_number = 12 THEN avg_retention_rate END) as retention_12m
FROM seasonal_retention
GROUP BY cohort_quarter, cohort_month_num
ORDER BY cohort_quarter, cohort_month_num;

-- Executive Summary Statistics
SELECT 
    'Overall Retention Metrics' as metric_type,
    COUNT(DISTINCT cohort_month) as total_cohorts_analyzed,
    ROUND(AVG(CASE WHEN period_number = 1 THEN retention_rate END), 2) as avg_1_month_retention,
    ROUND(AVG(CASE WHEN period_number = 3 THEN retention_rate END), 2) as avg_3_month_retention,
    ROUND(AVG(CASE WHEN period_number = 6 THEN retention_rate END), 2) as avg_6_month_retention,
    ROUND(AVG(CASE WHEN period_number = 12 THEN retention_rate END), 2) as avg_12_month_retention
FROM retention_rates
WHERE period_number IN (1, 3, 6, 12);