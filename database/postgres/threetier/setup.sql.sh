docker exec -it twotier_data /bin/bash

export PGHOSTADDR=$PGHOST
export PGPORT=$PGPORT
export PGDATABASE=$PGDB
export PGUSER=$PGUSER
export PGPASSWORD=$PGPSWD

docker run -d \
   --name pgadmin \
   --network appdev \
   -p 8080:80 \
   -e PGADMIN_DEFAULT_EMAIL=$PGADMINLOCAL \
   -e PGADMIN_DEFAULT_PASSWORD=$PGADMINPSWD \
   dpage/pgadmin4
# GRANT ALL PRIVILEGES ON DATABASE twotier TO twotier;
# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO twotier;
# GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO twotier;
# ALTER DEFAULT PRIVILEGES FOR USER your_username IN SCHEMA your_schema_name GRANT ALL PRIVILEGES ON TABLES TO your_username;
# ALTER DEFAULT PRIVILEGES FOR USER your_username IN SCHEMA your_schema_name GRANT ALL PRIVILEGES ON SEQUENCES TO your_username;

psql -h db -U twotier -d twotier
psql -h postgres_appdevdb -U appdevdbuser -d appdevdb

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

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(200) NOT NULL
);

-- Enable pgcrypto (once per database)
CREATE EXTENSION IF NOT EXISTS pgcrypto;
INSERT INTO users (username, password_hash)
VALUES ('name', crypt('Name1', gen_salt('bf')));


CREATE TABLE CustomerUsers (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    customer_id INTEGER NOT NULL,
    password_hash TEXT NOT NULL
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
INSERT INTO CustomerUsers (username, customer_id, password_hash)
VALUES ('brentnotme', crypt('securepassword123', gen_salt('bf'))); -- 'bf' indicates bcrypt algorithm
