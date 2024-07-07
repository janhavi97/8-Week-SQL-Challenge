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



-- Is there any relationship between the number of pizzas and how long the order takes to prepare?



-- What was the average distance travelled for each customer?



-- What was the difference between the longest and shortest delivery times for all orders?



-- What was the average speed for each runner for each delivery and do you notice any trend for these values?



-- What is the successful delivery percentage for each runner?


