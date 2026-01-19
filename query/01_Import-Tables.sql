/* Step 2 */
/* CREATE DATABASE */
CREATE DATABASE Brazilian;

/* USE DATABASE */
USE Brazilian;

/* CREATE TABLES */
/* A column can only have one data type (number, date, character) */
CREATE TABLE Brazilian.olist_customers_dataset (
customer_id text
,customer_unique_id text
,customer_zip_code_prefix int
,customer_city text
,customer_state text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- ENGINE: Storage Server Engine / DEFAULT CHARSET: character conversion / COLLATE: Character alignment method

CREATE TABLE Brazilian.olist_order_items_dataset (
order_id text
,order_item_id int
,product_id text
,seller_id text
,shipping_limit_date datetime
,price double
,freight_value double
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Brazilian.olist_order_payments_dataset (
order_id text
,payment_sequential int
,payment_type text
,payment_installments int
,payment_value double
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Brazilian.olist_order_reviews_dataset (
review_id text
,order_id text
,review_score int
,review_comment_title text
,review_comment_message text
,review_creation_date datetime
,review_answer_timestamp datetime
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Brazilian.olist_orders_dataset (
order_id text
,customer_id text
,order_status text
,order_purchase_timestamp datetime
,order_approved_at datetime
,order_delivered_carrier_date datetime
,order_delivered_customer_date datetime
,order_estimated_delivery_date datetime
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Brazilian.olist_products_dataset (
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

CREATE TABLE Brazilian.olist_sellers_dataset (
seller_id text
,seller_zip_code_prefix int
,seller_city text
,seller_state text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Brazilian.product_category_name_translation (
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
INTO TABLE Brazilian.olist_customers_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv' IGNORE
INTO TABLE Brazilian.olist_order_items_dataset
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
INTO TABLE Brazilian.olist_order_reviews_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv' IGNORE
INTO TABLE Brazilian.olist_orders_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv' IGNORE
INTO TABLE Brazilian.olist_products_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv' IGNORE
INTO TABLE Brazilian.olist_sellers_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv' IGNORE
INTO TABLE Brazilian.product_category_name_translation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS;



 