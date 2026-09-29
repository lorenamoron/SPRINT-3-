
-- SPRINT 3 · NIVEL 3: PRESENTACIÓN DE DATOS Y CREACIÓN DE VISTAS
-- CAPA GOLD
-- Autora: Lorena
-- Entorno: BigQuery (GoogleSQL)

-- =====================================================================
-- EJERCICIO 1: La visión del marketing (lógica empresarial)
-- Vista: sprint3_gold.v_marketing_kpis

CREATE OR REPLACE VIEW `sprint3_gold.v_marketing_kpis` AS
SELECT
  c.company_id,
  c.company_name,
  c.phone,
  c.country,
  ROUND(AVG(t.amount), 2) AS avg_purchase,
  CASE
    WHEN AVG(t.amount) > 260 THEN 'Premium'
    ELSE 'Estándar'
  END AS client_tier
FROM `sprint3_silver.companies_clean` AS c
JOIN `sprint3_silver.transactions_clean` AS t
  ON c.company_id = t.business_id
WHERE t.declined = 0 AND t.amount > 0
GROUP BY c.company_id, c.company_name, c.phone, c.country;

-- Entrega: Premium primero y, dentro de cada grupo, mayor compra media.
-- El CASE asigna prioridad (1 = Premium, 2 = Estándar) para que el orden
-- responda a la lógica de negocio y no al orden alfabético.
SELECT *
FROM `sprint3_gold.v_marketing_kpis`
ORDER BY avg_purchase DESC;

-- =====================================================================
-- EJERCICIO 2: Clasificación de productos (el poder de los arrays)
-- Tabla: sprint3_gold.product_sales_ranking

CREATE OR REPLACE TABLE `sprint3_gold.product_sales_ranking` AS
WITH ventas AS (
  SELECT
    product_id,
    COUNT(*) AS total_sold
  FROM `sprint3_silver.transactions_clean` AS t,
       UNNEST(t.product_ids) AS product_id
  WHERE t.declined = 0
  GROUP BY product_id
)
SELECT
  p.product_id,
  p.name,
  p.price,
  p.colour,
  IFNULL(v.total_sold, 0) AS total_sold
FROM `sprint3_silver.products_clean` AS p
LEFT JOIN ventas AS v
  ON p.product_id = v.product_id
ORDER BY total_sold DESC;

-- =====================================================================
-- EJERCICIO 3: Exportación de resultados (Reverse ETL)
-- Destino: Google Sheets

SELECT *
FROM `sprint3_gold.product_sales_ranking`
ORDER BY total_sold DESC;
