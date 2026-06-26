# E-Commerce Customer Analytics
**Brazilian E-Commerce Analysis using SQL, Python and Power BI**

## Tools Used
- MySQL Workbench (data cleaning and aggregation)
- Python / Google Colab (EDA, RFM analysis, K-Means clustering)
- Power BI Desktop (interactive dashboard)

## Dataset
Olist Brazilian E-Commerce Public Dataset (Kaggle)
- 100,000 orders from 2016 to 2018
- 9 relational tables covering orders, customers, products, payments and sellers
- Download: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Raw data not uploaded due to file size. Place CSVs in data/raw/ after downloading.

## Project Structure
- `MySQL/` - Complete SQL script for data cleaning and business metrics
- `notebook/` - Python notebook with EDA, RFM scoring and K-Means clustering
- `powerbi/` - Power BI dashboard screenshots
- `report/` - Python generated charts and visualizations
- `data/` - Processed CSV exports from MySQL

## Key Findings
- Total revenue of R$13.4M across 92,850 orders from 2016 to 2018
- Credit card is the dominant payment method at 73.9% of all transactions
- 41.3% of customers are At Risk of churning, representing a major retention problem
- Champions (top 8% of customers) spend 11x more than Lost customers (R$296 vs R$26)
- Beauty and health is the top revenue category, followed by watches and gifts
- Every customer placed exactly one order, indicating zero repeat purchase rate

## Business Recommendations
- Launch a re-engagement campaign targeting the 38,344 At Risk customers
- Introduce a loyalty program to convert Loyal customers into Champions
- Focus marketing spend on Beauty, Electronics and Home categories
- Incentivize repeat purchases since 100% of customers are one-time buyers

## Methodology
1. Imported 6 relational tables into MySQL (500K+ rows total)
2. Cleaned and filtered data using SQL, keeping only delivered orders
3. Built RFM scoring model in Python to segment 92,850 customers
4. Applied K-Means clustering (k=4) to identify behavioral clusters
5. Visualized findings in a 4-page interactive Power BI dashboard
