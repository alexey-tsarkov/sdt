-- Выбрать имена (name) 5 клиентов, которые сделали больше всего заказов в магазине
WITH top5_customers AS (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    ORDER BY COUNT(*) DESC
    LIMIT 5
)
SELECT name
FROM clients
WHERE id IN (SELECT customer_id FROM top5_customers);

-- Здесь дополнительные индексы не нужны, т.к. используются существующие PK и FK
-- Покрывающий индекс `clients`.`name` здесь не принесет пользы потому, что чтение таблицы `clients` здесь ограничено всего 5 записями
-- Ощутимый выигрыш в производительности принесет создание счетчика заказов в таблице `clients`, т.к. больше не потребуется полностью читать таблицу `orders`
EXPLAIN WITH top5_customers AS (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    ORDER BY COUNT(*) DESC
    LIMIT 5
)
SELECT name
FROM clients
WHERE id IN (SELECT customer_id FROM top5_customers);
