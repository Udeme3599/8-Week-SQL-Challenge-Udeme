-- B. Data Analysis Questions
-- 1. How many customers has Foodie-Fi ever had?
select count(distinct customer_id) from subscriptions;

 -- 2. What is the monthly distribution of trial plan start_date values for our dataset 
 -- use the start of the month as the group by value
select date_format(start_date, '%Y-%m-01') AS start_of_month, COUNT(*) AS number_of_trial_plans
from subscriptions where plan_id = 0
group by start_of_month
order by start_of_month;

-- 3. What plan start_date values occur after the year 2020 for our dataset? 
-- Show the breakdown by count of events for each plan_name
SELECT s.plan_id,p.plan_name, COUNT(*) AS number_of_events
FROM subscriptions s, plans p
where s.plan_id = p.plan_id
and start_date > '2020-12-31'
GROUP BY plan_id, plan_name
ORDER BY number_of_events ASC;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select plan_id, COUNT(*) as cust_count, round((COUNT(*) / 1000 * 100), 1) AS percentage
from subscriptions
where plan_id = 4;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
with trial as (select customer_id from subscriptions where plan_id = 0),
churned as (select customer_id from subscriptions where plan_id = 4)
select count(distinct c.customer_id) as churned_after_trial,
round((count(distinct c.customer_id) / (select count(distinct customer_id) from Trial)) * 100) as churn_percentage
from Churned c, Trial t
where c.customer_id = t.customer_id;

-- 6. What is the number and percentage of customer plans after their initial free trial?
with freeTrial as (select customer_id from subscriptions where plan_id = 0),
continuation as (select customer_id from subscriptions where plan_id in (1,4))
select count(distinct ct.customer_id) as number,
round(count(distinct ct.customer_id) / (select count(distinct customer_id) from freeTrial) * 100) as Percentage
from freeTrial ft, continuation ct
where ft.customer_id = ct.customer_id;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
SELECT s.plan_id,p.plan_name, COUNT(*) AS number_of_events, round((COUNT(*) / 1000 * 100), 0) AS percentage
FROM subscriptions s, plans p
where s.plan_id = p.plan_id
and start_date <= '2020-12-31'
GROUP BY plan_id, plan_name
ORDER BY number_of_events DESC;

-- 8. How many customers have upgraded to an annual plan in 2020?
-- this question is kind of tricky, tricky because every customer was once on free_trial-0 before migrating to another plan

with pro_annual as (select customer_id from subscriptions where plan_id = 3
and start_date between '2020-01-01' AND '2020-12-31'),
others as (select customer_id from subscriptions where plan_id in (0,1,2,4))
select count(distinct pa.customer_id) as number
from pro_annual pa, others o
where pa.customer_id = o.customer_id;

-- you can also do this and still get same answer
select count(distinct customer_id) from subscriptions
where plan_id = 3
and start_date <= '2020-12-31';

-- this script shows you how each customer upgraded to the pro-annual plan
select distinct a.customer_id, a.plan_id, a.start_date, b.plan_id
from subscriptions a, subscriptions b
where a.customer_id = b.customer_id
and a.plan_id = 3
and a.start_date between '2020-01-01' AND '2020-12-31';

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with joined as (select customer_id, min(start_date) as joined_date, plan_id from subscriptions
where plan_id = 0 group by customer_id),
annual as (select customer_id, min(start_date) as annual_date, plan_id from subscriptions
where plan_id = 3 group by customer_id)
select j.customer_id, joined_date, annual_date, datediff(annual_date,joined_date) as Days
from joined j,
annual a
where j.customer_id = a.customer_id;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
with joined as (select customer_id, min(start_date) as joined_date, plan_id from subscriptions
where plan_id = 0 group by customer_id),
annual as (select customer_id, min(start_date) as annual_date, plan_id from subscriptions
where plan_id = 3 group by customer_id)
select j.customer_id, joined_date, annual_date, datediff(annual_date,joined_date) as Days, 
case when datediff(A.annual_date,J.joined_date) <= 30 then '0-30'
when datediff(A.annual_date,J.joined_date) > 30 and datediff(A.annual_date,J.joined_date) <= 60 then  '31-60'
when datediff(A.annual_date,J.joined_date) > 60 and datediff(A.annual_date,J.joined_date) <= 90 then  '61-90'
when datediff(A.annual_date,J.joined_date) > 90 and datediff(A.annual_date,J.joined_date) <= 120 then '91-120'
when datediff(A.annual_date,J.joined_date) > 120 THEN 120 
else '121+'end as  period
from joined j, annual a
where j.customer_id = a.customer_id
order by period asc;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
select t.customer_id, o.customer_id, t.plan_id, o.plan_id, o.start_date as BasicMonthly, t.start_date as ProMonthly
from subscriptions o, subscriptions t
where o.customer_id = t.customer_id
and o.plan_id = 1
and t.plan_id = 2
and o.start_date > t.start_date;




