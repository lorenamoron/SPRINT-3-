
-- SPRINT 3 · NIVEL 2: LIMPIEZA Y TRANSFORMACIÓN (ELT)
-- Autora: Lorena
-- Entorno: BigQuery (GoogleSQL)

-- =====================================================================
-- EJERCICIO 1: Limpieza de productos
-- Tabla: sprint3_silver.products_clean

CREATE OR REPLACE TABLE `sprint3_silver.products_clean` AS
SELECT
  id AS product_id,
  product_name AS name,
  SAFE_CAST(price AS FLOAT64) AS price,
  colour,
  weight,
  SAFE_CAST(REPLACE(warehouse_id, 'WH-', '') AS INT64) AS warehouse_id,
  category,
  brand,
  cost,
  launch_date
FROM `sprint3_bronze.products_raw`;

-- Verificación: SAFE_CAST no debe haber generado valores nulos
SELECT
  COUNTIF(warehouse_id IS NULL) AS wh_nulos,
  COUNTIF(price IS NULL)        AS price_nulos
FROM `sprint3_silver.products_clean`;

-- =====================================================================
-- EJERCICIO 2: Creación neta de transacciones
-- Tabla: sprint3_silver.transactions_clean

CREATE OR REPLACE TABLE `sprint3_silver.transactions_clean` AS
SELECT
  id AS transaction_id,
  card_id,
  business_id,
  CAST(`timestamp` AS TIMESTAMP) AS `timestamp`,
  IFNULL(SAFE_CAST(amount AS FLOAT64), 0) AS amount,
  declined,
  ARRAY(SELECT CAST(TRIM(x) AS INT64) FROM UNNEST(SPLIT(product_ids, ',')) AS x) AS product_ids,
  user_id,
  SAFE_CAST(lat AS FLOAT64) AS lat,
  SAFE_CAST(longitude AS FLOAT64) AS longitude
FROM `sprint3_bronze.transactions_raw_native`;

-- =====================================================================
-- EJERCICIO 3: Unificación de usuarios (UNION ALL)
-- Tabla: sprint3_silver.users_combined

CREATE OR REPLACE TABLE `sprint3_silver.users_combined` AS
WITH usuarios_union AS (
  SELECT
    id, name, surname, phone, birth_date, country, city, postal_code, address,
    'Europa' AS origen
  FROM `sprint3_bronze.european_users_raw`
  UNION ALL
  SELECT
    id, name, surname, phone, birth_date, country, city, postal_code, address,
    'EE. UU.' AS origen
  FROM `sprint3_bronze.american_users_raw`
)
SELECT
  id AS user_id,
  name,
  surname,
  phone,
  birth_date,
  country,
  city,
  postal_code,
  address,
  origen
FROM usuarios_union;

-- =====================================================================
-- EJERCICIO 4: Materialización de empresas y tarjetas de crédito
-- Tablas: sprint3_silver.companies_clean · sprint3_silver.credit_cards_clean

CREATE OR REPLACE TABLE `sprint3_silver.companies_clean` AS
SELECT
  company_id,
  company_name,
  phone,
  email,
  country,
  website
FROM `sprint3_bronze.companies_raw`;

CREATE OR REPLACE TABLE `sprint3_silver.credit_cards_clean` AS
SELECT
  id AS card_id,
  user_id,
  iban,
  pan,
  pin,
  cvv,
  track1,
  track2,
  expiring_date
FROM `sprint3_bronze.credit_cards_raw`;
