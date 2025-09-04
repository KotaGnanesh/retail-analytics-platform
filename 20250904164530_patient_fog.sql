/*
  # RFM Analysis SQL Script
  
  This script performs Recency, Frequency, and Monetary analysis on customer transaction data.
  
  ## What this script does:
  1. Calculates RFM metrics for each customer
  2. Creates RFM scores using quintile ranking
  3. Segments customers based on RFM scores
  4. Generates summary statistics by segment
  
  ## Required tables:
  - transactions: customer_id, transaction_date, amount
  
  ## Output:
  - Customer-level RFM scores and segments
  - Segment summary statistics
*/

-- Step 1: Calculate base RFM metrics
WITH rfm_base AS (
    SELECT 
        customer_id,
        MAX(transaction_date) as last_purchase_date,
        COUNT(DISTINCT transaction_date) as frequency,
        SUM(amount) as monetary_value,
        -- Calculate recency in days from the most recent transaction in dataset
        (SELECT MAX(transaction_date) FROM transactions) - MAX(transaction_date) as recency_days
    FROM transactions 
    WHERE amount > 0 
    GROUP BY customer_id
),

-- Step 2: Add recency calculation
rfm_with_recency AS (
    SELECT *,
        EXTRACT(DAY FROM recency_days) as recency
    FROM rfm_base
),

-- Step 3: Calculate RFM scores using quintiles
rfm_scores AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary_value,
        last_purchase_date,
        -- Recency score (lower recency = higher score)
        NTILE(5) OVER (ORDER BY recency DESC) as recency_score,
        -- Frequency score (higher frequency = higher score)  
        NTILE(5) OVER (ORDER BY frequency ASC) as frequency_score,
        -- Monetary score (higher monetary = higher score)
        NTILE(5) OVER (ORDER BY monetary_value ASC) as monetary_score
    FROM rfm_with_recency
),

-- Step 4: Create combined RFM score and segments
rfm_segments AS (
    SELECT 
        *,
        -- Combined RFM score
        CAST(recency_score AS VARCHAR) || 
        CAST(frequency_score AS VARCHAR) || 
        CAST(monetary_score AS VARCHAR) as rfm_score,
        
        -- Business segment classification
        CASE 
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 
                THEN 'Champions'
            WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 
                THEN 'Loyal Customers'
            WHEN recency_score >= 4 AND frequency_score <= 2 
                THEN 'New Customers'
            WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score <= 2 
                THEN 'Potential Loyalists'
            WHEN recency_score <= 2 AND frequency_score >= 3 
                THEN 'At Risk'
            WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score <= 2 
                THEN 'Lost Customers'
            WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score >= 3 
                THEN 'Cannot Lose Them'
            WHEN recency_score >= 3 AND frequency_score <= 2 AND monetary_score <= 2 
                THEN 'Promising'
            ELSE 'Others'
        END as customer_segment
    FROM rfm_scores
)

-- Final output: Customer RFM analysis
SELECT 
    customer_id,
    recency,
    frequency, 
    monetary_value,
    last_purchase_date,
    recency_score,
    frequency_score,
    monetary_score,
    rfm_score,
    customer_segment,
    -- Calculate customer lifetime value estimate
    ROUND(monetary_value * (365.0 / NULLIF(recency, 0)) * 2, 2) as estimated_clv
FROM rfm_segments
ORDER BY monetary_value DESC;

-- Segment Summary Statistics
WITH segment_stats AS (
    SELECT 
        customer_segment,
        COUNT(*) as customer_count,
        ROUND(AVG(recency), 1) as avg_recency,
        ROUND(AVG(frequency), 1) as avg_frequency,
        ROUND(AVG(monetary_value), 2) as avg_monetary,
        ROUND(SUM(monetary_value), 2) as total_revenue,
        ROUND(AVG(monetary_value * (365.0 / NULLIF(recency, 0)) * 2), 2) as avg_clv
    FROM rfm_segments
    GROUP BY customer_segment
),
total_customers AS (
    SELECT COUNT(*) as total_count, SUM(monetary_value) as total_revenue 
    FROM rfm_segments
)

SELECT 
    s.customer_segment,
    s.customer_count,
    ROUND(s.customer_count * 100.0 / t.total_count, 1) as percentage_of_customers,
    s.avg_recency,
    s.avg_frequency, 
    s.avg_monetary,
    s.total_revenue,
    ROUND(s.total_revenue * 100.0 / t.total_revenue, 1) as percentage_of_revenue,
    s.avg_clv,
    -- Marketing priority score (higher CLV + larger segment = higher priority)
    ROUND((s.avg_clv * s.customer_count / 1000), 2) as marketing_priority_score
FROM segment_stats s
CROSS JOIN total_customers t
ORDER BY s.total_revenue DESC;

-- Top customers by segment for targeted campaigns
SELECT 
    customer_segment,
    customer_id,
    recency,
    frequency,
    monetary_value,
    rfm_score,
    RANK() OVER (PARTITION BY customer_segment ORDER BY monetary_value DESC) as segment_rank
FROM rfm_segments
WHERE customer_segment IN ('Champions', 'Loyal Customers', 'Cannot Lose Them')
ORDER BY customer_segment, segment_rank
LIMIT 50;