-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(p.price) AS total_spent
FROM dannys_diner.sales s
JOIN dannys_diner.menu p
ON s.product_id = p.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
-- Customer A spent $76.
-- Customer B spent $74.
-- Customer C spent $36.


-- 2. How many days has each customer visited the restaurant?
SELECT s.customer_id, COUNT(DISTINCT s.order_date) AS visit_count
FROM dannys_diner.sales s
GROUP BY s.customer_id;
-- Customer A visited 4 times.
-- Customer B visited 6 times.
-- Customer C visited 2 times.


-- 3. What was the first item from the menu purchased by each customer?
SELECT s.customer_id, p.product_name
FROM dannys_diner.sales s
JOIN dannys_diner.menu p 
ON s.product_id = p.product_id
WHERE (s.customer_id, s.order_date) IN (
                                            SELECT customer_id, MIN(order_date)
                                            FROM dannys_diner.sales
                                            GROUP BY customer_id
                                       )
ORDER BY s.customer_id;
-- Customer A's first order is curry and sushi.
-- Customer B's first order is curry.
-- Customer C's first order is ramen.


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT p.product_name, COUNT(*) AS no_of_time_purchased
FROM dannys_diner.sales s
JOIN dannys_diner.menu p 
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY no_of_time_purchased DESC
LIMIT 1;
-- Most purchased item on the menu is ramen which was purchased 8 times


-- 5. Which item was the most popular for each customer?
SELECT a.customer_id, a.product_name, a.product_count
FROM
    (
        SELECT s.customer_id, 
               p.product_name, 
               COUNT(p.product_name) AS product_count, 
               RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(p.product_name) DESC) AS RNK1
        FROM dannys_diner.sales s
        JOIN dannys_diner.menu p
        ON s.product_id = p.product_id
        GROUP BY s.customer_id, p.product_name
    ) a
WHERE a.RNK1 = 1;
-- Customer A and Customer C's preferred item is ramen.
-- Customer B enjoys every item on the menu.


-- 6. Which item was purchased first by the customer after they became a member?
SELECT customer_id, product_name
FROM
    (
        SELECT s.customer_id, p.product_name, RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS RNK1
        FROM dannys_diner.sales s
        JOIN dannys_diner.menu p
        ON s.product_id = p.product_id
      	JOIN dannys_diner.members m
      	ON s.customer_id = m.customer_id
      	WHERE m.join_date <= s.order_date 
    ) a
WHERE RNK1 = 1;
-- Customer A's first order as a member is ramen.
-- Customer B's first order as a member is sushi.

    
-- 7. Which item was purchased just before the customer became a member?
SELECT customer_id, product_name
FROM
    (
        SELECT s.customer_id, 
               p.product_name, 
               RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS RNK1
        FROM dannys_diner.sales s
        JOIN dannys_diner.menu p
        ON s.product_id = p.product_id
      	JOIN dannys_diner.members m
      	ON s.customer_id = m.customer_id
      	WHERE m.join_date > s.order_date 
    ) a
WHERE RNK1 = 1;
-- Customer A's order just before becoming a member is sushi and curry.
-- Customer B's order just before becoming a member is sushi.


-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(s.product_id) AS product_count, SUM(p.price) AS amount_spent
FROM dannys_diner.sales s
JOIN dannys_diner.menu p
ON s.product_id = p.product_id
JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
WHERE m.join_date > s.order_date 
GROUP BY s.customer_id
ORDER BY s.customer_id
-- Customer A spent $25 on 2 items.
-- Customer B spent $40 on 3 items.


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, SUM(CASE WHEN p.product_name = 'sushi' THEN p.price * 20 ELSE p.price * 10 END) AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu p 
    ON s.product_id = p.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
-- Customer A has 860 points
-- Customer B has 940 points
-- Customer C has 360 points  


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id, 
       SUM(CASE WHEN s.order_date BETWEEN m.join_date AND m.join_date + INTERVAL '6' DAY THEN p.price * 20
                WHEN p.product_name = 'sushi' THEN p.price * 20 
                ELSE p.price * 10
           END) AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu p 
ON s.product_id = p.product_id
JOIN dannys_diner.members m 
ON s.customer_id = m.customer_id
WHERE s.order_date <= '2021-01-31'
AND s.order_date >= m.join_date
GROUP BY s.customer_id;
-- Customer A has 1020 points
-- Customer B has 320 points


--Join All The Things (Recreate the table with: customer_id, order_date, product_name, price, member (Y/N))
WITH dannys_dinner_all AS (
SELECT 
  s.customer_id, 
  s.order_date,  
  p.product_name, 
  p.price,
  CASE WHEN m.join_date <= s.order_date THEN 'Y'
       ELSE 'N' 
  END AS member_status
FROM dannys_diner.sales s
JOIN dannys_diner.menu p
ON s.product_id = p.product_id
LEFT JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
ORDER BY m.customer_id, s.order_date
)

SELECT * FROM dannys_dinner_all


--Rank All The Things (Rank customer products but only for the records when customers are member)
SELECT *, CASE WHEN member_status = 'N' then NULL 
			         ELSE RANK () OVER (PARTITION BY customer_id, member_status ORDER BY order_date) 
          END AS Ranking
FROM dannys_dinner_all;






