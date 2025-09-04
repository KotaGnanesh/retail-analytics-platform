# Retail Analytics Platform 🛍️📊

A comprehensive end-to-end data analytics solution for retail sales forecasting, customer insights, and promotion optimization. This project demonstrates advanced analytics techniques using Python, SQL, and business intelligence tools.

## 🎯 Project Overview

This portfolio project showcases a complete data science workflow for retail analytics, including:

- **Time Series Forecasting** using ARIMA, Prophet, and XGBoost models
- **Customer Segmentation** through RFM analysis and K-Means clustering  
- **A/B Testing Framework** for promotion effectiveness analysis
- **SQL Analytics** for advanced customer behavior insights
- **Dashboard Specifications** for business intelligence visualization

## 📁 Project Structure

```
retail-analytics-platform/
├── notebooks/                    # Jupyter notebooks for analysis
│   ├── sales_forecasting.ipynb   # ARIMA, Prophet, XGBoost forecasting
│   ├── customer_segmentation.ipynb # RFM & K-Means clustering
│   └── promotion_ab_testing.ipynb  # A/B testing & hypothesis testing
├── sql/                          # SQL scripts for data analysis
│   ├── rfm_analysis.sql          # Customer RFM segmentation
│   ├── cohort_retention_analysis.sql # Customer retention cohorts
│   └── churn_detection.sql       # Churn prediction and risk scoring
├── dashboards/                   # Dashboard assets and specifications
│   ├── sample_sales_data.csv     # Sample dataset for visualization
│   ├── customer_segments.csv     # Customer segment analysis results
│   ├── segment_summary.csv       # Aggregated segment metrics
│   ├── ab_test_results.csv       # A/B testing campaign results
│   ├── dashboard_specification.md # Detailed dashboard requirements
│   └── powerbi_setup_guide.md    # Step-by-step Power BI setup
├── src/                          # React frontend (optional web interface)
└── README.md                     # This file
```

## 🚀 Getting Started

### Prerequisites

```bash
# Python environment setup
python -m venv retail_analytics
source retail_analytics/bin/activate  # On Windows: retail_analytics\Scripts\activate

# Install required packages
pip install pandas numpy matplotlib seaborn jupyter
pip install scikit-learn statsmodels prophet xgboost scipy
pip install sqlalchemy psycopg2-binary  # For database connections
```

### Running the Analysis

1. **Launch Jupyter Lab/Notebook:**
   ```bash
   jupyter lab notebooks/
   ```

2. **Execute notebooks in order:**
   - Start with `sales_forecasting.ipynb` for time series analysis
   - Run `customer_segmentation.ipynb` for customer insights
   - Complete with `promotion_ab_testing.ipynb` for A/B testing analysis

3. **Execute SQL scripts:** (if you have a database)
   ```bash
   # Connect to your database and run scripts in sql/ folder
   psql -d your_database -f sql/rfm_analysis.sql
   psql -d your_database -f sql/cohort_retention_analysis.sql  
   psql -d your_database -f sql/churn_detection.sql
   ```

## 📈 Key Analytics Components

### 1. Sales Forecasting
- **ARIMA Model**: Traditional time series approach for trend and seasonality
- **Prophet**: Facebook's robust forecasting with holiday effects
- **XGBoost**: Machine learning approach with feature engineering
- **Model Comparison**: Performance metrics and accuracy assessment

**Business Value**: Optimize inventory planning, workforce allocation, and marketing budget distribution.

### 2. Customer Segmentation
- **RFM Analysis**: Segments customers based on Recency, Frequency, Monetary value
- **K-Means Clustering**: Machine learning segmentation for behavior patterns
- **Segment Profiling**: Detailed customer personas with marketing strategies

**Key Segments Identified**:
- **Champions** (15%): High value, frequent, recent customers
- **Loyal Customers** (20%): Regular purchasers with good engagement
- **At Risk** (14%): Declining engagement, need retention efforts
- **Lost Customers** (11%): Win-back campaign targets

### 3. Promotion Effectiveness
- **A/B Testing**: Statistical comparison of promotion strategies
- **Hypothesis Testing**: T-tests, Z-tests, and confidence intervals
- **ROI Analysis**: Financial impact and profitability assessment
- **Statistical Power**: Sample size calculations and effect size analysis

