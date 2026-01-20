USE Brazilian; -- This command must be executed once to open a query window and connect to the database.
/* Step 1 */
/**************************************************************************************************************************************************************/
/******************************************************************** Table for analysis **********************************************************************/
/**************************************************************************************************************************************************************/

-- 1. RFM(Recency, Frequency, Monetary) Analysis Table
-- * The purchase date period is 2016-09-04 ~ 2018-10-17.(Recency calculation base date is 2018-10-17)
SELECT  MIN(order_purchase_timestamp) as MIN_order_purchase_timestamp
		,MAX(order_purchase_timestamp) as MAX_order_purchase_timestamp
  FROM  olist_orders_dataset;
  
-- * Edit → Preferences → SQL Editor → DBMS connection read time out interval (in seconds): 30 -> 100000
CREATE TABLE RFM_LISTS AS
(
SELECT  c.customer_unique_id
		,DATEDIFF('2018-10-17', MAX(order_purchase_timestamp)) AS recency -- * The last purchase date is 2018-10-17.(Recency calculation base date)
        ,COUNT(distinct o.order_id) AS frequency
        ,SUM(IFNULL(oi.price,0)) + SUM(IFNULL(oi.freight_value,0)) AS monetary -- * NULL + 1 = NULL, so convert to 0 if NULL with the IFULL function
  FROM  olist_orders_dataset AS o
  LEFT 
  JOIN  olist_order_items_dataset AS oi 
    ON  o.order_id = oi.order_id
  LEFT
  JOIN  olist_customers_dataset AS c
    ON  o.customer_id = c.customer_id
 WHERE  oi.order_id IS NOT NULL -- * Excluding orders of 755 that do not match.
 GROUP
    BY  1
);

-- * Check Table
SELECT  *
  FROM  RFM_LISTS
 WHERE  customer_unique_id = '004288347e5e88a27ded2bb23747066c';
 
-- recency: 276 / frequency: 2 / monetary: 354.37
SELECT  o.order_id
		,order_purchase_timestamp
        ,oi.price
        ,oi.freight_value
  FROM  olist_orders_dataset AS o
  LEFT 
  JOIN  olist_order_items_dataset AS oi 
    ON  o.order_id = oi.order_id
  LEFT
  JOIN  olist_customers_dataset AS c
    ON  o.customer_id = c.customer_id
 WHERE  c.customer_unique_id = '004288347e5e88a27ded2bb23747066c';
 
SELECT DATEDIFF('2018-10-17', '2018-01-14');
SELECT 229.99 +	21.1 + 87.9	+ 15.38;

-- NTILE: Evenly Divide Window Function
-- NTILE_recency
WITH NTILE_recency AS
(
SELECT  *
		,NTILE(10) OVER (ORDER BY recency) AS recency_segment
  FROM  RFM_LISTS
)
SELECT  recency_segment
		,MIN(recency) AS MIN_recency
        ,MAX(recency) AS MAX_recency
        ,COUNT(DISTINCT customer_unique_id) AS customer_cnt        
  FROM  NTILE_recency
 GROUP
    BY  1;

-- 95420
SELECT  COUNT(DISTINCT customer_unique_id) AS customer_cnt
  FROM  RFM_LISTS;

-- NTILE(10)
SELECT  95420 / 10;

-- NTILE_frequency
WITH NTILE_frequency AS
(
SELECT  *
		,NTILE(10) OVER (ORDER BY frequency) AS frequency_segment
  FROM  RFM_LISTS
)
SELECT  frequency_segment
		,MIN(frequency) AS MIN_frequency
        ,MAX(frequency) AS MAX_frequency
        ,COUNT(DISTINCT customer_unique_id) AS customer_cnt        
  FROM  NTILE_frequency
 GROUP
    BY  1;

SELECT  frequency
		,COUNT(DISTINCT customer_unique_id) AS customer_cnt
  FROM  RFM_LISTS
 GROUP
    BY  1;
    
-- NTILE_monetary
WITH NTILE_monetary AS
(
SELECT  *
		,NTILE(10) OVER (ORDER BY monetary) AS monetary_segment
  FROM  RFM_LISTS
)
SELECT  monetary_segment
		,MIN(monetary) AS NTILE_monetary
        ,MAX(monetary) AS NTILE_monetary
        ,COUNT(DISTINCT customer_unique_id) AS customer_cnt
  FROM  NTILE_monetary
 GROUP
    BY  1;    

/* Step 2 */
-- 2. Delivery Analysis Table
-- * Delivery completion means order_status is delivered.
SELECT  order_status
		,COUNT(DISTINCT order_id) AS order_count
  FROM  olist_orders_dataset
 GROUP
    BY  1
 ORDER
    BY  2 DESC;
    
