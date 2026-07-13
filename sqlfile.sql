-- Active: 1770309306489@@127.0.0.1@5432@costco_data
SELECT
    *
FROM
    customers;

SELECT
    *
FROM
    products;

SELECT
    *
FROM
    sales;

-- find the duplicates and remove them 
SELECT
    order_id,
    count(*)
FROM
    sales
GROUP BY
    1
HAVING
    count(*) > 1;

WITH cta AS (
    SELECT
        ctid,
        ROW_NUMBER() OVER(
            PARTITION BY order_id
            ORDER BY
                order_date DESC
        ) AS row_num
    FROM
        sales
)
DELETE FROM
    sales
WHERE
    ctid IN(
        SELECT
            ctid
        FROM
            cta
        WHERE
            row_num > 1
    );

-- cheke nulls 
SELECT
    *
FROM
    sales
WHERE
    order_id IS NULL
    OR order_date IS NULL
    OR ship_date IS NULL
    OR ship_mode IS NULL
    OR customer_id IS NULL
    OR product_id IS NULL
    OR qty IS NULL
    OR discount IS NULL;

SELECT
    *
FROM
    customers
WHERE
    customer_id IS NULL
    OR customer_name IS NULL
    OR "country-city" IS NULL
    OR state IS NULL
    OR postal_code IS NULL
    OR region IS NULL;

SELECT
    *
FROM
    products
WHERE
    product_id IS NULL
    OR product_name IS NULL
    OR category IS NULL
    OR "sub-category" IS NULL
    OR unit_price IS NULL
    OR cogs IS NULL;

SELECT
    *
FROM
    sales;

SELECT
    count(*) FILTER (
        WHERE
            order_id IS NULL
    ) AS order_id_nulls,
    count(*) FILTER (
        WHERE
            order_date IS NULL
    ) AS order_date_nulls,
    count(*) FILTER (
        WHERE
            ship_date IS NULL
    ) AS ship_date_nulls,
    count(*) FILTER (
        WHERE
            ship_mode IS NULL
    ) AS ship_mode_nulls,
    count(*) FILTER (
        WHERE
            customer_id IS NULL
    ) AS customer_id_nulls,
    count(*) FILTER (
        WHERE
            product_id IS NULL
    ) AS product_id_nulls,
    count(*) FILTER (
        WHERE
            qty IS NULL
    ) AS qty_nulls,
    count(*) FILTER (
        WHERE
            discount IS NULL
    ) AS discount_nulls
FROM
    sales;

SELECT
    *
FROM
    sales
WHERE
    qty IS NULL;

SELECT
    count(*) FILTER (
        WHERE
            customer_id IS NULL
    ) AS customer_id_nulls,
    count(*) FILTER (
        WHERE
            customer_name IS NULL
    ) AS customer_name_nulls,
    count(*) FILTER (
        WHERE
            segment IS NULL
    ) AS segment_nulls,
    count(*) FILTER (
        WHERE
            "country-city" IS NULL
    ) AS country_city_nulls,
    count(*) FILTER (
        WHERE
            state IS NULL
    ) AS state_nulls,
    count(*) FILTER (
        WHERE
            postal_code IS NULL
    ) AS postal_code_nulls,
    count(*) FILTER (
        WHERE
            region IS NULL
    ) AS region_nulls
FROM
    customers;

SELECT
    count(*) FILTER (
        WHERE
            product_id IS NULL
    ) AS product_id_nulls,
    count(*) FILTER (
        WHERE
            product_name IS NULL
    ) AS product_name_nulls,
    count(*) FILTER (
        WHERE
            category IS NULL
    ) AS category_nulls,
    count(*) FILTER (
        WHERE
            "sub-category" IS NULL
    ) AS sub_category_nulls,
    count(*) FILTER (
        WHERE
            unit_price IS NULL
    ) AS unit_price_nulls,
    count(*) FILTER (
        WHERE
            cogs IS NULL
    ) AS cogs_nulls
FROM
    products;

SELECT
    round(avg(qty))
FROM
    sales
WHERE
    qty IS NOT NULL;

SELECT
    qty,
    count(*) AS frequency
FROM
    sales
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT
    1;

UPDATE
    sales
SET
    qty = (
        SELECT
            qty
        FROM
            (
                SELECT
                    qty,
                    count(*) AS frequency
                FROM
                    sales
                GROUP BY
                    qty
                ORDER BY
                    2 DESC
                LIMIT
                    1
            )
    )
WHERE
    qty IS NULL;

SELECT
    *
FROM
    sales;

SELECT
    *
FROM
    products;