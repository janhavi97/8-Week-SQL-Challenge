# **Case Study #2: [Pizza Runner](https://8weeksqlchallenge.com/case-study-2/)**
<img width="679" alt="image" src="https://github.com/janhavi97/8-Week-SQL-Challenge/assets/30179560/4a915492-cb54-4bba-934f-45ba87b8606c">


## **Introduction**
Inspired by the '80s and the concept of on-demand services, "Pizza Runner" was launched with the aim of revolutionizing pizza delivery by combining quality food with efficient service. The business started from a home base, employing a network of runners to deliver fresh pizzas and using a mobile app for customer orders, focusing on a data-driven approach to manage and expand the venture.


## **Problem Statement**
To secure seed funding and scale up the pizza delivery business, it's crucial to optimize operations and enhance customer satisfaction. The goal is to analyze detailed operational data to improve delivery efficiency, customize customer experiences, and streamline the order process.


## **Entity Relationship Diagram**
<img width="573" alt="image" src="https://github.com/janhavi97/8-Week-SQL-Challenge/assets/30179560/03bd399a-1333-4bd3-9dd6-97194a56ff3c">


## **Tables Overview**
1. Table 1 - runners: Transactions recorded with runner IDs and registration dates.
2. Table 2 - customer_orders: Details of each menu item including order ID, customer ID, pizza ID, exclusions, extras, and order time.
3. Table 3 - runner_orders: Records of each order assigned to runners including order ID, runner ID, pickup time, distance, duration, and cancellation status.
4. Table 4 - pizza_names: Listing of available pizzas with their pizza ID and pizza name.
5. Table 5 - pizza_recipes: Specifications of each pizza including pizza ID and the toppings used.
6. Table 6 - pizza_toppings: Inventory of all available toppings including topping ID and topping name.

## Data Cleaning & Transformation
### Table: customer_orders
<img width="1447" alt="image" src="https://github.com/janhavi97/8-Week-SQL-Challenge/assets/30179560/5632ecfc-e55f-408e-a20d-f58788fff725">

- Columns Affected: exclusions and extras
- Issues: Contains 'null' values and missing (blank) spaces.
- Solution: Create a temporary table, replace all 'null' and blank spcaes in these columns with NULL.

```
CREATE TEMP TABLE customer_orders_temp AS
SELECT 	order_id, 
		customer_id, 
 		pizza_id, 
  		CASE 
			WHEN exclusions IN ('null', '') THEN NULL
			ELSE exclusions
		END AS exclusions,
		CASE
			WHEN extras IN ('null', '') THEN NULL
			ELSE extras
		END AS extras,
		order_time
FROM pizza_runner.customer_orders;
```

```
SELECT *
FROM customer_orders_temp
```
<img width="1447" alt="image" src="https://github.com/janhavi97/8-Week-SQL-Challenge/assets/30179560/79ece6b4-e339-47ad-b799-9708f23daef0">


### Table: runner_orders
<img width="1449" alt="image" src="https://github.com/janhavi97/8-Week-SQL-Challenge/assets/30179560/f305c7ac-647c-4f64-a4fb-25965763e785">

Issues:
- pickup_time: Contains 'null'.
- distance: Contains "km" and 'null'.
- duration: Contains "minutes", "minute", and 'null'.
- cancellation: Contains 'null' and blank spaces.

Solutions:
- For pickup_time: Replace 'null' with NULL.
- For distance: Remove "km" and replace 'nulls' with NULL.
- For duration: Remove "minutes" and "minute", replace 'null' with NULL.
- For cancellation: Replace 'null' and blank spaces with NULL.

```
CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT
    order_id,
    runner_id,
    CASE
        WHEN pickup_time = 'null' THEN NULL
        ELSE pickup_time
    END AS pick_up_time,
    CASE
        WHEN distance = 'null' THEN NULL
        ELSE regexp_replace(distance, '[a-z]+', '', 'gi')
    END AS distance,
    CASE
        WHEN duration = 'null' THEN NULL
        ELSE regexp_replace(duration, '[a-z]+', '', 'gi')
    END AS duration,
    CASE
        WHEN cancellation IN ('null', '') THEN NULL
        ELSE cancellation
    END AS cancellation
FROM pizza_runner.runner_orders;
```

Post-Cleanup: Alter pickup_time, distance, and duration columns to the correct data types for proper query execution.
```
ALTER TABLE runner_orders_temp
ALTER COLUMN pick_up_time TYPE TIMESTAMP USING pick_up_time::TIMESTAMP,
ALTER COLUMN distance TYPE FLOAT USING CAST(trim(distance) AS FLOAT),
ALTER COLUMN duration TYPE INTEGER USING CAST(trim(duration) AS INTEGER);
```

```
SELECT * FROM runner_orders_temp;
```
<img width="1447" alt="image" src="https://github.com/janhavi97/8-Week-SQL-Challenge/assets/30179560/e5426064-2c8f-4a51-903c-0bb617cb0fa3">



## **Case Study Questions**
### A. Pizza Metrics
- How many pizzas were ordered?
- How many unique customer orders were made?
- How many successful orders were delivered by each runner?
- How many of each type of pizza was delivered?
- How many Vegetarian and Meatlovers were ordered by each customer?
- What was the maximum number of pizzas delivered in a single order?
- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
- How many pizzas were delivered that had both exclusions and extras?
- What was the total volume of pizzas ordered for each hour of the day?
- What was the volume of orders for each day of the week?

### B. Runner and Customer Experience
- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
- Is there any relationship between the number of pizzas and how long the order takes to prepare?
- What was the average distance travelled for each customer?
- What was the difference between the longest and shortest delivery times for all orders?
- What was the average speed for each runner for each delivery and do you notice any trend for these values?
- What is the successful delivery percentage for each runner?

### C. Ingredient Optimisation
- What are the standard ingredients for each pizza?
- What was the most commonly added extra?
- What was the most common exclusion?
- Generate an order item for each record in the customers_orders table in the format of one of the following:
  - Meat Lovers
  - Meat Lovers - Exclude Beef
  - Meat Lovers - Extra Bacon
  - Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
  - For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
  
### D. Pricing and Ratings
- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
- What if there was an additional $1 charge for any pizza extras?
  - Add cheese is $1 extra
- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
  - customer_id
  - order_id
  - runner_id
  - rating
  - order_time
  - pickup_time
  - Time between order and pickup
  - Delivery duration
  - Average speed
  - Total number of pizzas
- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

### E. Bonus Questions
If owner wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
