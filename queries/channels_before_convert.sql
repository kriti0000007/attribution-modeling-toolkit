-- ============================================================
-- AVERAGE DISTINCT CHANNELS BEFORE CONVERSION
-- Measures multi-touch behavior before a purchase or conversion.
--
-- CRITICAL: filter to clicks BEFORE or AT the conversion date.
-- Post-conversion clicks inflate the count and produce wrong results.
-- ============================================================
SELECT
    ROUND(AVG(n), 2)   AS avg_distinct_channels,
    MIN(n)             AS min_channels,
    MAX(n)             AS max_channels,
    COUNT(*)           AS total_journeys
FROM (
    SELECT
        cl.user_id,
        l.lock_id,
        COUNT(DISTINCT cl.channel_id) AS n
    FROM clicks cl
    JOIN locks l ON cl.user_id = l.user_id
    WHERE cl.click_datetime <= l.lock_datetime
    GROUP BY cl.user_id, l.lock_id
);
