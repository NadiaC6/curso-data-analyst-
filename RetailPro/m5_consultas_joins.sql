-- ==============================================================================
-- Proyecto: RetailPro- Pre-entrega 5: Consultas con JOINs
-- Archivo:  m5_consultas_joins.sql
-- Base:     Ventas_Tech_DB (creada en M3)
-- Motor:    SQL Server (SSMS)
-- Alumna:   Nadia Cajal
-- ==============================================================================
USE Ventas_Tech_DB;
GO
-- ==============================================================================
-- CONSULTA 1: Vista base del proyecto (INNER JOIN)
-- Proposito: obtener en una sola fila cada venta con el nombre del cliente,
-- su ciudad, el producto, su categoría y el total. Es la fuente de datos
-- principal para Power BI (ciudad y categoría sirven para agrupar y filtrar).
-- ==============================================================================
SELECT 
    v.fecha_venta,
    c.nombre                               AS cliente,
    c.ciudad,
    p.nombre_producto                      AS producto,
    cat.nombre_categoria                   AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario         AS total_venta
    FROM ventas v
    INNER JOIN clientes c                  ON v.id_cliente = c.id_cliente
    INNER JOIN productos p                 ON v.id_producto = p.id_producto
    INNER JOIN categorias cat              ON p.id_categoria = cat.id_categoria
    ORDER BY v.fecha_venta;
    
    -- Hallazgo: las 10 ventas cruzan correctamente con su cliente, producto y
    -- categoria. Computacion concentra el 76,8% de lo vendido ($4.950 de $6.444).
    
    -- ============================================================================
    -- CONSULTA 2: Clientes sin ventas (LEFT JOIN)
    -- Proposito: detectar clientes registrados que nunca compraron, 
    -- para que el area de CRM los contacte.
    -- ============================================================================
    SELECT
        c.nombre,
        c.email,
        c.fecha_registro
    FROM clientes c
    LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
    WHERE v.id_venta IS NULL;

   -- Hallazgo: 0 de los 5 clientes registrados no compraron (todos tienen al
   -- menos una venta). CRM no necesita una campaña de activacion por ahora.

   -- =============================================================================
   -- CONSULTA 3: Productos sin ventas (LEFT JOIN)
   -- Proposito: detectar productos del catalogo sin ninguna venta registrada,
   -- para que el area de producto revise su stock o su precio.
   -- =============================================================================
   SELECT
       p.nombre_producto,
       cat.nombre_categoria                         AS categoria,
       p.precio
   FROM productos p
   INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
   LEFT JOIN ventas v        ON p.id_producto = v.id_producto
   WHERE v.id_venta IS NULL;
   
   -- Hallazgo: 0 de los 6 productos del catálogo quedaron sin ventas: todos
   -- tuvieron movimiento en marzo. Producto no tiene articulos para discontinuar.
   -- ===============================================================================
   -- CONSULTA 4: Consolidado por canal (UNION ALL)
   -- Proposito: comparar la facturacion de dos periodos de marzo 2024.
   -- La columna canal no existe en las tablas: se crea en cada SELECT con un
   -- texto fijo. Se usa UNION ALL (y no UNION) para que cada venta se cuente
   -- una sola vez, aunque coincida con otra en todos sus valores.
   -- ===============================================================================
   SELECT
       canal,
       SUM(total)                              AS total_canal
    FROM (
       SELECT fecha_venta, cantidad * precio_unitario AS total,'Periodo 1 (05 al 10/03)' AS canal
       FROM ventas
       WHERE fecha_venta <= '2024-03-10' 

      UNION ALL
      SELECT fecha_venta, cantidad * precio_unitario AS total, 'Periodo 2 (11 al 15/03)' AS canal
      FROM ventas
      WHERE fecha_venta > '2024-03-10'
      ) AS consolidado
      GROUP BY canal
      ORDER BY canal;

     -- Hallazgo: el Periodo 1 (05 al 10/03) facturo $3.620 (56,2%) y el
     -- Periodo 2 (11 al 15/03) $2.824 (43,8%): las ventas bajaron en la 
     -- segunda mitad del periodo, aunque con la misma cantidad de pedidos (5 y 5).
