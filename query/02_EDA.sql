USE Brazilian; -- This command must be executed once to open a query window and connect to the database.

/* Setting */
-- Don't Limit
-- Edit → Preferences → SQL Editor → DBMS connection read time out interval (in seconds): 30 -> 100000

/* Step 1 */
/**************************************************************************************************************************************************************/
/************************************************************************ Tables Check ************************************************************************/
/**************************************************************************************************************************************************************/

-- 1. olist_order_items_dataset
SELECT * FROM olist_order_items_dataset LIMIT 10;

SELECT  * 
  FROM  olist_order_items_dataset
 WHERE  order_id in ('0006ec9db01a64e59a68b2c340bf65a7', '0008288aa423d2a3f00fcb17cd7d8719');

-- 2. olist_products_dataset
SELECT * FROM olist_products_dataset LIMIT 10;

-- 3. product_category_name_translation
SELECT * FROM product_category_name_translation LIMIT 10;

-- 4. olist_orders_dataset
-- * order_purchase_timestamp -> order_approved_at -> order_delivered_carrier_date -> order_delivered_customer_date
-- * order_estimated_delivery_date
SELECT * FROM olist_orders_dataset LIMIT 10;

-- 5. olist_order_reviews_dataset
SELECT * FROM olist_order_reviews_dataset LIMIT 10;

-- * rating ranging from 1 to 5
SELECT  distinct review_score
  FROM  olist_order_reviews_dataset
 ORDER
    BY  1;
  
-- 6. olist_order_payments_dataset
SELECT * FROM olist_order_payments_dataset LIMIT 10;

-- payment_value: 126.54
SELECT  *
  FROM  olist_order_payments_dataset
 WHERE  order_id = '0008288aa423d2a3f00fcb17cd7d8719';
  
SELECT  * 
  FROM  olist_order_items_dataset
 WHERE  order_id in ('0008288aa423d2a3f00fcb17cd7d8719');

-- 126.54  
SELECT  49.9 + 49.9 + 13.37 + 13.37;

WITH PAY_TOTAL AS
(
SELECT  order_id
		,SUM(payment_value) AS payment_value_total
  FROM  olist_order_payments_dataset
 GROUP
    BY  1
),
ORDER_ITEM_VALUE AS
(
SELECT  order_id
        ,SUM(oi.price) AS price_total
        ,SUM(oi.freight_value) AS freight_value_total
        ,SUM(IFNULL(oi.price,0)) + SUM(IFNULL(oi.freight_value,0)) AS value_total -- * NULL + 1 = NULL, so convert to 0 if NULL with the IFULL function
  FROM  olist_order_items_dataset AS oi 
 GROUP
    BY  1
)
SELECT  *
  FROM  PAY_TOTAL AS PT
  LEFT
  JOIN  ORDER_ITEM_VALUE AS OIV
    ON  PT.order_id = OIV.order_id
 WHERE  ROUND(payment_value_total,0) <> ROUND(value_total,0)
 LIMIT  10;

SELECT  *
  FROM  olist_order_payments_dataset
 WHERE  order_id = '051fcda88d997d3ff86012da2a556342';
  
SELECT  * 
  FROM  olist_order_items_dataset
 WHERE  order_id in ('051fcda88d997d3ff86012da2a556342');

SELECT  49 + 7.6;

-- 7. olist_sellers_dataset
SELECT * FROM olist_sellers_dataset LIMIT 10;

-- 8. olist_customers_dataset
SELECT * FROM olist_customers_dataset LIMIT 10;

SELECT  *
  FROM  olist_customers_dataset
 WHERE  customer_unique_id = '4c93744516667ad3b8f1fb645a3116a4';

SELECT  * 
  FROM  olist_orders_dataset
 WHERE  customer_id in ('879864dab9bc3047522c92c82e1212b8', '802bb9a59876a712f8380da8f297057c');


/* Step 2 */
/**************************************************************************************************************************************************************/
/******************************************************************** Tables Pattern Check ********************************************************************/
/**************************************************************************************************************************************************************/

