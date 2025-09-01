docker exec -it twotier_data /bin/bash

export PGHOST=
export PGSSLMODE=

export PGHOSTADDR=$PGHOST
export PGPORT=$PGPORT
export PGDATABASE=$PGDB
export PGUSER=$PGUSER
export PGPASSWORD=$PGPSWD


# GRANT ALL PRIVILEGES ON DATABASE twotier TO twotier;
# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO twotier;
# GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO twotier;
# ALTER DEFAULT PRIVILEGES FOR USER your_username IN SCHEMA your_schema_name GRANT ALL PRIVILEGES ON TABLES TO your_username;
# ALTER DEFAULT PRIVILEGES FOR USER your_username IN SCHEMA your_schema_name GRANT ALL PRIVILEGES ON SEQUENCES TO your_username;

psql -h db -U twotier -d twotier

CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE
);
INSERT INTO Customers (first_name,last_name,email) VALUES ('brent','notme','brent.notme@domain.com');
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
INSERT INTO Orders (customer_id,order_date,total_amount) VALUES (1,NOW(),100.99);
SELECT order_date,first_name,last_name,total_amount FROM Customers c JOIN Orders o ON c.customer_id=o.customer_id;
