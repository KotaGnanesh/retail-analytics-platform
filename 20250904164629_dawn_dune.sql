/*
  # Customer Churn Detection Analysis
  
  This script identifies customers at risk of churning and provides churn prediction metrics.
  
  ## What this script does:
  1. Defines churn based on business rules (no purchase in X days)
  2. Identifies at-risk customers using behavioral indicators
  3. Calculates churn probability scores
  4. Segments customers by churn risk
  5. Provides actionable insights for retention campaigns
  
  ## Business Rules:
  - Churned: No purchase in 90+ days
  - At Risk: No purchase in 45-89 days
  - Active: Purchase within 44 days
  
  ## Required tables:
  - transactions: customer_id, transaction_date, amount
  - customers: customer_id, registration_date, email (optional)
*/

-- Step 1: Calculate customer behavior metrics
WITH customer_behavior AS (
    SELECT 
        customer_id,
        MIN(transaction_date) as first_purchase_date,
        MAX(transaction_date) as last_purchase_date,
        COUNT(DISTINCT transaction_date) as total_transactions,
        COUNT(DISTINCT DATE_TRUNC('month', transaction_date)) as active_months,
        SUM(amount) as total_spent,
        ROUND(AVG(amount), 2) as avg_transaction_amount,
        ROUND(SUM(amount) / COUNT(DISTINCT transaction_date), 2) as avg_order_value,
        -- Days since last purchase
        CURRENT_DATE - MAX(transaction_date) as days_since_last_purchase,
        -- Customer tenure in days
        CURRENT_DATE - MIN(transaction_date) as customer_tenure_days,
        -- Purchase frequency (transactions per month)
        ROUND(
            COUNT(DISTINCT transaction_date) * 30.0 / 
            GREATEST(CURRENT_DATE - MIN(transaction_date), 1), 2
        ) as purchase_frequency_per_month
    FROM transactions
    WHERE amount > 0
    GROUP BY customer_id
),

-- Step 2: Add churn indicators and risk scoring
churn_analysis AS (
    SELECT 
        *,
        EXTRACT(DAY FROM days_since_last_purchase) as days_since_last_purchase_num,
        EXTRACT(DAY FROM customer_tenure_days) as customer_tenure_days_num,
        
        -- Churn status classification
        CASE 
            WHEN EXTRACT(DAY FROM days_since_last_purchase) >= 90 THEN 'Churned'
            WHEN EXTRACT(DAY FROM days_since_last_purchase) BETWEEN 45 AND 89 THEN 'At Risk'
            WHEN EXTRACT(DAY FROM days_since_last_purchase) BETWEEN 15 AND 44 THEN 'Declining'
            ELSE 'Active'
        END as churn_status,
        
        -- Risk factors (higher score = higher churn risk)
        (EXTRACT(DAY FROM days_since_last_purchase) / 90.0) * 30 +  -- Recency factor
        (CASE WHEN purchase_frequency_per_month < 0.5 THEN 20 ELSE 0 END) +  -- Low frequency
        (CASE WHEN avg_transaction_amount < 50 THEN 15 ELSE 0 END) +  -- Low value
        (CASE WHEN total_transactions <= 2 THEN 25 ELSE 0 END) +  -- New customer
        (CASE WHEN active_months <= 2 THEN 10 ELSE 0 END) as churn_risk_score
    FROM customer_behavior
),

-- Step 3: Create risk segments
risk_segments AS (
    SELECT 
        *,
        CASE 
            WHEN churn_risk_score >= 70 THEN 'Critical Risk'
            WHEN churn_risk_score >= 50 THEN 'High Risk'
            WHEN churn_risk_score >= 30 THEN 'Medium Risk'
            WHEN churn_risk_score >= 15 THEN 'Low Risk'
            ELSE 'Healthy'
        END as risk_segment,
        
        -- Churn probability (simplified model)
        ROUND(
            LEAST(churn_risk_score / 100.0, 0.95), 3
        ) as churn_probability
    FROM churn_analysis
)

-- Main output: Customer churn analysis
SELECT 
    customer_id,
    first_purchase_date,
    last_purchase_date,
    days_since_last_purchase_num as days_since_last_purchase,
    customer_tenure_days_num as customer_tenure_days,
    total_transactions,
    active_months,
    total_spent,
    avg_transaction_amount,
    avg_order_value,
    purchase_frequency_per_month,
    churn_status,
    risk_segment,
    churn_risk_score,
    churn_probability,
    
    -- Recommended action
    CASE 
        WHEN churn_status = 'Churned' THEN 'Win-back campaign'
        WHEN risk_segment = 'Critical Risk' THEN 'Immediate intervention'
        WHEN risk_segment = 'High Risk' THEN 'Retention campaign'
        WHEN risk_segment = 'Medium Risk' THEN 'Engagement increase'
        ELSE 'Standard communication'
    END as recommended_action
    