-- 1. Check number of monthly orders
-- * There appears to be data loss.(2016.9~12 / 2018.9~10)
SELECT  date_format(order_purchase_timestamp, '%Y-%m') as YM
        ,count(distinct order_id) as order_count
  FROM  olist_orders_dataset
 GROUP
    BY  1
 ORDER
    BY  1;

-- 2. olist_order_items_dataset table column aggregation
SELECT  count(*) as cnt
		,count(order_id) as order_count_not_distinct
		,count(distinct order_id) as order_count
  FROM  olist_order_items_dataset;
  
-- 3. olist_orders_dataset, olist_order_items_dataset table relationship
SELECT  count(*) as cnt
		,count(order_id) as order_count_not_distinct
		,count(distinct order_id) as order_count
  FROM  olist_orders_dataset;

-- * olist_orders_dataset : olist_order_items_dataset = 1 : N (order_id) => One order_id can have multiple order_item_ids.
SELECT  *
  FROM  olist_order_items_dataset
 WHERE  order_id = '00337fe25a3780b3424d9ad7c5a4b35e';

-- 4. Which categories sold the most?
-- * bed_bath_table > health_beauty > sports_leisure > computers_accessories > furniture_decor..
SELECT  pct.product_category_name_english
        ,COUNT(distinct o.order_id) AS order_count
        ,SUM(oi.price) AS price_total
        ,SUM(oi.freight_value) AS freight_value_total
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
 GROUP
    BY  1
 ORDER
    BY  2 DESC;

-- * olist_products_dataset : olist_order_items_dataset = 1 : N (product_id) => One product_id can be ordered multiple times.
SELECT  COUNT(product_id)
		,COUNT(DISTINCT product_id)
  FROM  olist_products_dataset;
  
SELECT  COUNT(product_id)
		,COUNT(DISTINCT product_id)
  FROM  olist_order_items_dataset;

-- * There are 71 product_category_names.  
SELECT  COUNT(product_category_name)
		,COUNT(DISTINCT product_category_name)
  FROM  product_category_name_translation; 

-- * pct.product_category_name_english IS NULL
-- * Reason
-- 1) product_category_name No information
-- 2) There is no product_category_name_english matching product_category_name
SELECT  distinct p.product_category_name
		,pct.product_category_name
        ,pct.product_category_name_english
  FROM  olist_products_dataset AS p 
  LEFT 
  JOIN  product_category_name_translation AS pct 
    ON  p.product_category_name = pct.product_category_name  
 WHERE  pct.product_category_name IS NULL; 
    
-- 5. Is the sum of price and freight_value the total order value?
-- * The order_id(00143d0f86d6fbd9f9b38ab440ac16f5) has 3 items (same product_id: e95ee6822b66ac6058e2e4aff656071a). 
-- * This is not duplicate data because the values of the order_item_id column are 1, 2, and 3.
-- * freight_value is the freight cost and price is the product price.
-- * The sum of price is 21.33 * 3 = 63.99
-- * The sum of freight_value is 15.10 * 3 = 45.30
-- * The total order value (sum of price + sum of freight_value) is: 63.99 + 45.30 = 109.29    
SELECT  *
  FROM  olist_order_items_dataset AS oi 
 WHERE  order_id = '00143d0f86d6fbd9f9b38ab440ac16f5';
 
SELECT  oi.order_id
	    ,SUM(oi.price) AS sum_of_price
        ,SUM(oi.freight_value) AS sum_of_freight_value
        ,SUM(oi.price) + SUM(oi.freight_value) AS total_order_value
  FROM  olist_order_items_dataset AS oi 
 WHERE  order_id = '00143d0f86d6fbd9f9b38ab440ac16f5'
 GROUP
    BY  1;
   
