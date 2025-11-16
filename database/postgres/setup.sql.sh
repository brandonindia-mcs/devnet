docker exec -it twotier_data /bin/bash

psql -h localhost -U pgadmin -d postgres
psql -h localhost -U appuser -d appdata

## THE TWO COMMANDS ARE FUNCTIONALLY THE SAME
docker run -it --rm --network appdev postgres psql -h postgres_testing -U pgadmin -d postgres
psql -h postgres_testing -U pgadmin -d postgres
function pgconnect {
    blue Connecting to postgres_testing
    docker run -it --rm --network appdev postgres psql -h postgres_testing -U pgadmin -d postgres
}
CREATE USER sa WITH PASSWORD ;
ALTER USER sa WITH SUPERUSER;

export PGHOST=
export PGSSLMODE=

export PGHOSTADDR=172.18.0.2
export PGPORT=5432
export PGDATABASE=
export PGUSER=
export PGPASSWORD=

export PGHOSTADDR=$PGHOST
export PGPORT=$PGPORT
export PGDATABASE=$PGDB
export PGUSER=$PGUSER
export PGPASSWORD=$PGPSWD

psql -h db -U $PGUSER -d $PGDATABASE

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

CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    customer_id INTEGER NOT NULL,
    password_hash TEXT NOT NULL
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
INSERT INTO users (username, customer_id, password_hash)
VALUES ('brentnotme', crypt('securepassword123', gen_salt('bf'))); -- 'bf' indicates bcrypt algorithm


-- ### GRANULAR SCOPE
CREATE DATABASE my_app_db;
CREATE USER app_user WITH PASSWORD 'StrongPassword123!';
GRANT CONNECT ON DATABASE my_app_db TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT CREATE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA public TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, TRUNCATE, REFERENCES, TRIGGER ON TABLES TO app_user;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO app_user;

-- ### BLANKET SCOPE
GRANT ALL PRIVILEGES ON DATABASE your_database TO your_username;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA your_schema TO your_username;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA your_schema TO your_username;
ALTER DEFAULT PRIVILEGES FOR USER your_username IN SCHEMA your_schema GRANT ALL PRIVILEGES ON TABLES TO your_username;
ALTER DEFAULT PRIVILEGES FOR USER your_username IN SCHEMA your_schema GRANT ALL PRIVILEGES ON SEQUENCES TO your_username;
