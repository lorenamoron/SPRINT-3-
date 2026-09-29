
-- SPRINT 3 - NIVEL 1
-- Proyecto: sprint3-analytics-lorena-moron
-- Ubicación de todos los datasets: EU
-- ============================================================
-- EJERCICIO 1: Arquitectura de Datos (Lógica vs. Física)

-- sprint3_bronze: creado mediante la Interfaz Gráfica (UI) de BigQuery
-- (sin código SQL asociado)

-- sprint3_silver: creado mediante código SQL
CREATE OR REPLACE SCHEMA `sprint3-analytics-lorena-moron.sprint3_silver`
OPTIONS (
  location = 'EU'
);

-- sprint3_gold: creado mediante Cloud Shell (comando bq, no es SQL)
-- bq --location=EU mk --dataset sprint3_gold


-- ============================================================
-- EJERCICIO 2: Admisión de capa Bronze (Tablas Externas)

-- Creamos la tabla transactions
CREATE OR REPLACE EXTERNAL TABLE `sprint3-analytics-lorena-moron.sprint3_bronze.transactions_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/ERP/transactions.csv'],
  skip_leading_rows = 1,
  field_delimiter = ';'
);
-- Creamos la tabla companies
CREATE OR REPLACE EXTERNAL TABLE `sprint3-analytics-lorena-moron.sprint3_bronze.companies_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/ERP/companies.csv'],
  skip_leading_rows = 1,
  field_delimiter = ';'
  
  -- hacemos un select para poder ver su contenido y asi designar manualmente los nombres
  -- de las columnas, y su tipo de dato adecuadamente
  SELECT *
  FROM `sprint3-analytics-lorena-moron.sprint3_bronze.companies_raw`
  LIMIT 5;
  
  -- reemplazamos la tabla companies ahora si especificando nombre de columnas y tipo de dato en cada caso
CREATE OR REPLACE EXTERNAL TABLE `sprint3-analytics-lorena-moron.sprint3_bronze.companies_raw`
(
  company_id STRING,
  company_name STRING,
  phone STRING,
  email STRING,
  country STRING,
  website STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/ERP/companies.csv'],
  skip_leading_rows = 1
);

-- Creamos la tabla american_users
CREATE OR REPLACE EXTERNAL TABLE `sprint3-analytics-lorena-moron.sprint3_bronze.american_users_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/CRM/american_users.csv'],
  skip_leading_rows = 1
);

-- Creamos la tabla european_users
CREATE EXTERNAL TABLE `sprint3-analytics-lorena-moron.sprint3_bronze.european_users_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/CRM/european_users.csv'],
  skip_leading_rows = 1
);

-- Creamos la tabla credit_cards
CREATE EXTERNAL TABLE `sprint3-analytics-lorena-moron.sprint3_bronze.credit_cards_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/CRM/credit_cards.csv'],
  skip_leading_rows = 1
);

-- ============================================================
-- EJERCICIO 3: Subida de Datos Locales

-- products_raw: creado mediante subida manual del archivo local (interfaz gráfica)
-- Tabla nativa (no externa), sin código SQL asociado a su creación.


-- ============================================================
-- EJERCICIO 4: Arquitectura y rendimiento

-- a) Materialización de datos (generada con asistencia de Gemini,
--    validada manualmente antes de ejecutar)
CREATE OR REPLACE TABLE `sprint3-analytics-lorena-moron.sprint3_bronze.transactions_raw_native` AS
SELECT
  *
FROM
  `sprint3-analytics-lorena-moron.sprint3_bronze.transactions_raw`;

-- b) Auditoría de costes: comparación de bytes procesados/facturados
--    al leer una sola columna en tabla externa vs. tabla nativa
-- Select id en tabla externa
SELECT id
FROM `sprint3-analytics-lorena-moron.sprint3_bronze.transactions_raw`;

-- Select id en tabla nativa
SELECT id
FROM `sprint3-analytics-lorena-moron.sprint3_bronze.transactions_raw_native`;

-- c) El peligro del LIMIT: misma comparación, añadiendo LIMIT 10

-- LIMIT en tabla externa
SELECT id
FROM `sprint3-analytics-lorena-moron.sprint3_bronze.transactions_raw`
LIMIT 10;

-- LIMIT en tabla nativa
SELECT id
FROM `sprint3-analytics-lorena-moron.sprint3_bronze.transactions_raw_native`
LIMIT 10;

-- ============================================================
-- EJERCICIO 5: Adaptación de la sintaxis (Reporting)
-- Los 5 días con más ingresos en 2021

SELECT ROUND(SUM(amount), 2) AS total_ingresos, DATE(`timestamp`) AS fecha
FROM `sprint3-analytics-lorena-moron.sprint3_bronze.transactions_raw_native`
WHERE EXTRACT(YEAR FROM timestamp) = 2021
GROUP BY DATE(`timestamp`)
ORDER BY total_ingresos DESC
LIMIT 5;

-- ============================================================
-- EJERCICIO 6: Consultas complejas (JOIN)
-- Empresas con transacciones entre 100-200€ en fechas específicas

SELECT
c.company_name AS nombre_empresa,
c.country AS pais,
DATE(t.`timestamp`) AS fecha
FROM `sprint3-analytics-lorena-moron.sprint3_bronze.transactions_raw_native` AS t
JOIN `sprint3-analytics-lorena-moron.sprint3_bronze.companies_raw` AS c
ON t.business_id = c.company_id
WHERE t.amount BETWEEN 100 AND 200
AND DATE(t.`timestamp`) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY 1;
