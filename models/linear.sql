-- ============================================================
-- LINEAR ATTRIBUTION
-- Equal credit distributed across all touchpoints per journey.
-- Best for: balanced view when all channels contribute equally.
-- ============================================================
WITH user_touches AS (
    SELECT
        s.sale_id,
        cl.channel_id,
        COUNT(*) OVER (PARTITION BY s.sale_id) AS total_touches
    FROM sales s
    JOIN clicks cl ON s.user_id = cl.user_id
    WHERE cl.click_datetime <= s.sale_datetime
),
linear_credit AS (
    SELECT sale_id, channel_id,
        1.0 / total_touches AS credit
    FROM user_touches
)
SELECT
    ac.category,
    ac.partner,
    ac.campaign,
    ROUND(SUM(lc.credit), 2) AS attributed_sales,
    ROUND(SUM(lc.credit) * 100.0 / SUM(SUM(lc.credit)) OVER (), 2) AS pct_of_total
FROM linear_credit lc
JOIN ad_channels ac ON lc.channel_id = ac.channel_id
GROUP BY ac.category, ac.partner, ac.campaign
ORDER BY attributed_sales DESC;
