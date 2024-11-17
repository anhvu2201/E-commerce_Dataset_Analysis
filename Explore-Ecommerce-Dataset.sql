-- Q1
SELECT
    format_date('%Y%m',PARSE_DATE('%Y%m%d', date) ) month
    ,SUM(totals.visits) visits
    ,SUM(totals.pageviews) pageviews
    ,SUM(totals.transactions) transactions
FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE 
    date BETWEEN '20170101' AND '20170331'
GROUP BY 
    month
ORDER BY 
    month;

-- Q2
SELECT 
    trafficSource.source source
    ,SUM(totals.visits) visits
    ,SUM(totals.bounces) total_no_of_bounces
    ,ROUND((SUM(totals.bounces) / SUM(totals.visits)) *100,3) bounce_rate
FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY 
    trafficSource.source
ORDER BY 
    visits desc;

-- Q3
SELECT
    'Month' time_type
    , format_date('%Y%m',PARSE_DATE('%Y%m%d', date) ) time
    , trafficSource.source source
    , ROUND (SUM ((product.productRevenue) / 1000000),4) revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
    ,UNNEST (hits) hits,
    UNNEST (hits.product) product
WHERE product.productRevenue is not null
GROUP BY source, time

UNION ALL

SELECT
    'Week' time_type
    , format_date('%Y%W',PARSE_DATE('%Y%m%d', date) ) time
    , trafficSource.source source
    , ROUND (SUM ((product.productRevenue) / 1000000),4) revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
    ,UNNEST (hits) hits,
    UNNEST (hits.product) product
WHERE product.productRevenue is not null
GROUP BY source, time
Order by revenue desc;

-- Q4
WITH 
purchaser_data AS(
  SELECT
      FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month,
      (SUM(totals.pageviews)/COUNT(DISTINCT fullvisitorid)) AS avg_pageviews_purchase,
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) hits
    ,UNNEST(product) product
  WHERE _table_suffix BETWEEN '0601' AND '0731'
  AND totals.transactions>=1
  AND product.productRevenue IS NOT NULL
  GROUP BY month
),

non_purchaser_data AS(
  SELECT
      FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month,
      SUM(totals.pageviews)/COUNT(DISTINCT fullvisitorid) AS avg_pageviews_non_purchase,
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      ,UNNEST(hits) hits
    ,UNNEST(product) product
  WHERE _table_suffix BETWEEN '0601' AND '0731'
  AND totals.transactions IS NULL
  AND product.productRevenue IS NULL
  GROUP BY month
)

SELECT
    pd.*,
    avg_pageviews_non_purchase
FROM purchaser_data pd
FULL JOIN non_purchaser_data USING(month)
ORDER BY pd.month;

-- Q5
SELECT
    format_date('%Y%m',PARSE_DATE('%Y%m%d', date) ) Month
    , sum(totals.transactions) / count (distinct (fullVisitorId)) Avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,UNNEST (hits) hits,
    UNNEST (hits.product) product
WHERE totals.transactions >= 1 
  and product.productRevenue is not null
  and _table_suffix between '01' and '31'
GROUP BY month;

-- Q6
SELECT
    format_date('%Y%m',PARSE_DATE('%Y%m%d', date) ) Month
    , ROUND ((sum(product.productRevenue) / sum(totals.visits) / 1000000),2) avg_revenue_by_user_per_visit
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,UNNEST (hits) hits,
    UNNEST (hits.product) product
WHERE totals.transactions is not null 
    and product.productRevenue is not null
    and _table_suffix between '01' and '31'
GROUP BY month;

-- Q7
With customers_who_purchased_henley as (
SELECT DISTINCT fullVisitorId
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,UNNEST (hits) hits,
    UNNEST (hits.product) product
WHERE   
     product.v2ProductName = "YouTube Men's Vintage Henley"
    and _table_suffix between '01' and '31'
    and totals.transactions is not null
    and product.productRevenue is not null
)
SELECT 
    product.v2ProductName other_purchased_products,
    sum(product.productQuantity) quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,UNNEST (hits) hits,
    UNNEST (hits.product) product
INNER JOIN customers_who_purchased_henley
USING (fullVisitorId)
WHERE 
    product.v2ProductName <> "YouTube Men's Vintage Henley"
    and _table_suffix between '01' and '31'
    and totals.transactions is not null
    and product.productRevenue is not null
GROUP BY other_purchased_products
ORDER BY quantity DESC;

-- Q8
WITH product_data AS(
SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
    COUNT(CASE WHEN eCommerceAction.action_type = '2' THEN product.v2ProductName END) AS num_product_view,
    COUNT(CASE WHEN eCommerceAction.action_type = '3' THEN product.v2ProductName END) AS num_add_to_cart,
    COUNT(CASE WHEN eCommerceAction.action_type = '6' AND product.productRevenue IS NOT NULL THEN product.v2ProductName END) AS num_purchase
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
,UNNEST(hits) AS hits
,UNNEST (hits.product) AS product
WHERE _table_suffix BETWEEN '20170101' AND '20170331'
AND eCommerceAction.action_type IN ('2','3','6')
GROUP BY month
ORDER BY month
)

SELECT
    *,
    ROUND(num_add_to_cart/num_product_view * 100, 2) AS add_to_cart_rate,
    ROUND(num_purchase/num_product_view * 100, 2) AS purchase_rate
FROM product_data;