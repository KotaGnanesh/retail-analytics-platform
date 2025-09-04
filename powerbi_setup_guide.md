# Power BI Dashboard Setup Guide

## Prerequisites
1. Power BI Desktop installed
2. Access to SQL database or CSV import capability
3. Sample data files from the `dashboards/` folder

## Quick Setup Steps

### 1. Data Import
```
File → Get Data → Text/CSV
```
Import these files in order:
- `sample_sales_data.csv`
- `customer_segments.csv`
- `segment_summary.csv`
- `ab_test_results.csv`

### 2. Data Relationships
Create relationships between tables:
- customer_segments[customer_id] ↔ ab_test_raw_data[customer_id]
- Use customer_id as the primary key

### 3. Calculated Measures

#### Sales Measures
```dax
Total Sales = SUM(sample_sales_data[sales])
Sales Growth MoM = 
VAR CurrentMonth = [Total Sales]
VAR PreviousMonth = CALCULATE([Total Sales], DATEADD(sample_sales_data[date], -1, MONTH))
RETURN DIVIDE(CurrentMonth - PreviousMonth, PreviousMonth)

Average Order Value = DIVIDE([Total Sales], COUNT(sample_sales_data[date]))
```

#### Customer Measures
```dax
Total Customers = DISTINCTCOUNT(customer_segments[customer_id])
Customer Lifetime Value = AVERAGE(customer_segments[monetary])
Churn Risk Customers = 
CALCULATE(
    COUNT(customer_segments[customer_id]),
    customer_segments[segment] = "At Risk"
)
```

#### A/B Testing Measures
```dax
Conversion Rate = 
DIVIDE(
    SUM(ab_test_results[total_conversions]),
    SUM(ab_test_results[total_users])
)

Campaign ROI = 
DIVIDE(
    SUM(ab_test_results[profit]),
    SUM(ab_test_results[total_cost])
)
```

### 4. Key Visualizations Setup

#### Sales Trend Chart
- Visualization: Line Chart
- X-axis: sample_sales_data[date]
- Y-axis: [Total Sales]
- Legend: sample_sales_data[product_category]

#### Customer Segment Treemap
- Visualization: Treemap
- Category: customer_segments[segment]
- Values: COUNT(customer_segments[customer_id])
- Color: AVERAGE(customer_segments[monetary])

#### Campaign Performance
- Visualization: Clustered Column Chart
- X-axis: ab_test_results[campaign]
- Y-axis: ab_test_results[conversion_rate]
- Secondary Y-axis: ab_test_results[roi]

### 5. Filters Configuration
Add these slicers to each page:
- Date range (sample_sales_data[date])
- Store location (sample_sales_data[store_location])
- Customer segment (customer_segments[segment])
- Campaign type (ab_test_results[campaign])

### 6. Conditional Formatting
Apply conditional formatting to:
- ROI values (Red < 0, Yellow 0-1, Green > 1)
- Churn risk scores (Heat map colors)
- Statistical significance indicators

## Advanced Features

### Dynamic Titles
```dax
Dynamic Title = 
"Sales Performance - " & FORMAT(MAX(sample_sales_data[date]), "MMMM YYYY")
```

### Trend Indicators
```dax
Sales Trend Icon = 
IF([Sales Growth MoM] > 0, "↗️", "↘️")
```

### Forecasting (if using Power BI Premium)
1. Enable forecasting on time series visuals
2. Set forecast period to 30 days
3. Configure confidence intervals

## Color Themes
Apply consistent branding:
- Primary: #2563EB
- Success: #16A34A  
- Warning: #D97706
- Danger: #DC2626
- Background: #F8FAFC

## Performance Optimization
1. Use DirectQuery for large datasets
2. Implement row-level security for multi-tenant scenarios
3. Create aggregation tables for faster rendering
4. Use composite models for mixed data sources

## Deployment Checklist
- [ ] All data sources connected
- [ ] Relationships established
- [ ] Calculated measures tested
- [ ] Visualizations formatted
- [ ] Filters applied
- [ ] Performance optimized
- [ ] Published to Power BI Service
- [ ] Scheduled refresh configured

## Troubleshooting
**Common Issues:**
- CSV encoding: Use UTF-8 encoding
- Date formats: Ensure consistent date formatting
- Missing relationships: Check data types match
- Slow performance: Reduce visual complexity or use aggregations

**Data Quality Checks:**
- Verify no negative sales values
- Check for duplicate customer IDs
- Validate date ranges
- Confirm conversion rates are within expected bounds (0-100%)