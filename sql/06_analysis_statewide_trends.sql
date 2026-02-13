-- 06_analysis_statewide_trends.sql
-- statewide funding mix trend (local/state/federal/other) over time

WITH yearly AS (
  SELECT
    year AS yr,
    SUM(total_revenue)  AS total_rev,
    SUM(local_revenue)  AS local_rev,
    SUM(state_revenue)  AS state_rev,
    SUM(federal_revenue) AS fed_rev
  FROM funding_fact
  WHERE year BETWEEN 2008 AND 2024
  GROUP BY year
)
SELECT
  yr AS year,
  total_rev AS statewide_total_revenue,
  local_rev AS statewide_local_revenue,
  state_rev AS statewide_state_revenue,
  fed_rev   AS statewide_federal_revenue,

  ROUND(1.0 * local_rev / NULLIF(total_rev, 0), 4) AS local_share,
  ROUND(1.0 * state_rev / NULLIF(total_rev, 0), 4) AS state_share,
  ROUND(1.0 * fed_rev   / NULLIF(total_rev, 0), 4) AS federal_share,

  ROUND(
    1.0 - (
      (1.0 * local_rev / NULLIF(total_rev, 0)) +
      (1.0 * state_rev / NULLIF(total_rev, 0)) +
      (1.0 * fed_rev   / NULLIF(total_rev, 0))
    ),
    4
  ) AS other_share,

  ROUND(
    (1.0 * local_rev / NULLIF(total_rev, 0)) +
    (1.0 * state_rev / NULLIF(total_rev, 0)) +
    (1.0 * fed_rev   / NULLIF(total_rev, 0)) +
    (
      1.0 - (
        (1.0 * local_rev / NULLIF(total_rev, 0)) +
        (1.0 * state_rev / NULLIF(total_rev, 0)) +
        (1.0 * fed_rev   / NULLIF(total_rev, 0))
      )
    ),
    4
  ) AS share_sum
FROM yearly
ORDER BY yr;
