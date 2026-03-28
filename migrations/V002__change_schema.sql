ALTER TABLE product ADD COLUMN price double precision;

ALTER TABLE orders ADD COLUMN date_created date;

DROP TABLE product_info;
DROP TABLE orders_date;