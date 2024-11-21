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
  
###########################

USE pizza_runner;

##Pizza MEtrics

##How many pizzas were ordered? (work on removing cancelled orders)
select count(distinct order_id) as total_order 
from customer_orders;

##How many unique customer orders were made?
select count(distinct order_id) as unique_orders, customer_id from customer_orders
group by customer_id;

##How many successful orders were delivered by each runner?
select runner_id, count(runner_id) as successful_orders
from runner_orders
where distance and duration is not null
group by runner_id;

##How many of each type of pizza was delivered?
select count(pn.pizza_id) as TotaPizza , pn.pizza_name
from pizza_names pn, runner_orders ro, customer_orders co
where distance is not null
and co.order_id = ro.order_id
and co.pizza_id = pn.pizza_id
group by pn.pizza_id, pn.pizza_name;

##How many Vegetarian and Meatlovers were ordered by each customer?
select co. customer_id, pn.pizza_name, count(pn.pizza_id) as Order_count
from pizza_names pn, runner_orders ro, customer_orders co
where co.order_id = ro.order_id
and co.pizza_id = pn.pizza_id
group by pn.pizza_id, pn.pizza_name, co.customer_id;

##What was the maximum number of pizzas delivered in a single order?
SELECT DATE(order_time) AS order_date, COUNT(DISTINCT order_id) AS total_orders
FROM customer_orders
GROUP BY DATE(order_time)
Order by total_orders DESC;

##For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id, 
count(case when exclusions > 0 or extras > 0 then 1  end) as changes
from customer_orders
group by customer_id;

##How many pizzas were delivered that had both exclusions and extras?
select count(distinct order_id) as order_id, 
count(case when exclusions > 0 or extras > 0 then 1  end) as changes
from customer_orders
group by customer_id
having changes > 0;

##What was the total volume of pizzas ordered for each hour of the day?
select customer_id, count(distinct order_time) as count
from pizza_runner.customer_orders
group by customer_id;

##What was the volume of orders for each day of the week?
select distinct date(order_time) as order_time, count(order_id) as order_count 
from customer_orders
group by date(order_time);

##Runner and Customer Experience
##How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select date_add(registration_date, interval -weekday(registration_date) day) as week_start,
count(*) as runner_count
from runners
where registration_date >= '2021-01-01'
group by week_start
order by week_start;
## i dont think this is correct 

### C. Ingredient Optimisation
# 1. What are the standard ingredients for each pizza?
#i have issues with spliting the numbers 






##D. Pricing and Ratings
# 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
#how much money has Pizza Runner made so far if there are no delivery fees?
SELECT co.order_id, pn.pizza_name,
CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END AS amount
FROM customer_orders co, pizza_names pn
where  co.pizza_id = pn.pizza_id
UNION ALL
SELECT 'Total' AS order_id, 'Total' AS pizza_name,
    SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS amount
FROM customer_orders co, pizza_names pn
where  co.pizza_id = pn.pizza_id;








