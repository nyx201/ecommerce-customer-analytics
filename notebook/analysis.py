import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
import warnings
warnings.filterwarnings('ignore')

# ── 1. Load data ──────────────────────────────────────────────
df = pd.read_csv('../data/processed/retail_clean.csv', parse_dates=['invoice_date'])
rfm = pd.read_csv('../data/processed/rfm_base.csv')

print(f"Transactions: {len(df):,}")
print(f"Unique customers: {df['customer_id'].nunique():,}")
print(f"Date range: {df['invoice_date'].min()} to {df['invoice_date'].max()}")

# ── 2. RFM Scoring ────────────────────────────────────────────
rfm['R_score'] = pd.qcut(rfm['recency_days'],  5, labels=[5,4,3,2,1])
rfm['F_score'] = pd.qcut(rfm['frequency'].rank(method='first'), 5, labels=[1,2,3,4,5])
rfm['M_score'] = pd.qcut(rfm['monetary'],      5, labels=[1,2,3,4,5])
rfm['RFM_score'] = rfm[['R_score','F_score','M_score']].astype(int).sum(axis=1)

# ── 3. Segment labeling ───────────────────────────────────────
def label_segment(score):
    if score >= 13:   return 'Champions'
    elif score >= 10: return 'Loyal Customers'
    elif score >= 7:  return 'At Risk'
    elif score >= 4:  return 'Hibernating'
    else:             return 'Lost'

rfm['Segment'] = rfm['RFM_score'].apply(label_segment)

# ── 4. K-Means clustering ─────────────────────────────────────
features = rfm[['recency_days','frequency','monetary']].copy()
scaler = StandardScaler()
scaled = scaler.fit_transform(features)

# Elbow method
inertia = []
K = range(2, 9)
for k in K:
    km = KMeans(n_clusters=k, random_state=42, n_init=10)
    km.fit(scaled)
    inertia.append(km.inertia_)

# Fit with optimal k=4
km = KMeans(n_clusters=4, random_state=42, n_init=10)
rfm['Cluster'] = km.fit_predict(scaled)

# Name clusters based on centroid characteristics
cluster_summary = rfm.groupby('Cluster').agg(
    Avg_Recency=('recency_days','mean'),
    Avg_Frequency=('frequency','mean'),
    Avg_Monetary=('monetary','mean'),
    Count=('customer_id','count')
).round(1)
print(cluster_summary)

# ── 5. Save outputs ───────────────────────────────────────────
rfm.to_csv('../data/processed/rfm_segmented.csv', index=False)

# ── 6. Visualizations ─────────────────────────────────────────
fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('RFM Customer Segmentation Analysis', fontsize=14, fontweight='bold')

# Segment distribution
seg_counts = rfm['Segment'].value_counts()
colors = ['#2E86AB','#A23B72','#F18F01','#C73E1D','#3B1F2B']
axes[0].bar(seg_counts.index, seg_counts.values, color=colors[:len(seg_counts)])
axes[0].set_title('Customers per Segment')
axes[0].set_ylabel('Count')
axes[0].tick_params(axis='x', rotation=30)

# Avg monetary by segment
seg_money = rfm.groupby('Segment')['monetary'].mean().sort_values(ascending=False)
axes[1].barh(seg_money.index, seg_money.values, color='#2E86AB')
axes[1].set_title('Avg Revenue by Segment')
axes[1].set_xlabel('Avg Revenue (£)')

# Elbow curve
axes[2].plot(K, inertia, marker='o', color='#A23B72')
axes[2].axvline(x=4, color='gray', linestyle='--', alpha=0.7)
axes[2].set_title('K-Means Elbow Curve')
axes[2].set_xlabel('Number of Clusters (k)')
axes[2].set_ylabel('Inertia')

plt.tight_layout()
plt.savefig('../report/rfm_analysis.png', dpi=150, bbox_inches='tight')
plt.show()

print("Done. Outputs saved.")
