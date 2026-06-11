SET FOREIGN_KEY_CHECKS = 0;

CREATE OR REPLACE TABLE clients (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE OR REPLACE TABLE merchandise (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id)
);

CREATE OR REPLACE TABLE orders (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    item_id INT UNSIGNED NOT NULL,
    customer_id INT UNSIGNED NOT NULL,
    comment TEXT NOT NULL DEFAULT '',
    status ENUM('new', 'complete') NOT NULL DEFAULT 'new',
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_orders_item_id FOREIGN KEY (item_id) 
        REFERENCES merchandise(id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_orders_customer_id FOREIGN KEY (customer_id) 
        REFERENCES clients(id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
    -- Индексы для оптимизации запросов
    -- INDEX idx_customer_date (customer_id, order_date),
    -- INDEX idx_item_status (item_id, status)
);

SET FOREIGN_KEY_CHECKS = 1;
