-- Выбрать имена (name) всех клиентов, которые не делали заказы в последние 7 дней
SELECT c.name
FROM clients c
LEFT JOIN orders o ON c.id = o.customer_id 
    AND o.order_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
WHERE o.id IS NULL;

DROP INDEX IF EXISTS idx_clients_name ON clients;
DROP INDEX IF EXISTS idx_orders_customer_date ON orders;

-- Без индексов
EXPLAIN SELECT c.name
FROM clients c
LEFT JOIN orders o ON c.id = o.customer_id 
    AND o.order_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
WHERE o.id IS NULL;

-- Можно добавить покрывающий индекс, но это приведет к повышенному расходу памяти из-за строкового поля и замеделнию записи
-- CREATE INDEX idx_clients_name ON clients (id, name);

CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date);

-- С индексами
EXPLAIN SELECT c.name
FROM clients c
LEFT JOIN orders o ON c.id = o.customer_id 
    AND o.order_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
WHERE o.id IS NULL;
