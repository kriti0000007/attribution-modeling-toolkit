-- ============================================================
-- LAST-TOUCH ATTRIBUTION
-- 100% credit to the last channel clicked before conversion.
-- Best for: measuring which channels close the most sales.
-- Limitation: ignores awareness and consideration channels.
-- ============================================================
WITH last_touch AS (
    SELECT s.sale_id, s.user_id, cl.channel_id AS lt_channel_id
    FROM sales s
    JOIN clicks cl ON s.user_id = cl.user_id
    WHERE cl.click_datetime <= s.sale_datetime
    AND cl.click_datetime = (
        SELECT MAX(cl2.click_datetime)
        FROM clicks cl2
        WHERE cl2.user_id = s.user_id
        AND cl2.click_datetime <= s.sale_datetime
    )
)
SELECT
    ac.category,
    ac.partner,
    ac.campaign,
    COUNT(lt.sale_id) AS attributed_sales,
    ROUND(COUNT(lt.sale_id) * 100.0 / SUM(COUNT(lt.sale_id)) OVER (), 2) AS pct_of_total
FROM last_touch lt
JOIN ad_channels ac ON lt.lt_channel_id = ac.channel_id
GROUP BY ac.category, ac.partner, ac.campaign
ORDER BY attributed_sales DESC;
