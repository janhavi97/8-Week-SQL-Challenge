-- C. Ingredient Optimisation

WITH pizza_recipes_cte AS (
SELECT
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes)


-- What are the standard ingredients for each pizza?


-- What was the most commonly added extra?



-- What was the most common exclusion?



-- Generate an order item for each record in the customers_orders table in the format of one of the following:
  -- Meat Lovers
  -- Meat Lovers - Exclude Beef
  -- Meat Lovers - Extra Bacon
  -- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers


-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
  -- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"



-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?


