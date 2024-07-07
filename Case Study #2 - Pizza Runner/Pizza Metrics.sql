-- A. Pizza Metrics
-- How many pizzas were ordered?
SELECT COUNT(1) AS pizza_count
FROM customer_orders_temp;
-- 14 pizzas were ordered


-- How many unique customer orders were made?
SELECT COUNT( DISTINCT order_id) AS unique_order_count
FROM customer_orders_temp;
-- 10 unique customer orders were made


-- How many successful orders were delivered by each runner?
SELECT runner_id, count(DISTINCT ORDER_id) as count_successful_orders
FROM runner_orders_temp
WHERE distance IS NOT NULL
GROUP BY runner_id; 
-- runner_id 1 made 4 orders
-- runner_id 2 made 3 orders
-- runner_id 3 made 1 orders

-- How many of each type of pizza was delivered?
SELECT 	p.pizza_name,
		COUNT(c.pizza_id) AS delivered_pizza_count
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
JOIN pizza_runner.pizza_names AS p
ON c.pizza_id = p.pizza_id
WHERE r.distance IS NOT NULL
GROUP BY p.pizza_name;
-- 9 Meatlovers and 3 Vegetarian pizzas were delivered.


-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 	c.customer_id,
		p.pizza_name,
		COUNT(c.pizza_id) AS delivered_pizza_count
FROM customer_orders_temp AS c
JOIN pizza_runner.pizza_names AS p
ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id, p.pizza_name;
-- Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
-- Customer 102 ordered 2 Meatlovers pizzas and 2 Vegetarian pizzas.
-- Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
-- Customer 104 ordered 1 Meatlovers pizza.
-- Customer 105 ordered 1 Vegetarian pizza.


-- What was the maximum number of pizzas delivered in a single order?
SELECT MAX(a.count_pizza) as count_max_order
FROM 
  (
    SELECT COUNT(c.order_id) as count_pizza
    FROM customer_orders_temp AS c
	  JOIN runner_orders_temp AS r
	  ON c.order_id = r.order_id
    WHERE r.distance IS NOT NULL
    GROUP BY c.order_id
	) a
-- 3 is the maximum number of pizzas delivered in a single order


-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT  c.customer_id, 
        SUM (CASE WHEN exclusions IS NULL OR extras IS NULL THEN 1 ELSE 0 END) as order_notchanged_count,
		    SUM (CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) as order_changed_count
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;
-- Customer 101 and 102 made no change in their pizza order.
-- Customer 103, 104 and 105 have requested at least 1 change in their pizza.


-- How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(c.order_id)
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
AND exclusions IS NOT NULL AND extras IS NOT NULL;
-- 1 pizza had both exclusions and extras on it.


-- What was the total volume of pizzas ordered for each hour of the day?
SELECT DATE_PART('hour', order_time) AS order_hour,
       COUNT(*) AS total_pizzas_ordered
FROM customer_orders_temp
GROUP BY order_hour;
-- Highest volume of pizza ordered is at 13 (1:00 pm), 18 (6:00 pm), 23 (11:00 pm) and 21 (9:00 pm).
-- Lowest volume of pizza ordered is at 11 (11:00 am) and 19 (7:00 pm).


-- What was the volume of orders for each day of the week?
SELECT TO_CHAR(order_time, 'Day') AS order_weekday,
       COUNT(*) AS total_pizzas_ordered
FROM customer_orders_temp
GROUP BY order_weekday;
-- There are 5 pizzas ordered on Saturday and Wednesday.
-- There are 3 pizzas ordered on Thursday.
-- There is 1 pizza ordered on Friday.
