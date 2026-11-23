DROP TABLE IF EXISTS raw_superstore;

CREATE TABLE raw_superstore (
    row_id          INTEGER PRIMARY KEY,
    order_id        TEXT NOT NULL,
    order_date      TEXT NOT NULL,
    ship_date       TEXT NOT NULL,
    ship_mode       TEXT,
    customer_id     TEXT NOT NULL,
    customer_name   TEXT,
    segment         TEXT,
    country         TEXT,
    city            TEXT,
    state           TEXT,
    postal_code     TEXT,
    region          TEXT,
    product_id      TEXT NOT NULL,
    category        TEXT,
    sub_category    TEXT,
    product_name    TEXT,
    sales           REAL NOT NULL,
    quantity        INTEGER NOT NULL,
    discount        REAL NOT NULL,
    profit          REAL NOT NULL
);