CREATE TABLE DELIVERY_LISTS AS
(
WITH DELIVERED AS
(
SELECT  c.customer_unique_id
		,DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) as arrived_day
  FROM  olist_orders_dataset AS o
  INNER
  JOIN  olist_customers_dataset AS c
    ON  o.customer_id = c.customer_id
 WHERE  order_status = 'delivered'  
)
SELECT  customer_unique_id
		,AVG(arrived_day) AS AVG_arrived_day
  FROM  DELIVERED
 WHERE  arrived_day IS NOT NULL
 GROUP
    BY  1
);

-- * Check Table
SELECT  *
  FROM  DELIVERY_LISTS
 LIMIT  100; 

-- 3. Review Analysis Table
CREATE TABLE REVIEW_LISTS AS
(
SELECT  c.customer_unique_id
		,AVG(review_score) AS AVG_review_score
  FROM  olist_orders_dataset AS o
  INNER
  JOIN  olist_customers_dataset AS c
    ON  o.customer_id = c.customer_id
  INNER
  JOIN  olist_order_reviews_dataset AS ors
    on  o.order_id = ors.order_id
 WHERE  review_score IS NOT NULL
 GROUP
    BY  1
);
    
-- * Check Table
SELECT  *
  FROM  REVIEW_LISTS
 LIMIT  100;
 
/* Step 3 */ 
-- 4. Delivery & Review Analysis Table 
CREATE TABLE DELIVERY_REVIEW_SCORE_ORDER AS
(
WITH DELIVERY_REVIEW AS
(
SELECT  o.order_id
		,DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) as arrived_day
        ,ors.review_score
  FROM  olist_orders_dataset AS o
  INNER
  JOIN  olist_customers_dataset AS c
    ON  o.customer_id = c.customer_id
  INNER
  JOIN  olist_order_reviews_dataset AS ors
    on  o.order_id = ors.order_id    
 WHERE  order_status = 'delivered' 
)
SELECT  review_score
		,AVG(arrived_day) AS AVG_arrived_day
        ,COUNT(DISTINCT order_id) AS order_count
  FROM  DELIVERY_REVIEW
 WHERE  arrived_day IS NOT NULL
 GROUP
    BY  1
);

-- * Check Table
SELECT  *
  FROM  DELIVERY_REVIEW_SCORE_ORDER
 ORDER
    BY  1;

-- 5. Best order Category Table
CREATE TABLE ORDER_CATE_BY_CUSTOMER AS
(
SELECT  customer_unique_id
		,pct.product_category_name_english
        ,COUNT(distinct o.order_id) AS order_count
  FROM  olist_order_items_dataset AS oi 
  LEFT 
  JOIN  olist_orders_dataset AS o
    ON  oi.order_id = o.order_id 
  LEFT 
  JOIN  olist_products_dataset AS p 
    ON  oi.product_id = p.product_id
  LEFT 
  JOIN  product_category_name_translation AS pct 
    ON  p.product_category_name = pct.product_category_name
  INNER
  JOIN  olist_customers_dataset AS c
    ON  o.customer_id = c.customer_id
 GROUP
    BY  1,2
);

CREATE TABLE ORDER_CATE_BY_CUSTOMER_TOP_1 AS
(
SELECT  customer_unique_id
		,product_category_name_english
  FROM  (
		SELECT  *
				,ROW_NUMBER() OVER(PARTITION BY customer_unique_id ORDER BY order_count DESC) AS RK
          FROM  ORDER_CATE_BY_CUSTOMER
		)AS BASE
 WHERE  RK = 1
);

-- * Check Table
SELECT  *
  FROM  ORDER_CATE_BY_CUSTOMER_TOP_1
 LIMIT  10;
 
-- 6. Delivery Category Table 
CREATE TABLE DELIVERY_CATEGORY_ORDER AS 
(
WITH DELIVERY_BY_product_category_name AS
(
SELECT  o.order_id
		,pct.product_category_name_english
		,DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) as arrived_day
  FROM  olist_orders_dataset AS o
  INNER 
  JOIN  olist_order_items_dataset AS oi 
    ON  o.order_id = oi.order_id
  LEFT 
  JOIN  olist_products_dataset AS p 
    ON  oi.product_id = p.product_id
  LEFT 
  JOIN  product_category_name_translation AS pct 
    ON  p.product_category_name = pct.product_category_name
)
SELECT  product_category_name_english
		,AVG(arrived_day) AS AVG_arrived_day
  FROM  DELIVERY_BY_product_category_name
 GROUP
    BY  1
);

SELECT  *
  FROM  DELIVERY_CATEGORY_ORDER;