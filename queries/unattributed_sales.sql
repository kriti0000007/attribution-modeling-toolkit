-- ============================================================
-- UNATTRIBUTED SALES — NO CLICK IN PRIOR N DAYS
-- Default window: 90 days. Change the BETWEEN clause to adjust.
--
-- julianday() converts datetime to a float number of days.
-- Subtracting two julianday values gives the gap in days.
--
-- NOTE: If result shows 0 sales_with_click, re-run the datetime
-- fix utility (utils/datetime_fix.py) to normalize string formats.
-- ============================================================
WITH sales_with_click AS (
    SELECT DISTINCT s.sale_id
    FROM sales s
    JOIN clicks cl ON s.user_id = cl.user_id
    WHERE CAST(
        (julianday(s.sale_datetime) - julianday(cl.click_datetime))
    AS INT) BETWEEN 0 AND 90   -- change 90 to adjust window
)
SELECT
    COUNT(DISTINCT s.sale_id)                                                AS total_sales,
    COUNT(DISTINCT swc.sale_id)                                              AS sales_with_click,
    COUNT(DISTINCT s.sale_id) - COUNT(DISTINCT swc.sale_id)                  AS unattributed_sales,
    ROUND(
        100.0 * (COUNT(DISTINCT s.sale_id) - COUNT(DISTINCT swc.sale_id))
        / COUNT(DISTINCT s.sale_id), 2
    )                                                                        AS pct_unattributed
FROM sales s
LEFT JOIN sales_with_click swc ON s.sale_id = swc.sale_id;
