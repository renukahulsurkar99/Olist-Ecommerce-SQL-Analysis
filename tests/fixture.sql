-- Small synthetic records exercise relationships independently of Kaggle data.
TRUNCATE olist.order_reviews, olist.order_payments, olist.order_items,
         olist.orders, olist.customers, olist.products, olist.sellers,
         olist.category_translation;
INSERT INTO olist.customers VALUES
('c1','u1','00100','City A','SP'),('c2','u1','00100','City A','SP'),
('c3','u2','00200','City B','BA'),('c4','u3','00300','City C','RJ');
INSERT INTO olist.category_translation VALUES ('cat','category');
INSERT INTO olist.products(product_id,product_category_name) VALUES ('p1','cat'),('p2','untranslated');
INSERT INTO olist.sellers VALUES ('s1','00100','City A','SP'),('s2','00200','City B','BA');
INSERT INTO olist.orders VALUES
('o1','c1','delivered','2018-01-01 08:00','2018-01-01 09:00','2018-01-01 10:00','2018-01-01 23:59','2018-01-01 00:00'),
('o2','c2','delivered','2018-03-01 08:00','2018-03-01 09:00','2018-03-01 10:00','2018-03-03 10:00','2018-03-02 00:00'),
('o3','c3','canceled','2018-03-15 08:00',NULL,NULL,NULL,'2018-03-25'),
('o4','c4','delivered','2018-01-10 08:00','2018-01-10 09:00',NULL,NULL,'2018-01-20');
INSERT INTO olist.order_items VALUES
('o1',1,'p1','s1','2018-01-01',10,2),('o1',2,'p2','s2','2018-01-01',20,3),
('o2',1,'p1','s1','2018-03-01',10,1),('o4',1,'p1','s1','2018-01-10',20,0);
INSERT INTO olist.order_payments VALUES
('o1',1,'credit_card',1,15),('o1',2,'voucher',1,20),
('o2',1,'credit_card',1,11),('o4',1,'credit_card',1,20);
INSERT INTO olist.order_reviews VALUES
('shared','o1',1,NULL,NULL,'2018-01-02','2018-01-02'),
('latest','o1',5,NULL,NULL,'2018-01-03','2018-01-03'),
('shared','o2',2,NULL,NULL,'2018-03-04','2018-03-04');
