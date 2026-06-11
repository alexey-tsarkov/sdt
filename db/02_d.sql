-- Выбрать имена (name) всех товаров, по которым не было доставленных заказов (со статусом “complete”)
SELECT m.name
FROM merchandise AS m
LEFT JOIN orders AS o
    ON m.id = o.item_id AND o.status = 'complete'
WHERE o.id IS NULL;

DROP INDEX IF EXISTS idx_item_status ON orders;
DROP INDEX IF EXISTS idx_name ON merchandise;

-- Без индексов
EXPLAIN SELECT m.name
FROM merchandise AS m
LEFT JOIN orders AS o
    ON m.id = o.item_id AND o.status = 'complete'
WHERE o.id IS NULL;

-- Здесь порядок колонок особенно важен, т.к. селективность `item_id` выше
CREATE INDEX idx_item_status orders (item_id, status);

-- Рассуждения как в ршении a: чтение из индекса быстрее, но при этом будут накладные расходы по памяти и замедление записи
-- CREATE INDEX idx_name merchandise (name);

-- С индексами
EXPLAIN SELECT m.name
FROM merchandise AS m
LEFT JOIN orders AS o
    ON m.id = o.item_id AND o.status = 'complete'
WHERE o.id IS NULL;

-- Лучшим решением будет создание счетчиков заказов в таблице `merchandise`
