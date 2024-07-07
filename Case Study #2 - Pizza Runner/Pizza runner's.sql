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
SELECT EXTRACT(HOUR FROM order_time) AS order_hour,
       COUNT(*) AS total_pizzas_ordered
FROM customer_orders_temp
GROUP BY order_hour;
-- Highest volume of pizza ordered is at 13 (1:00 pm), 18 (6:00 pm) and 21 (9:00 pm).
-- Lowest volume of pizza ordered is at 11 (11:00 am), 19 (7:00 pm) and 23 (11:00 pm).


-- What was the volume of orders for each day of the week?
SELECT TO_CHAR(order_time, 'Day') AS order_weekday,
       COUNT(*) AS total_pizzas_ordered
FROM customer_orders_temp
GROUP BY order_weekday;
-- There are 5 pizzas ordered on Saturday and Wednesday.
-- There are 3 pizzas ordered on Thursday.
-- There is 1 pizza ordered on Friday.


-- B. Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- What was the average distance travelled for each customer?
-- What was the difference between the longest and shortest delivery times for all orders?
-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- What is the successful delivery percentage for each runner?

-- C. Ingredient Optimisation
-- What are the standard ingredients for each pizza?
-- What was the most commonly added extra?
-- What was the most common exclusion?
-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- - Meat Lovers
  -- Meat Lovers - Exclude Beef
  -- Meat Lovers - Extra Bacon
  -- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
  -- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
  
-- D. Pricing and Ratings
-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
-- What if there was an additional $1 charge for any pizza extras?
  -- Add cheese is $1 extra
-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
-- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
  -- customer_id
  -- order_id
  -- runner_id
  -- rating
  -- order_time
  -- pickup_time
  -- Time between order and pickup
  -- Delivery duration
  -- Average speed
  -- Total number of pizzas
-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

-- E. Bonus Questions
-- If owner wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