-- 6. Which city has the most orders?
-- * sao paulo is capital of brazil
SELECT  c.customer_city
        ,COUNT(DISTINCT o.order_id) AS order_count
        ,COUNT(DISTINCT c.customer_id) AS customer_count
        ,COUNT(DISTINCT c.customer_unique_id) AS customer_unique_count
  FROM  olist_orders_dataset AS o 
  LEFT 
  JOIN  olist_customers_dataset AS c 
    ON  c.customer_id = o.customer_id
 GROUP 
    BY  c.customer_city
 ORDER 
    BY  2 DESC;
    
-- 7. What is the difference between the customer_id and customer_unique_id columns in the olist_customers_dataset table?
-- * customer_unique_id(2e3b427dc09d7b4f7430f92956b0f3e6) has the same customer_id(f4608a440b868f3f57f378c4b8cd643f).
-- * customer_unique_id(c2551ea089b7ebbc67a2ea8757152514) has two different customer_ids(569cf68214806a39acc0f39344aea67f, c9f8da8278a23eb777ede2591b9ad3ee).
SELECT  c.customer_unique_id -- * c.customer_unique_id is the unique identifier of a customer.
        ,o.customer_id
        ,o.order_purchase_timestamp
        ,oi.product_id
        ,s.seller_id
  FROM  olist_orders_dataset AS o
  LEFT
  JOIN  olist_customers_dataset AS c
    ON  o.customer_id = c.customer_id
  LEFT 
  JOIN  olist_order_items_dataset AS oi 
    ON  o.order_id = oi.order_id    
  LEFT
  JOIN  olist_sellers_dataset AS s
    ON  oi.seller_id = s.seller_id
 WHERE  c.customer_unique_id IN ('2e3b427dc09d7b4f7430f92956b0f3e6','c2551ea089b7ebbc67a2ea8757152514')
 ORDER
    BY  1;

/* Step 3 */
-- 8. Who bought the most?
-- * Among all members, the number of members who purchased two or more items is very small at 3.12%.
WITH ORDER_BY_CUSTOMER AS
(
SELECT  c.customer_unique_id -- * c.customer_unique_id is the unique identifier of a customer.
        ,COUNT(DISTINCT o.order_id) AS order_count
  FROM  olist_orders_dataset AS o
  LEFT
  JOIN  olist_customers_dataset AS c
    ON  o.customer_id = c.customer_id
 GROUP
    BY  1
)
SELECT  CASE WHEN order_count >= 5 THEN '5_Order_Over'
			 WHEN order_count >= 4 THEN '4_Order'
             WHEN order_count >= 3 THEN '3_Order'
             WHEN order_count >= 2 THEN '2_Order'
             WHEN order_count >= 1 THEN '1_Order'
             END AS order_segment
		,COUNT(DISTINCT customer_unique_id) AS customer_cnt
  FROM  ORDER_BY_CUSTOMER
 GROUP
    BY  CASE WHEN order_count >= 5 THEN '5_Order_Over'
			 WHEN order_count >= 4 THEN '4_Order'
             WHEN order_count >= 3 THEN '3_Order'
             WHEN order_count >= 2 THEN '2_Order'
             WHEN order_count >= 1 THEN '1_Order'
             END
 ORDER
    BY  1;
        
-- 9. What products do you often buy together?
CREATE TABLE ORDER_LISTS AS
(
SELECT  o.order_id
		,oi.order_item_id
        ,pct.product_category_name_english
  FROM  olist_orders_dataset AS o
  LEFT 
  JOIN  olist_order_items_dataset AS oi 
    ON  o.order_id = oi.order_id
  LEFT 
  JOIN  olist_products_dataset AS p 
    ON  oi.product_id = p.product_id
  LEFT 
  JOIN  product_category_name_translation AS pct 
    ON  p.product_category_name = pct.product_category_name  
);

SELECT  *
  FROM  ORDER_LISTS
 LIMIT  10;

