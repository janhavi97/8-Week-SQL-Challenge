-- B. Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2020-01-01)
SELECT FLOOR((EXTRACT(DAY FROM age(registration_date, '2021-01-01')) / 7)) AS registration_week,
       COUNT(runner_id) AS runner_signup
FROM pizza_runner.runners
GROUP BY registration_week
ORDER BY registration_week;
-- In Week 1, 2 new runners signed up.
-- In Week 2 and 3, 1 new runner signed up.


-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT r.runner_id,
       AVG(DATE_PART('minute', (r.pickup_time - c.order_time))) AS average_minutes_to_pickup
FROM customer_orders_temp c
JOIN runner_orders_temp r
ON c.order_id = r.order_id
WHERE r.pickup_time IS NOT NULL AND c.order_time IS NOT NULL
GROUP BY r.runner_id
ORDER BY r.runner_id;
-- Runner 1 took 15.34 minutes on average
-- Runner 2 took 23.4 minutes on average
-- Runner 3 took 10 minutes on average


-- Is there any relationship between the number of pizzas and how long the order takes to prepare?



-- What was the average distance travelled for each customer?



-- What was the difference between the longest and shortest delivery times for all orders?



-- What was the average speed for each runner for each delivery and do you notice any trend for these values?



-- What is the successful delivery percentage for each runner?


