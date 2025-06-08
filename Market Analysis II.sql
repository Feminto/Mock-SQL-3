-- Solution for Mock SQL 3 question : Market Analysis II
-- Method 1
WITH cnt AS (
    SELECT  seller_id,
            COUNT(*) cnt
    FROM orders
    GROUP BY seller_id
),
main AS (
SELECT  user_id AS seller_id,
        2nd_item_fav_brand,
        rwn
FROM (
    SELECT  u.user_id,
            -- o.order_date,
            -- i.item_brand,
            -- u.favorite_brand,
            CASE
                WHEN i.item_brand = u.favorite_brand AND c.cnt > 1 THEN 'yes'
                ELSE 'no'
            END AS 2nd_item_fav_brand,
            ROW_NUMBER() OVER(PARTITION BY u.user_id ORDER BY o.order_date) AS rwn
    FROM users u
    LEFT JOIN orders o
    ON o.seller_id = u.user_id
    LEFT JOIN items i
    ON o.item_id = i.item_id
    LEFT JOIN cnt c
    ON u.user_id = c.seller_id
    ORDER BY u.user_id, o.order_date
    ) a
WHERE rwn IN (1,2)
)
SELECT  seller_id,
        2nd_item_fav_brand
FROM main
WHERE (seller_id, rwn) IN (SELECT seller_id, MAX(rwn) FROM main GROUP BY seller_id);

-- Method 2
WITH cte AS (
    SELECT  order_date,
            item_brand,
            seller_id,
            RANK() OVER(PARTITION BY o.seller_id ORDER BY o.order_date) AS 'rnk'
    FROM orders o
    JOIN items i
    ON o.item_id = i.item_id
),
cte2 AS (
    SELECT  *
    FROM cte 
    WHERE rnk = 2
)
SELECT  user_id AS 'seller_id',
        CASE
            WHEN rnk = 2 AND item_brand = favorite_brand THEN 'yes'
            ELSE 'no'
        END AS '2nd_item_fav_brand'
FROM users
LEFT JOIN cte2
ON cte2.seller_id = users.user_id;