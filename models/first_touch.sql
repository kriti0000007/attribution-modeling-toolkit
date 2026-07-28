-- ============================================================
-- FIRST-TOUCH ATTRIBUTION
-- 100% credit to the first channel a user ever clicked.
-- Best for: measuring which channels initiate the most journeys.
-- Limitation: ignores all subsequent touchpoints.
-- ============================================================
WITH first_touch AS (
    SELECT user_id, channel_id AS ft_channel_id
    FROM (
        SELECT user_id, channel_id,
            ROW_NUMBER() OVER (
                PARTITION BY user_id
                ORDER BY click_datetime ASC
            ) AS rn
        FROM clicks
    )
    WHERE rn = 1
)
SELECT
    ac.category,
    ac.partner,
    ac.campaign,
    COUNT(s.sale_id) AS attributed_sales,
    ROUND(COUNT(s.sale_id) * 100.0 / SUM(COUNT(s.sale_id)) OVER (), 2) AS pct_of_total
FROM sales s
JOIN first_touch ft ON s.user_id = ft.user_id
JOIN ad_channels ac ON ft.ft_channel_id = ac.channel_id
GROUP BY ac.category, ac.partner, ac.campaign
ORDER BY attributed_sales DESC;
