"""
datetime_fix.py
---------------
Fixes SQLite datetime parsing issues after kernel restarts.

Problem: julianday() in SQLite requires datetime strings in a specific
format (YYYY-MM-DD HH:MM:SS). After a kernel restart in Jupyter,
datetime columns may be stored as non-standard strings that julianday()
cannot parse, causing date arithmetic queries to return zero or null.

Solution: Re-normalize datetime columns with pandas and re-persist to SQLite.

Run this before any query that uses julianday() date arithmetic.
"""

import pandas as pd


def normalize_datetimes(dfs_dict, datetime_cols):
    """
    Normalize datetime columns across multiple dataframes.

    Parameters:
        dfs_dict      : dict of {table_name: dataframe}
        datetime_cols : dict of {table_name: [col1, col2, ...]}

    Returns:
        dict of normalized dataframes
    """
    result = {}
    for table_name, df in dfs_dict.items():
        df = df.copy()
        cols = datetime_cols.get(table_name, [])
        for col in cols:
            if col in df.columns:
                df[col] = pd.to_datetime(df[col], format='mixed').astype(str)
                print(f"Normalized {table_name}.{col}")
        result[table_name] = df
    return result


# ── Usage in Jupyter ──────────────────────────────────────────────────────────
# from utils.datetime_fix import normalize_datetimes
#
# tables = {'sales': sales, 'clicks': clicks}
# cols   = {'sales': ['sale_datetime'], 'clicks': ['click_datetime']}
#
# normalized = normalize_datetimes(tables, cols)
# sales  = normalized['sales']
# clicks = normalized['clicks']
#
# %sql --persist-replace sales
# %sql --persist-replace clicks
# print("done")
