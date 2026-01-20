/* CREATE DATABASE */
CREATE DATABASE Practice;

/* USE DATABASE */
USE Practice;

/* CREATE TABLES */
/* A column can only have one data type (number, date, character) */
CREATE TABLE Practice.olist_customers_dataset (
customer_id text
,customer_unique_id text
,customer_zip_code_prefix int
,customer_city text
,customer_state text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- ENGINE: Storage Server Engine / DEFAULT CHARSET: character conversion / COLLATE: Character alignment method

CREATE TABLE Practice.olist_order_items_dataset (
order_id text
,order_item_id int
,product_id text
,seller_id text
,shipping_limit_date datetime
,price double
,freight_value double
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Practice.olist_order_payments_dataset (
order_id text
,payment_sequential int
,payment_type text
,payment_installments int
,payment_value double
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Practice.olist_order_reviews_dataset (
review_id text
,order_id text
,review_score int
,review_comment_title text
,review_comment_message text
,review_creation_date datetime
,review_answer_timestamp datetime
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Practice.olist_orders_dataset (
order_id text
,customer_id text
,order_status text
,order_purchase_timestamp datetime
,order_approved_at datetime
,order_delivered_carrier_date datetime
,order_delivered_customer_date datetime
,order_estimated_delivery_date datetime
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Practice.olist_products_dataset (
product_id text
,product_category_name text
,product_name_lenght int
,product_description_lenght int
,product_photos_qty int
,product_weight_g int
,product_length_cm int
,product_height_cm int
,product_width_cm int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Practice.olist_sellers_dataset (
seller_id text
,seller_zip_code_prefix int
,seller_city text
,seller_state text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Practice.product_category_name_translation (
product_category_name text
,product_category_name_english text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/* SETTING 1 */
show variables like 'local_infile';
set global local_infile = 1;

/* SETTING 2 */
-- MYSQL Connection -> Edit connection -> Advanced -> OPT_LOCAL_INFILE=1 

/* Load CSV file */
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv' IGNORE
INTO TABLE Practice.olist_customers_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv' IGNORE
INTO TABLE Practice.olist_order_items_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv' IGNORE
INTO TABLE Brazilian.olist_order_payments_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv' IGNORE
INTO TABLE Practice.olist_order_reviews_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv' IGNORE
INTO TABLE Practice.olist_orders_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv' IGNORE
INTO TABLE Practice.olist_products_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv' IGNORE
INTO TABLE Practice.olist_sellers_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv' IGNORE
INTO TABLE Practice.product_category_name_translation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

/**************************************************************************************************************************************************************/
/******************************************************************** Tables Pattern Check ********************************************************************/
/**************************************************************************************************************************************************************/

-- 9. What products do you often buy together?
-- * Edit → Preferences → SQL Editor → DBMS connection read time out interval (in seconds): 30 -> 100000
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


/**************************************************************************************************************************************************************/
/******************************************************************** Table for analysis **********************************************************************/
/**************************************************************************************************************************************************************/

-- 1. RFM(Recency, Frequency, Monetary) Analysis Table
-- * The purchase date period is 2016-09-04 ~ 2018-10-17.(Recency calculation base date is 2018-10-17)

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
 GROUP
    BY  1
);
 
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