-- * Frequently purchase furniture-related products together
WITH ORDER_LISTS_GROUP AS
(
SELECT  order_id 
		,GROUP_CONCAT(DISTINCT product_category_name_english ORDER BY product_category_name_english ASC) AS product_cates
  FROM  ORDER_LISTS
 GROUP
	BY  1
)
SELECT  product_cates
		,COUNT(DISTINCT order_id) AS order_count
  FROM  ORDER_LISTS_GROUP
 WHERE  product_cates LIKE '%,%'
 GROUP
    BY  1
 ORDER
    BY  2 DESC;

-- * Raw Data Check
WITH ORDER_LISTS_GROUP AS
(
SELECT  order_id 
		,GROUP_CONCAT(DISTINCT product_category_name_english ORDER BY product_category_name_english ASC) AS product_cates
  FROM  ORDER_LISTS
 GROUP
	BY  1
)
SELECT  *
  FROM  ORDER_LISTS_GROUP
 WHERE  product_cates LIKE '%,%'
   AND  product_cates LIKE '%bed_bath_table%'
 ORDER
    BY  1;
   
SELECT  *
  FROM  ORDER_LISTS
 WHERE  order_id = '01b1a7fdae9ad1837d6ab861705a1fa5';
    
-- 10. How many order_ids do not match between the olist_orders_dataset and olist_order_items_dataset tables?
-- * Out of 99,441 orders, 755 orders did not match.
SELECT  COUNT(DISTINCT o.order_id) AS order_count
		,COUNT(DISTINCT CASE WHEN oi.order_id IS NULL THEN o.order_id END) AS not_match_order_count
        ,MAX(DISTINCT CASE WHEN oi.order_id IS NULL THEN o.order_id END) AS not_match_order_id_sample
  FROM  olist_orders_dataset AS o
  LEFT 
  JOIN  olist_order_items_dataset AS oi 
    ON  o.order_id = oi.order_id;

-- * not_match_order_id_sample
SELECT  *
  FROM  olist_orders_dataset
 WHERE  order_id = 'ff71fa43cf5b726cd4a5763c7d819a35';
 
SELECT  *
  FROM  olist_order_items_dataset
 WHERE  order_id = 'ff71fa43cf5b726cd4a5763c7d819a35';
 
-- 11. Which category has the slowest average delivery date?
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
 ORDER
    BY  2 DESC;
    
-- 12. Which city has the slowest average delivery date?
WITH DELIVERY_BY_customer_city AS
(
SELECT  c.customer_city
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
  LEFT 
  JOIN  olist_customers_dataset AS c 
    ON  c.customer_id = o.customer_id    
)
SELECT  customer_city
		,AVG(arrived_day) AS AVG_arrived_day
  FROM  DELIVERY_BY_customer_city
 WHERE  arrived_day IS NOT NULL
 GROUP
    BY  1
 ORDER
    BY  2 DESC; 

-- 13. What are the number of customers and sellers by state?
WITH customer_cnt AS
(
SELECT  customer_state
		,COUNT(DISTINCT customer_unique_id) AS customer_cnt
  FROM  olist_customers_dataset
 GROUP
    BY  1
),
seller_cnt AS
(
SELECT  seller_state
        ,COUNT(DISTINCT seller_id) AS seller_cnt
  FROM  olist_sellers_dataset
 GROUP
    BY  1
)
SELECT  c.customer_state
		,customer_cnt
        ,seller_cnt
  FROM  customer_cnt AS c 
  LEFT
  JOIN  seller_cnt AS s
    ON  c.customer_state = s.seller_state
 ORDER
    BY  3 DESC;
    
-- 14. Which state has the slowest average delivery date?    
WITH DELIVERY_BY_customer_state AS
(
SELECT  c.customer_state
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
  LEFT 
  JOIN  olist_customers_dataset AS c 
    ON  c.customer_id = o.customer_id    
)
SELECT  customer_state
		,AVG(arrived_day) AS AVG_arrived_day
  FROM  DELIVERY_BY_customer_state
 WHERE  arrived_day IS NOT NULL
 GROUP
    BY  1
 ORDER
    BY  2 DESC;     