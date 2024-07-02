-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) as total_spent
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
-- Customer A spent $76.
-- Customer B spent $74.
-- Customer C spent $36.


-- 2. How many days has each customer visited the restaurant?
SELECT s.customer_id, COUNT(DISTINCT s.order_date) as visit_count
FROM dannys_diner.sales s
GROUP BY s.customer_id;
-- Customer A visited 4 times.
-- Customer B visited 6 times.
-- Customer C visited 2 times.


-- 3. What was the first item from the menu purchased by each customer?
SELECT a.customer_id, a.product_name
FROM
    (
        SELECT s.customer_id, m.product_name, RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS RNK1
        FROM dannys_diner.sales s
        JOIN dannys_diner.menu m
        ON s.product_id = m.product_id
        GROUP BY s.customer_id, m.product_name, s.order_date
    ) a
WHERE a.RNK1 = 1;
-- Customer A's first order is curry and sushi.
-- Customer B's first order is curry.
-- Customer C's first order is ramen.


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(s.product_id) as no_of_time_purchased
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY SUM(s.product_id) DESC
LIMIT 1;
-- Most purchased item on the menu is ramen which was purchased 8 times


-- 5. Which item was the most popular for each customer?
SELECT a.customer_id, a.product_name, a.product_count
FROM
    (
        SELECT s.customer_id, m.product_name, COUNT(m.product_name) as product_count, RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(m.product_name) DESC) AS RNK1
        FROM dannys_diner.sales s
        JOIN dannys_diner.menu m
        ON s.product_id = m.product_id
        GROUP BY s.customer_id, m.product_name
    ) a
WHERE a.RNK1 = 1;
-- Customer A and Customer C's preferred item is ramen.
-- Customer B enjoys every item on the menu.


-- 6. Which item was purchased first by the customer after they became a member?


-- 7. Which item was purchased just before the customer became a member?


-- 8. What is the total items and amount spent for each member before they became a member?


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


