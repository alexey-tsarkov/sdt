-- Выбрать имена (name) 10 клиентов, которые сделали заказы на наибольшую сумму
WITH top10_customers AS (
    SELECT o.customer_id
    FROM orders AS o
    JOIN merchandise AS m
        ON o.item_id = m.id
    GROUP BY o.customer_id
    ORDER BY SUM(price) DESC
    LIMIT 10
)
SELECT name
FROM clients
WHERE id IN (SELECT customer_id FROM top10_customers);

DROP INDEX IF EXISTS idx_name ON (clients);
DROP INDEX IF EXISTS idx_price ON (merchandise);

-- Без индексов
EXPLAIN WITH top10_customers AS (
    SELECT o.customer_id
    FROM orders AS o
    JOIN merchandise AS m
        ON o.item_id = m.id
    GROUP BY o.customer_id
    ORDER BY SUM(price) DESC
    LIMIT 10
)
SELECT name
FROM clients
WHERE id IN (SELECT customer_id FROM top10_customers);

CREATE INDEX idx_price merchandise (price);

-- Необязательно, рассуждения как в задании b
-- CREATE INDEX idx_name clients (name);

-- Теперь с индексами
EXPLAIN WITH top10_customers AS (
    SELECT o.customer_id
    FROM orders AS o
    JOIN merchandise AS m
        ON o.item_id = m.id
    GROUP BY o.customer_id
    ORDER BY SUM(price) DESC
    LIMIT 10
)
SELECT name
FROM clients
WHERE id IN (SELECT customer_id FROM top10_customers);

-- Хорошей оптимизацией будет сохранение стоимости товара в таблице `orders`
-- При этом в заказе цена товара останется актуальной на момент создания, хотя в таблице `merchandise` она может измениться
