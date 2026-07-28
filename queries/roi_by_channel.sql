-- ============================================================
-- ROI BY CHANNEL CATEGORY
-- ROI = Gross Profit / Advertising Spend
--
-- Requires a profit table pre-computed in Python (profit_calc.py)
-- and persisted as 'sale_profit' with columns: sale_id, category, profit
-- ============================================================
SELECT
    sp.category,
    ROUND(SUM(sp.cat_spend), 2)   AS total_spend,
    ROUND(SUM(pr.cat_profit), 2)  AS total_profit,
    ROUND(SUM(pr.cat_profit) / SUM(sp.cat_spend), 2) AS roi
FROM (
    SELECT ac.category, SUM(s.spend) AS cat_spend
    FROM spend s
    JOIN ad_channels ac ON s.channel_id = ac.channel_id
    GROUP BY ac.category
) sp
JOIN (
    SELECT category, SUM(profit) AS cat_profit
    FROM sale_profit
    GROUP BY category
) pr ON sp.category = pr.category
GROUP BY sp.category
ORDER BY roi DESC;
