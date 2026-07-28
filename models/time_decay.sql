-- ============================================================
-- TIME-DECAY ATTRIBUTION
-- More credit to touchpoints closer to conversion.
-- Credit halves every 7 days going backward from sale date.
-- Best for: short consideration cycles, promotional campaigns.
-- ============================================================
WITH touches_with_decay AS (
    SELECT
        s.sale_id,
        cl.channel_id,
        POWER(0.5,
            CAST((julianday(s.sale_datetime) - julianday(cl.click_datetime)) / 7.0 AS REAL)
        ) AS decay_weight
    FROM sales s
    JOIN clicks cl ON s.user_id = cl.user_id
    WHERE cl.click_datetime <= s.sale_datetime
),
normalized AS (
    SELECT sale_id, channel_id,
        decay_weight / SUM(decay_weight) OVER (PARTITION BY sale_id) AS credit
    FROM touches_with_decay
)
SELECT
    ac.category,
    ac.partner,
    ac.campaign,
    ROUND(SUM(n.credit), 2) AS attributed_sales,
    ROUND(SUM(n.credit) * 100.0 / SUM(SUM(n.credit)) OVER (), 2) AS pct_of_total
FROM normalized n
JOIN ad_channels ac ON n.channel_id = ac.channel_id
GROUP BY ac.category, ac.partner, ac.campaign
ORDER BY attributed_sales DESC;
