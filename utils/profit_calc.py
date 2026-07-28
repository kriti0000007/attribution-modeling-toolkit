"""
profit_calc.py
--------------
Configurable profit calculation for e-commerce attribution analysis.

Built from Carvana case study. Adapt the bodystyle_rules and apr settings
to match your own business's margin and cost structure.

Required columns in sales dataframe:
  - avg_margin         : base profit margin per product (from product/vehicle table)
  - is_financed        : 1 if financed, 0 if not
  - apr                : annual percentage rate (null if not financed)
  - has_trade_in       : 1 if customer traded in a product
  - delivery_distance  : distance of delivery in miles
  - bodystyle          : product category (Sedan, SUV, Truck, etc.)
  - sale_datetime      : datetime of sale
"""

import pandas as pd
import numpy as np


def calculate_monthly_avg_apr(df, financed_col='is_financed', apr_col='apr', date_col='sale_datetime'):
    """Calculate monthly average APR from financed sales only."""
    df = df.copy()
    df['month'] = pd.to_datetime(df[date_col]).dt.to_period('M')
    monthly_avg = (
        df[df[financed_col] == 1]
        .groupby('month')[apr_col]
        .mean()
        .reset_index(name='monthly_avg_apr')
    )
    return df.merge(monthly_avg, on='month', how='left')


def apr_modifier(row, financed_col='is_financed', apr_col='apr', avg_apr_col='monthly_avg_apr'):
    """
    Calculate APR modifier per sale.
    Financed: percent difference from monthly average APR.
    Not financed: flat modifier of -0.1 (configurable below).
    """
    NOT_FINANCED_MODIFIER = -0.1  # change this to adjust unfinanced penalty

    if row[financed_col] == 1 and pd.notna(row[apr_col]):
        return (row[apr_col] - row[avg_apr_col]) / row[avg_apr_col]
    return NOT_FINANCED_MODIFIER


# Bodystyle rules — adapt these to your product categories
# Format: 'category_name': {'base_adj': X, 'distance_mult': Y, 'tradein_bonus': Z}
BODYSTYLE_RULES = {
    'Sedan':     {'base_adj': 200,  'distance_mult': 0.5, 'tradein_bonus': 400},
    'Hatchback': {'base_adj': 200,  'distance_mult': 0.5, 'tradein_bonus': 400},
    'Coupe':     {'base_adj': 0,    'distance_mult': 0.8, 'tradein_bonus': 300},
    'SUV':       {'base_adj': 0,    'distance_mult': 0.8, 'tradein_bonus': 300},
    'Truck':     {'base_adj': -200, 'distance_mult': 1.0, 'tradein_bonus': 200},
}


def calc_profit(row, bodystyle_col='bodystyle', distance_col='delivery_distance',
                tradein_col='has_trade_in', modified_val_col='mod_val'):
    """
    Apply bodystyle-specific adjustments to get final profit per sale.
    Extend BODYSTYLE_RULES above to add new product categories.
    """
    val = row[modified_val_col]
    bs  = str(row[bodystyle_col]).strip()
    d   = row[distance_col]
    ti  = row[tradein_col]

    rules = BODYSTYLE_RULES.get(bs)
    if rules:
        val += rules['base_adj']
        val -= d * rules['distance_mult']
        if ti == 1:
            val += rules['tradein_bonus']

    return val


def run_profit_pipeline(sales_df, products_df,
                        sales_product_keys=('make', 'model'),
                        product_margin_col='avg_margin',
                        product_category_col='bodystyle'):
    """
    Full profit calculation pipeline.

    Parameters:
        sales_df          : sales DataFrame
        products_df       : product DataFrame with margin and category
        sales_product_keys: columns to join sales to products
        product_margin_col: column name for base margin in products_df
        product_category_col: column name for product category in products_df

    Returns:
        sales_df with 'profit' column added
    """
    # Step 1: Join product info
    sv = sales_df.merge(
        products_df[[*sales_product_keys, product_category_col, product_margin_col]],
        on=list(sales_product_keys), how='left'
    )

    # Step 2: Calculate monthly avg APR
    sv = calculate_monthly_avg_apr(sv)

    # Step 3: APR modifier
    sv['apr_mod'] = sv.apply(apr_modifier, axis=1)

    # Step 4: Modified value
    sv['mod_val'] = sv[product_margin_col] * (1 + sv['apr_mod'])

    # Step 5: Bodystyle adjustments
    sv['profit'] = sv.apply(calc_profit, axis=1)

    return sv


# ── Example usage ─────────────────────────────────────────────────────────────
# import pandas as pd
# sales    = pd.read_csv('data/sales.csv')
# vehicles = pd.read_csv('data/vehicles.csv')
#
# result = run_profit_pipeline(sales, vehicles)
# print(result[['make','model','bodystyle','avg_margin','apr_mod','mod_val','profit']].head())
