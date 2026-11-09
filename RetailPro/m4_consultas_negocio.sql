-- Proyecto: RetailPro- Pre-entrega 4: Consultas SQL de  negocio
-- Archivo:  m4_consultas_negocio.sql
-- Base:     Ventas_Tech_DB (creada en M3)
-- Motor:    SQL Server (SSMS)
-- Alumna:   Nadia Cajal
-- ==========================================================================
USE Ventas_Tech_DB
GO
-- ==========================================================================
-- CONSULTA 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
-- Ticket promedio = total facturado/ cantidad de pedidos.
-- (En este modelo cada fila de ventas es un pedido de un solo producto.)
-- ==========================================================================
SELECT
MONTH(fecha_venta)                            AS mes,
SUM(cantidad * precio_unitario)               AS total_facturado,
COUNT(*)                                      AS cantidad_pedidos,
SUM(cantidad * precio_unitario) / COUNT(*)    AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- ==========================================================================
-- CONSULTA 2: Ranking de productos
-- TOP 5 de productos por total facturado, con unidades vendidas.
-- ==========================================================================
SELECT TOP 5
id_producto,
SUM(cantidad)                        AS unidades_vendidas,
SUM(cantidad * precio_unitario)      AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- ===========================================================================
-- CONSULTA 3: Clientes recurrentes
-- Clientes con mas de un pedido, con cantidad de pedidos y total gastado.
-- ===========================================================================
SELECT
id_cliente,
COUNT(*)                            AS cantidad_pedidos,
SUM(cantidad * precio_unitario)     AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

--=======================================================================
-- CONSULTA 4: Productos por encima/ por debajo del promedio
-- Paso 1: (WITH): se calcula el total facturado de cada producto.
-- Paso 2: se compara cada total con el promedio de los totales por 
-- producto ( no con el promedio de las filas de venta)
--=======================================================================
WITH totales_producto AS(
SELECT
     id_producto,
     SUM(cantidad * precio_unitario)        AS total_facturado
FROM ventas
GROUP BY id_producto
)
SELECT
      id_producto,
      total_facturado,
      CASE
      WHEN total_facturado> (SELECT AVG(total_facturado) FROM totales_producto)
      THEN 'Por encima'
      ELSE 'Por debajo'
      END                  AS comparacion_promedio
FROM totales_producto
ORDER BY total_facturado DESC;

-- =================================================================
-- HALLAZGOS
-- =================================================================
-- 1. El producto 1 concentra el 55,9% de la facturacion de marzo 2024
-- ($3.600 de $6.444). Junto con el producto 3 suman el 76,8%, por lo
-- que la facturacion depende de muy pocos productos.
-- 2. El producto 2 es el que mas unidades vende (13), pero factura solo
-- $364 (5,6% del total): mucho volumen con poco valor por unidad.
-- 3. Los 5 clientes son recurrentes (2 pedidos cada uno), pero los
-- clientes 1 y 5 concentran el 73,6% de la facturacion ($4.740).

