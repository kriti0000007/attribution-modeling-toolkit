-- ============================================================
-- COST PER CLICK BY CHANNEL CATEGORY
-- CPC = Total Spend / Total Clicks
--
-- IMPORTANT: spend and clicks must be aggregated separately
-- before joining. Spend has one row per day per channel.
-- Joining directly inflates spend by the number of click rows.
-- ============================================================
SELECT
    ac.category,
    SUM(s.total_spend)  AS total_spend,
    SUM(c.total_clicks) AS total_clicks,
    ROUND(SUM(s.total_spend) / SUM(c.total_clicks), 2) AS cpc
FROM (
    SELECT channel_id, SUM(spend) AS total_spend
    FROM spend
    GROUP BY channel_id
) s
JOIN (
    SELECT channel_id, COUNT(*) AS total_clicks
    FROM clicks
    GROUP BY channel_id
) c ON s.channel_id = c.channel_id
JOIN ad_channels ac ON s.channel_id = ac.channel_id
GROUP BY ac.category
ORDER BY cpc ASC;
