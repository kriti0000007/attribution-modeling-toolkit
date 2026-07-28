-- ============================================================
-- CUSTOMER ACQUISITION COST BY PARTNER
-- CAC = Total Spend / First-Touch Attributed Sales
--
-- Uses first-touch attribution by default.
-- Swap the ft CTE for last_touch or linear to compare models.
-- ============================================================
WITH ft AS (
    SELECT user_id, channel_id AS ft_channel_id
    FROM (
        SELECT user_id, channel_id,
            ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY click_datetime) AS rn
        FROM clicks
    )
    WHERE rn = 1
),
spend_by_partner AS (
    SELECT ac.partner, SUM(s.spend) AS total_spend
    FROM spend s
    JOIN ad_channels ac ON s.channel_id = ac.channel_id
    GROUP BY ac.partner
),
sales_by_partner AS (
    SELECT ac.partner, COUNT(s.sale_id) AS num_sales
    FROM sales s
    JOIN ft ON s.user_id = ft.user_id
    JOIN ad_channels ac ON ft.ft_channel_id = ac.channel_id
    GROUP BY ac.partner
)
SELECT
    sl.partner,
    sl.num_sales,
    ROUND(sp.total_spend, 2)                AS total_spend,
    ROUND(sp.total_spend / sl.num_sales, 2) AS cac
FROM spend_by_partner sp
JOIN sales_by_partner sl ON sp.partner = sl.partner
ORDER BY cac ASC;
