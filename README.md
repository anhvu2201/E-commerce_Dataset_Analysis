# E-commerce Dataset Analysis
# I. Introduction

In this project, I will use SQL on Google [BigQuery](https://cloud.google.com/bigquery/) to explore an eCommerce business dataset, which is based on the Google Analytics public dataset.

# II. Dataset Exploration

There is 8 different queries in this project:

## Query 01: Calculate total visit, pageview, transaction and revenue of the business in January, February and March 2017, in order of month.

- SQL Code:

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
- Query Result:

			month	visits	pageviews	transactions
			201701	64694	257708		713
			201702	62192	233373		733
			201703	69931	259522		993
- Link To Result: [Link](https://drive.google.com/file/d/1TMId10oA9mxwMws7YoTywQspK7LW2il4/view?usp=sharing)
## Query 02: Bounce rate per traffic source in July 2017.

- SQL Code:

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
		    visits DESC;
- Query Result:

		source		visits	total_no_of_bounces	bounce_rate
		google		38400	19798			51.557
		(direct)		19891	8606			43.266
		youtube.com		6351	4238			66.73
		analytics.google.com	1972	1064			53.955
		Partners		1788	936			52.349
		m.facebook.com	669	430			64.275
		google.com		368	183			49.728
		dfa			302	124			41.06
		sites.google.com	230	97			42.174
- Link To Result: [Link](https://drive.google.com/file/d/1a_w1-Brkxmsx2encFke0t704Yj9s6BBB/view?usp=sharing)

## Query 03: Revenue contributed by traffic source calculated by week and by month in June 2017.

- SQL Code:

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
		Order by revenue DESC;
- Query Result:

		time_type	time	source		revenue
		Month		201706	(direct)	97333.6197
		Week		201724	(direct)	30908.9099
		Week		201725	(direct)	27295.3199
		Month		201706	google		18757.1799
		Week		201723	(direct)	17325.6799
		Week		201726	(direct)	14914.81
		Week		201724	google		9217.17
		Month		201706	dfa		8862.23
		Week		201722	(direct)	6888.9
		Week		201726	google		5330.57
- Link To Result: [Link](https://drive.google.com/file/d/1bIS2-TLoupKlBFz62ECcB00XLRxeOs8h/view?usp=sharing)


## Query 04: Average number of product pageviews categorized by purchaser type (purchasers and non-purchasers) in June and July 2017.

- SQL Code:

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
- Query Result:

		month		avg_pageviews_purchase	avg_pageviews_non_purchase
		201706	94.02050113895217	316.86558846341671
		201707	124.23755186721992	334.05655979568053
- Link To Result: [Link](https://drive.google.com/file/d/1XxcJESc57hGYPZOmuQ2H1o-DVRq1KB3x/view?usp=sharing)

## Query 05: Average number of transactions per user that made atleast a purchase in July 2017.

- SQL Code:

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
		- Query Result:
- Query Result:

		Month		Avg_total_transactions_per_user
		201707	4.16390041493776
- Link To Result: [Link](https://drive.google.com/file/d/15zB2NTqVZiVx8lGYxuZdN7dbbjSryRx8/view?usp=sharing)

## Query 06: Average amount of money spent per session in July 2017.

- SQL Code:

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
- Query Result:

		Month		avg_revenue_by_user_per_visit
		201707	43.86
- Link To Result: [Link](https://drive.google.com/file/d/1-YCR7yBo3gMGngwNUTfLfX58JoEOqeKQ/view?usp=sharing)

## Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017.

- SQL Code:

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
- Query Result:

		other_purchased_products				quantity
		Google Sunglasses					20
		Google Women's Vintage Hero Tee Black			7
		SPF-15 Slim & Slender Lip Balm			6
		Google Women's Short Sleeve Hero Tee Red Heather	4
		YouTube Men's Fleece Hoodie Black			3
		Google Men's Short Sleeve Badge Tee Charcoal		3
		Crunch Noise Dog Toy					2
		Android Wool Heather Cap Heather/Black		2
		YouTube Twill Cap					2
		Recycled Mouse Pad					2
- Link To Result: [Link](https://drive.google.com/file/d/1eWZoWVcLPy-2Uv4K1F_tjkrR7ZGE8hwi/view?usp=sharing)

## Query 08: Calculate cohort map from pageview to addtocart to purchase in the last 3 month.

- SQL Code:

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
- Query Result:

		month		num_product_view	num_add_to_cart	  num_purchase	add_to_cart_rate	purchase_rate
		201701	25787			7342		  2143		28.47			8.31
		201702	21489			7360		  2060		34.25			9.59
		201703	23549			8782		  2977		37.29			12.64
- Link To Result: [Link](https://drive.google.com/file/d/1MiMC9QuzYWLw_or2QZt60T7YqvYhmM1y/view?usp=sharing)

# III. Conclusion

- In conclusion, analyzing the eCommerce dataset using SQL on Google BigQuery has uncovered key insights into total visits, pageviews, transactions, bounce rate, and revenue by traffic source, which can drive more informed business decisions.
- By exploring the dataset, a deeper understanding of critical metrics is achieved, setting the foundation for further analysis. The next step will involve using visualization tools like Power BI or Tableau to highlight key trends and patterns.
- Overall, this project showcases the effectiveness of combining SQL with big data tools like Google BigQuery to derive actionable insights from extensive datasets, emphasizing the value of data-driven decision-making.

