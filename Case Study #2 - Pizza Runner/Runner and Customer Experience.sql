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
SELECT pizza_count, 
       AVG(average_minutes_to_pickup)
FROM 
       (
              SELECT COUNT(r.order_id) AS pizza_count,
                     AVG(DATE_PART('minute', (r.pickup_time - c.order_time))) AS average_minutes_to_pickup
	       FROM customer_orders_temp c
	       JOIN runner_orders_temp r
	       ON c.order_id = r.order_id
	       WHERE r.pickup_time IS NOT NULL AND c.order_time IS NOT NULL
              GROUP BY r.order_id
       ) a
GROUP BY pizza_count
ORDER BY pizza_count;
-- On average, preparing a single pizza order requires 12 minutes. However, the efficiency improves with larger orders. For instance, an order containing 3 pizzas takes about 29 minutes, averaging 10 minutes per pizza. The most efficient scenario occurs with two-pizza orders, which take 18 minutes in total, breaking down to just 9 minutes per pizza. This setup showcases that ordering 2 pizzas at once provides the best use of preparation time.


-- What was the average distance travelled for each customer?
SELECT c.customer_id,
       AVG(r.distance) AS average_minutes_to_pickup
FROM customer_orders_temp c
JOIN runner_orders_temp r
ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;
-- Customer 104 stays the nearest to Pizza Runner HQ at average distance of 10km, whereas Customer 105 stays the furthest at 25km.


-- What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration) AS delivery_time_diff
FROM runner_orders_temp;
-- The difference between longest (40 minutes) and shortest (10 minutes) delivery times for all orders is 30 minutes.


-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, 
       order_id,
       (distance/duration * 60) AS average_speed
FROM runner_orders_temp
WHERE distance IS NOT NULL AND duration IS NOT NULL
ORDER BY runner_id, order_id;
-- Runner 1's average speed fluctuates between 37.5 km/h and 60 km/h, which is relatively consistent. 
-- Runner 2 exhibits a significantly wider range in average speed, varying from 35.1 km/h to an impressive 93.6 km/h. This represents a 300% fluctuation rate in average speed for Runner 2, suggesting potential inconsistencies or anomalies in performance that warrant further investigation by Danny. 
-- Runner 3 maintains a average speed of 40 km/h.


-- What is the successful delivery percentage for each runner?
SELECT runner_id, 
       ROUND(100 * SUM(CASE WHEN distance IS NULL THEN 0 ELSE 1 END) / COUNT(*), 0) AS complete_delivery_per
FROM runner_orders_temp
GROUP BY runner_id
ORDER BY runner_id;
-- Runner 1 has 100% successful delivery.
-- Runner 2 has 75% successful delivery.
-- Runner 3 has 50% successful delivery.
