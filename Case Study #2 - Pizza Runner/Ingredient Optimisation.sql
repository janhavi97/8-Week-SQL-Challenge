-- C. Ingredient Optimisation
-- What are the standard ingredients for each pizza?
SELECT n.pizza_name,
       STRING_AGG(t.topping_name, ', ' ORDER BY t.topping_name) AS ingredients
FROM pizza_runner.pizza_recipes r
JOIN pizza_runner.pizza_toppings t 
ON r.toppings LIKE '%' || t.topping_id || '%'
JOIN pizza_runner.pizza_names n 
ON r.pizza_id = n.pizza_id
GROUP BY n.pizza_name;
-- Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni and Salami are the standard ingredients for Meatlovers pizza.
-- Cheese, Mushrooms, Onions, Peppers, Tomatoes and Tomato Sauce are the standard ingredients for Vegetarian pizza. 


-- What was the most commonly added extra?
SELECT t.topping_name, 
       COUNT(*) AS count_extra_toppings
FROM customer_orders_temp c
JOIN pizza_runner.pizza_toppings t 
ON c.extras LIKE '%' || t.topping_id || '%'
WHERE c.extras IS NOT NULL
GROUP BY t.topping_name
ORDER BY count_extra_toppings DESC
LIMIT 1;
-- Bacon is the most commonly added extra topping


-- What was the most common exclusion?
SELECT t.topping_name, 
       COUNT(*) AS count_exclusion_toppings
FROM customer_orders_temp c
JOIN pizza_runner.pizza_toppings t 
ON c.exclusions LIKE '%' || t.topping_id || '%'
WHERE c.exclusions IS NOT NULL
GROUP BY t.topping_name
ORDER BY count_exclusion_toppings DESC
LIMIT 1;
-- Cheese is the most common excluded topping


-- Generate an order item for each record in the customers_orders table in the format of one of the following:
  -- Meat Lovers
  -- Meat Lovers - Exclude Beef
  -- Meat Lovers - Extra Bacon
  -- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

-- | order_id | order_description                                               |
-- | -------- | --------------------------------------------------------------- |
-- | 1        | Meatlovers                                                      |
-- | 2        | Meatlovers                                                      |
-- | 3        | Meatlovers                                                      |
-- | 3        | Vegetarian                                                      |
-- | 4        | Vegetarian - Exclude Cheese, Cheese, Cheese                     |
-- | 4        | Meatlovers - Exclude Cheese, Cheese, Cheese                     |
-- | 4        | Meatlovers - Exclude Cheese, Cheese, Cheese                     |
-- | 5        | Meatlovers - Extra Bacon                                        |
-- | 6        | Vegetarian                                                      |
-- | 7        | Vegetarian - Extra Bacon                                        |
-- | 8        | Meatlovers                                                      |
-- | 9        | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
-- | 10       | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |
-- | 10       | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |
  

-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
  -- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
SELECT c.order_id,
       n.pizza_name || ': ' || STRING_AGG(CASE WHEN c.extras LIKE '%' || t.topping_id || '%' THEN '2x' || t.topping_name ELSE t.topping_name END, ', ' ORDER BY t.topping_name) AS ingredients_list
FROM customer_orders_temp c
JOIN pizza_runner.pizza_recipes r 
ON c.pizza_id = r.pizza_id
JOIN pizza_runner.pizza_toppings t 
ON r.toppings LIKE '%' || t.topping_id || '%' OR c.extras LIKE '%' || t.topping_id || '%'
JOIN pizza_runner.pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY 
    co.order_id, pn.pizza_name
ORDER BY 
    co.order_id;
-- | order_id | order_description                                                                                    |
-- | -------- | ---------------------------------------------------------------------------------------------------- |
-- | 1        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                    |
-- | 2        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                    |
-- | 3        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                    |
-- | 3        | Vegetarian: BBQ Sauce, Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes             |
-- | 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                    |
-- | 4        | Vegetarian: BBQ Sauce, Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes             |
-- | 5        | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                  |
-- | 6        | Vegetarian: BBQ Sauce, Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes             |
-- | 7        | Vegetarian: 2xBacon, BBQ Sauce, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes           |
-- | 8        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                    |
-- | 9        | Meatlovers: 2xBacon, 2xChicken, BBQ Sauce, Beef, Cheese, Mushrooms, Pepperoni, Salami                |
-- | 10       | Meatlovers: 2xBacon, 2xCheese, BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |


-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH all_toppings AS (
    SELECT
        pizza_id,
        REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id,
        1 AS quantity -- Standard toppings count as one
    FROM
        pizza_runner.pizza_recipes
    UNION ALL
    SELECT
        pizza_id,
        REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS topping_id,
        2 AS quantity -- Extras count as two
    FROM
        customer_orders_temp
    WHERE
        extras IS NOT NULL
)
, topping_counts AS (
    SELECT
        topping_id,
        SUM(quantity) AS total_quantity
    FROM
        all_toppings
    GROUP BY
        topping_id
)
SELECT
    pt.topping_name,
    tc.total_quantity
FROM
    topping_counts tc
JOIN
    pizza_runner.pizza_toppings pt ON pt.topping_id = tc.topping_id
ORDER BY
    tc.total_quantity DESC;