FROM risk_segments
ORDER BY churn_risk_score DESC, total_spent DESC;

-- Churn summary by status and risk segment
SELECT 
    churn_status,
    risk_segment,
    COUNT(*) as customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage,
    ROUND(AVG(total_spent), 2) as avg_total_spent,
    ROUND(SUM(total_spent), 2) as total_revenue_at_risk,
    ROUND(AVG(churn_probability), 3) as avg_churn_probability,
    ROUND(AVG(days_since_last_purchase_num), 1) as avg_days_since_purchase
FROM risk_segments
GROUP BY churn_status, risk_segment
ORDER BY 
    CASE churn_status 
        WHEN 'Active' THEN 1 
        WHEN 'Declining' THEN 2 
        WHEN 'At Risk' THEN 3 
        WHEN 'Churned' THEN 4 
    END,
    CASE risk_segment 
        WHEN 'Healthy' THEN 1 
        WHEN 'Low Risk' THEN 2 
        WHEN 'Medium Risk' THEN 3 
        WHEN 'High Risk' THEN 4 
        WHEN 'Critical Risk' THEN 5 
    END;

-- High-value customers at risk (priority for retention)
SELECT 
    customer_id,
    churn_status,
    risk_segment,
    total_spent,
    days_since_last_purchase_num,
    churn_probability,
    purchase_frequency_per_month,
    recommended_action,
    -- Calculate potential revenue loss
    ROUND(total_spent * churn_probability, 2) as potential_revenue_loss
FROM risk_segments
WHERE churn_status IN ('At Risk', 'Declining') 
    AND total_spent > 500  -- High value threshold
ORDER BY potential_revenue_loss DESC
LIMIT 100;

-- Churn prediction model features
WITH churn_features AS (
    SELECT 
        customer_id,
        -- Binary churn indicator (1 = churned, 0 = active)
        CASE WHEN churn_status = 'Churned' THEN 1 ELSE 0 END as is_churned,
        
        -- Normalized features for ML models
        ROUND((days_since_last_purchase_num - AVG(days_since_last_purchase_num) OVER()) / 
              STDDEV(days_since_last_purchase_num) OVER(), 3) as recency_zscore,
        
        ROUND((purchase_frequency_per_month - AVG(purchase_frequency_per_month) OVER()) / 
              STDDEV(purchase_frequency_per_month) OVER(), 3) as frequency_zscore,
        
        ROUND((total_spent - AVG(total_spent) OVER()) / 
              STDDEV(total_spent) OVER(), 3) as monetary_zscore,
        
        ROUND((customer_tenure_days_num - AVG(customer_tenure_days_num) OVER()) / 
              STDDEV(customer_tenure_days_num) OVER(), 3) as tenure_zscore,
        
        -- Behavioral features
        total_transactions,
        active_months,
        avg_transaction_amount,
        
        -- Interaction features
        total_transactions * purchase_frequency_per_month as transaction_frequency_interaction,
        total_spent / GREATEST(customer_tenure_days_num, 1) as spend_rate
        
    FROM risk_segments
)

SELECT * FROM churn_features
ORDER BY is_churned DESC, customer_id;

-- Monthly churn rate trend
WITH monthly_churn AS (
    SELECT 
        DATE_TRUNC('month', first_purchase_date) as acquisition_month,
        COUNT(*) as customers_acquired,
        SUM(CASE WHEN churn_status = 'Churned' THEN 1 ELSE 0 END) as customers_churned,
        ROUND(
            SUM(CASE WHEN churn_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
        ) as churn_rate
    FROM risk_segments
    WHERE first_purchase_date >= CURRENT_DATE - INTERVAL '24 months'
    GROUP BY DATE_TRUNC('month', first_purchase_date)
)

SELECT 
    acquisition_month,
    customers_acquired,
    customers_churned,
    churn_rate,
    -- Moving average churn rate
    ROUND(AVG(churn_rate) OVER (
        ORDER BY acquisition_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) as churn_rate_3month_avg
FROM monthly_churn
ORDER BY acquisition_month;

-- Action plan for at-risk customers
SELECT 
    'Churn Prevention Action Plan' as summary_type,
    SUM(CASE WHEN risk_segment = 'Critical Risk' THEN 1 ELSE 0 END) as critical_risk_customers,
    SUM(CASE WHEN risk_segment = 'High Risk' THEN 1 ELSE 0 END) as high_risk_customers,
    SUM(CASE WHEN churn_status = 'At Risk' THEN total_spent ELSE 0 END) as revenue_at_risk,
    ROUND(AVG(CASE WHEN churn_status != 'Churned' THEN churn_probability END), 3) as avg_churn_probability_active,
    COUNT(CASE WHEN churn_status = 'Churned' AND total_spent > 1000 THEN 1 END) as high_value_churned
FROM risk_segments;