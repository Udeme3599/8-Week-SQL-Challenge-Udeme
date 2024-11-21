## Dannys diner db creation

DROP DATABASE IF EXISTS dannys_diner;

CREATE DATABASE dannys_diner;
USE dannys_diner;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);
INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

## 1 What is the total amount each customer spent at the restaurant?
with TotalAmount AS (select a.customer_id, a.product_id, b.price
from 
sales a,
menu b
where a.product_id = b.product_id)
SELECT sum(price) from TotalAmount;

##2 How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS order_count
FROM sales
GROUP BY customer_id;

##3 What was the first item from the menu purchased by each customer?
with orders as (select s.customer_id, s.order_date, m.product_name 
from
sales s,
menu m
where s.product_id = m.product_id)
select min(order_date) as firstorder, customer_id from orders 
group by customer_id;

##4 What is the most purchased item on the menu and how many times was it purchased by all customers?
with orders as (select s.customer_id, s.product_id, m.product_name 
from 
sales s, menu m
where s.product_id = m.product_id),
customer_purchases as(select product_name,count(product_name) as purchase_count 
from orders
group by product_name)
SELECT product_name, purchase_count FROM customer_purchases
ORDER BY purchase_count DESC
LIMIT 1;

##5 Which item was the most popular for each customer?
with order_count as (select s.customer_id, m.product_name, count(*) as purchase_count 
from sales s, menu m
where s.product_id = m.product_id
group by customer_id, product_name)
select customer_id, product_name, purchase_count as mostPopular
from order_count
WHERE (customer_id, purchase_count) IN (
    SELECT customer_id, MAX(purchase_count)
    FROM order_count
    GROUP BY customer_id);
    
##6 Which item was purchased first by the customer after they became a member?
SELECT s.customer_id, s.order_date, m.join_date
FROM sales s, members m
WHERE s.customer_id = m.customer_id
and order_date = (select min(order_date) 
from sales WHERE customer_id = s.customer_id 
        AND order_date >= m.join_date);
    
##7 Which item was purchased just before the customer became a member?
SELECT s.customer_id, s.order_date, m.join_date
FROM sales s, members m
WHERE s.customer_id = m.customer_id
and order_date = (select max(order_date) 
from sales WHERE customer_id = s.customer_id 
        AND order_date < m.join_date);
        
##8 What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, s.order_date, m.join_date, mn.product_name, count(mn.product_id) as total_count,
sum(mn.price) as total_price
FROM sales s, members m, menu mn
WHERE s.customer_id = m.customer_id
and mn.product_id = s. product_id
AND order_date < m.join_date
group by s.customer_id, s.order_date, m.join_date, mn.product_name;

##9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id, m.product_name, m.price,
case when 
	product_name = 'sushi' then(m.price * 10) * 2
    else (m.price * 10)
    end as points
from sales s, menu m
where s.product_id = m.product_id;

##10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
with selec as (select s.customer_id, mb.join_date, s.order_date, m.price, m.product_name,
case when 
price > 0 then (m.price * 10) * 2 end as points
from sales s, members mb, menu m
where s.customer_id = mb.customer_id
and m.product_id = s.product_id
and s.order_date <= mb.join_date)
select customer_id, SUM(points) as TotalPoints from selec
group by customer_id;






