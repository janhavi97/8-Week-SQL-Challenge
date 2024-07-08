-- C. Ingredient Optimisation

-- Create a sequence for auto-incrementing unique identifiers
CREATE SEQUENCE customer_orders_temp_record_id_seq;

-- Add a new column with a default value using the created sequence
ALTER TABLE customer_orders_temp
ADD COLUMN record_id INTEGER DEFAULT nextval('customer_orders_temp_record_id_seq');

CREATE TEMP TABLE exclusions_and_extras AS
SELECT record_id,
	   order_id,
       pizza_id,
       REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS exclusions_topping_id,
       NULL AS extras_topping_id
FROM customer_orders_temp c
WHERE exclusions IS NOT NULL
UNION
SELECT record_id,
	   order_id,
       pizza_id,
       NULL AS exclusions_topping_id,
       REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS extras_topping_id
FROM customer_orders_temp c
WHERE extras IS NOT NULL;


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
FROM exclusions_and_extras ex
JOIN pizza_runner.pizza_toppings t 
ON ex.extras_topping_id = t.topping_id
WHERE ex.extras_topping_id IS NOT NULL
GROUP BY t.topping_name
ORDER BY count_extra_toppings DESC
LIMIT 1;
-- Bacon is the most commonly added extra topping


-- What was the most common exclusion?
SELECT t.topping_name, 
       COUNT(*) AS count_exclusions_toppings
FROM exclusions_and_extras ex
JOIN pizza_runner.pizza_toppings t 
ON ex.exclusions_topping_id = t.topping_id
WHERE ex.exclusions_topping_id IS NOT NULL
GROUP BY t.topping_name
ORDER BY count_exclusions_toppings DESC
LIMIT 1;
-- Cheese is the most common excluded topping


-- Generate an order item for each record in the customers_orders table in the format of one of the following:
  -- Meat Lovers
  -- Meat Lovers - Exclude Beef
  -- Meat Lovers - Extra Bacon
  -- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH exclusion_details AS 
(
    SELECT c.record_id, c.order_id,
           STRING_AGG(DISTINCT t.topping_name, ', ') AS exclusion_list
    FROM exclusions_and_extras c
    JOIN pizza_runner.pizza_toppings t 
    ON c.exclusions LIKE '%' || t.topping_id || '%'
    WHERE c.exclusions IS NOT NULL
    GROUP BY c.record_id, c.order_id
),
extra_details AS 
(
    SELECT c.record_id, c.order_id,
           STRING_AGG(DISTINCT t.topping_name, ', ') AS extra_list
    FROM customer_orders_temp c
    JOIN pizza_runner.pizza_toppings t ON c.extras LIKE '%' || t.topping_id || '%'
    WHERE c.extras IS NOT NULL
    GROUP BY c.record_id, c.order_id
),
order_descriptions AS 
(
    SELECT
        c.record_id,
        c.order_id,
        n.pizza_name,
        COALESCE(ed.exclusion_list, '') AS exclusions,
        COALESCE(ex.extra_list, '') AS extras
    FROM customer_orders_temp c
    JOIN pizza_runner.pizza_names n 
    ON c.pizza_id = n.pizza_id
    LEFT JOIN exclusion_details ed 
    ON c.record_id = ed.record_id
    LEFT JOIN extra_details ex 
    ON c.record_id = ex.record_id
)
SELECT record_id,
       order_id,
       pizza_name || CASE WHEN exclusions <> '' THEN ' - Exclude ' || exclusions ELSE '' END || CASE WHEN extras <> '' THEN ' - Extra ' || extras ELSE '' END AS order_description
FROM order_descriptions
ORDER BY record_id;
-- | record_id | order_id | order_description                                               |
-- | --------- | -------- | --------------------------------------------------------------- |
-- | 1         | 1        | Meatlovers                                                      |
-- | 2         | 2        | Meatlovers                                                      |
-- | 3         | 3        | Meatlovers                                                      |
-- | 4         | 3        | Vegetarian                                                      |
-- | 5         | 4        | Meatlovers - Exclude Cheese                                     |
-- | 6         | 4        | Meatlovers - Exclude Cheese                                     |
-- | 7         | 4        | Vegetarian - Exclude Cheese                                     |
-- | 8         | 5        | Meatlovers - Extra Bacon                                        |
-- | 9         | 6        | Vegetarian                                                      |
-- | 10        | 7        | Vegetarian - Extra Bacon                                        |
-- | 11        | 8        | Meatlovers                                                      |
-- | 12        | 9        | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
-- | 13        | 10       | Meatlovers                                                      |
-- | 14        | 10       | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |
  

-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
  -- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH ingredient_details AS 
(
       SELECT c.record_id,
  		c.order_id,
              c.pizza_id,
              n.pizza_name,
              t.topping_id,
              t.topping_name,
              CASE WHEN c.extras LIKE '%' || t.topping_id || '%' THEN '2x' || t.topping_name ELSE t.topping_name END AS formatted_topping,
              c.exclusions
       FROM customer_orders_temp c
       LEFT JOIN pizza_runner.pizza_recipes r 
       ON c.pizza_id = r.pizza_id
       LEFT JOIN pizza_runner.pizza_toppings t 
       ON r.toppings LIKE '%' || t.topping_id || '%'
       LEFT JOIN pizza_runner.pizza_names n 
       ON c.pizza_id = n.pizza_id
)
SELECT record_id,
       order_id,
       pizza_name || ': ' || STRING_AGG(formatted_topping, ', ' ORDER BY formatted_topping) AS ingredients_list
FROM ingredient_details
WHERE NOT (exclusions IS NOT NULL AND exclusions <> '' AND exclusions LIKE '%' || topping_id || '%')
GROUP BY record_id, order_id, pizza_name;
-- | record_id | order_id | ingredients_list                                                                           |
-- | --------- | -------- | ------------------------------------------------------------------------------------------ |
-- | 1         | 1        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
-- | 2         | 2        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
-- | 3         | 3        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
-- | 3         | 3        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
-- | 4         | 3        | Vegetarian: BBQ Sauce, Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes   |
-- | 5         | 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami                  |
-- | 6         | 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami                  |
-- | 7         | 4        | Vegetarian: BBQ Sauce, Bacon, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes           |
-- | 8         | 5        | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami        |
-- | 9         | 6        | Vegetarian: BBQ Sauce, Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes   |
-- | 10        | 7        | Vegetarian: 2xBacon, BBQ Sauce, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes |
-- | 11        | 8        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
-- | 12        | 9        | Meatlovers: 2xBacon, 2xChicken, BBQ Sauce, Beef, Mushrooms, Pepperoni, Salami              |
-- | 13        | 10       | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
-- | 14        | 10       | Meatlovers: 2xBacon, 2xCheese, Beef, Chicken, Pepperoni, Salami                            |


-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