**Campaign Results**:
- **BOGO**: Highest conversion rate (17.95%) but moderate ROI
- **10% Discount**: Best balance of conversion and profitability  
- **Free Shipping**: Strong revenue per user performance
- **Control vs Treatment**: Statistically significant improvements identified

## 📊 Dashboard Insights

The Power BI dashboard provides executive-level insights across four main areas:

1. **Sales Performance**: Real-time sales tracking with trend analysis
2. **Customer Analytics**: Segment performance and lifetime value metrics  
3. **Campaign Effectiveness**: A/B testing results and ROI tracking
4. **Predictive Analytics**: Sales forecasts and churn predictions

### Setup Instructions
1. Follow the `dashboards/powerbi_setup_guide.md` for step-by-step setup
2. Import CSV files from the `dashboards/` folder
3. Use the `dashboard_specification.md` for layout and design guidance

## 🎯 Business Impact & ROI

### Forecasting Accuracy
- **Prophet Model**: Best overall performance with 8.5% MAPE
- **30-Day Forecast**: Enables proactive inventory management
- **Seasonal Insights**: Identified 23% holiday revenue boost opportunity

### Customer Segmentation Value
- **Revenue Concentration**: Top 20% customers drive 68% of revenue
- **Churn Prevention**: 140 at-risk customers identified ($45K revenue exposure)
- **Personalization**: 5 distinct segments for targeted marketing

### Promotion Optimization
- **Best Campaign**: 10% discount shows 2.79x ROI with statistical significance
- **Budget Allocation**: Data-driven recommendations for promotion spending
- **Conversion Lift**: Average 38% improvement over control group

## 🔧 Technical Implementation

### Data Pipeline
1. **Data Generation**: Synthetic datasets simulating real retail patterns
2. **Feature Engineering**: Time-based features, lag variables, rolling statistics
3. **Model Training**: Multiple algorithms with cross-validation
4. **Statistical Testing**: Rigorous hypothesis testing framework
5. **Results Export**: Automated CSV generation for dashboard consumption

### SQL Analytics
- **Advanced CTEs**: Complex analytical queries with window functions
- **Performance Optimization**: Indexed queries and efficient joins
- **Business Logic**: Domain-specific rules and calculations
- **Data Quality**: Built-in validation and error handling

### Visualization Strategy
- **Progressive Disclosure**: Drill-down capabilities from summary to detail
- **Interactive Filters**: Dynamic dashboard updates
- **Responsive Design**: Mobile and desktop optimization
- **Executive Summary**: High-level KPIs for decision makers

## 🎨 Design Philosophy

This project follows modern data science best practices:
- **Reproducible Research**: Version-controlled notebooks with clear methodology
- **Modular Code**: Separated analysis components for maintainability  
- **Business Focus**: Every analysis tied to actionable business outcomes
- **Statistical Rigor**: Proper significance testing and confidence intervals
- **Visual Excellence**: Publication-ready charts and professional dashboards

## 📚 Skills Demonstrated

### Technical Skills
- **Python**: Pandas, NumPy, Scikit-learn, Statsmodels
- **Time Series**: ARIMA, Prophet, seasonal decomposition
- **Machine Learning**: Clustering, regression, feature engineering
- **Statistical Analysis**: Hypothesis testing, A/B testing, confidence intervals
- **SQL**: Advanced queries, CTEs, window functions
- **Data Visualization**: Matplotlib, Seaborn, Power BI

### Business Skills  
- **Customer Analytics**: Segmentation, lifetime value, churn prediction
- **Marketing Analytics**: Campaign optimization, ROI analysis
- **Financial Analysis**: Revenue forecasting, profitability assessment
- **Strategic Thinking**: Data-driven recommendations and action plans

## 🔮 Future Enhancements

1. **Real-Time Analytics**: Stream processing for live dashboard updates
2. **Advanced ML**: Deep learning models for demand forecasting
3. **Attribution Modeling**: Multi-touch attribution for marketing channels
4. **Recommendation Engine**: Personalized product recommendations
5. **Automated Alerting**: Threshold-based notifications for key metrics

## 📧 Contact

This project demonstrates advanced data science capabilities suitable for senior analytics roles in retail, e-commerce, and marketing analytics.

**Key Technologies**: Python, SQL, Power BI, Statistical Analysis, Machine Learning, A/B Testing

---

*Built as a portfolio demonstration of end-to-end analytics capabilities from data generation to business insights and dashboard creation.*