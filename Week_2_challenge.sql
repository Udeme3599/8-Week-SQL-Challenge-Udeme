## Pizzza runner db creation

drop database if exists pizza_runner;
CREATE SCHEMA pizza_runner;
USE pizza_runner;
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE);
  INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
  DROP TABLE IF EXISTS customer_orders;
  CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP);
INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
  DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23));
  
  INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
  
  DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT);
  
  INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');
  DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT);
  INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');
  DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT);
  INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
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








