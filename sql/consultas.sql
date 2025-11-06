-- =========
-- CONSULTAS
-- =========

-- Se asume que la asignacion de vendedores a territorios ocurrio una sola vez para el año 2022
-- el día 2022-01-01 para todos los vendedores.
--UPDATE vendedor_territorio
--SET fecha = '2022-01-01'


-- Cuál es el mejor cliente según sus compras en el 2022?
SELECT c.nombre AS cliente,
	SUM(v.montousd) AS total_compra
FROM cliente c
INNER JOIN venta v ON c.id = v.clienteid
WHERE EXTRACT(YEAR FROM v.fecha) = 2022
GROUP BY c.id
ORDER BY total_compra DESC
LIMIT 1;

-- Cuáles son los 3 mejores vendedores según sus ventas en el 2022, y cuál
-- es el nivel de venta logrado por cada uno de ellos?
SELECT v.nombre AS vendedor,
	SUM(ve.montousd) AS venta_total 
FROM vendedor v
INNER JOIN vendedor_territorio vt ON v.id = vt.vendedorid
INNER JOIN territorio t ON vt.territorioid = t.id
INNER JOIN local l ON t.id = l.territorioid
INNER JOIN venta ve ON l.id = ve.localid
WHERE EXTRACT(YEAR FROM ve.fecha) = 2022
GROUP BY v.id
ORDER BY venta_total DESC
LIMIT 3;

-- Cuáles son las ventas de la empresa mes a mes en el territorio con menos venta del 2022?
SELECT 
	CASE EXTRACT(MONTH FROM v.fecha)
	    WHEN 1 THEN 'Enero'
	    WHEN 2 THEN 'Febrero'
	    WHEN 3 THEN 'Marzo'
	    WHEN 4 THEN 'Abril'
	    WHEN 5 THEN 'Mayo'
	    WHEN 6 THEN 'Junio'
	    WHEN 7 THEN 'Julio'
	    WHEN 8 THEN 'Agosto'
	    WHEN 9 THEN 'Septiembre'
	    WHEN 10 THEN 'Octubre'
	    WHEN 11 THEN 'Noviembre'
	    WHEN 12 THEN 'Diciembre'
	END AS "Mes",
	p.nombre AS "Producto",
	c.nombre AS "Cliente",
	v.preciousd AS "Precio (USD)",
	v.cantidad AS "Cantidad",
	v.montousd AS "Monto (USD)"
FROM venta v
INNER JOIN local l ON v.localid = l.id
INNER JOIN territorio t ON l.territorioid = t.id
INNER JOIN producto p ON v.productoid = p.id
INNER JOIN cliente c ON v.clienteid = c.id
WHERE t.id = (SELECT t.id
				FROM territorio t
				INNER JOIN local l ON t.id = l.territorioid
				INNER JOIN venta v ON l.id = v.localid
				WHERE EXTRACT(YEAR FROM v.fecha) = 2022
				GROUP BY t.id
				ORDER BY SUM(v.montousd)
				LIMIT 1);

-- Cuál es el producto más vendido del 2022?
SELECT p.nombre AS producto, 
	c.nombre AS categoria,
	m.nombre AS marca,
	e.nombre AS comercializador,
	SUM(v.cantidad) AS cantidad
FROM producto p
INNER JOIN venta v ON p.id = v.productoid
INNER JOIN categoria c ON p.categoriaid = c.id
INNER JOIN marca m ON p.marcaid = m.id
INNER JOIN empresa e ON p.empresaid = e.id
WHERE EXTRACT(YEAR FROM v.fecha) = 2022
GROUP BY p.id, c.nombre, m.nombre, e.nombre
ORDER BY cantidad DESC
LIMIT 1;

-- Cuáles son los locales de clientes que no tuvieron ninguna compra en el 2022?
SELECT l.nombre AS local,
	c.nombre AS Cliente,
	t.nombre AS territorio
FROM local l
INNER JOIN cliente c ON l.clienteid = c.id
LEFT JOIN venta v ON c.id = v.clienteid
	AND EXTRACT(YEAR FROM v.fecha) = 2022
INNER JOIN territorio t ON l.territorioid = t.id
WHERE v.id IS NULL

-- Si RESASA vendió 15% más que ACME en la categorías de CALDERAS en el 2022, y cada
-- uno de sus producto participó en el 50% de dichas ventas, cuánto vendió de cada uno
-- de sus productos en el 2022?
SELECT c.id, c.nombre, COUNT(p.id), SUM(v.montousd)
FROM venta v
INNER JOIN producto p ON v.productoid = p.id
INNER JOIN empresa e ON p.empresaid = e.id
INNER JOIN categoria c ON p.categoriaid = c.id
WHERE c.nombre = 'Calderas'
	AND e.nombre = 'Acme'
	AND EXTRACT(YEAR FROM v.fecha) = 2022
GROUP BY c.id

-- Si RESASA hubiera vendido 20% más que ACME en la categoría de calderas, cuál
-- hubiera sido el precio promedio de venta de sus productos?
SELECT c.id, c.nombre, COUNT(p.id), SUM(v.montousd), AVG(v.montousd)
FROM venta v
INNER JOIN producto p ON v.productoid = p.id
INNER JOIN empresa e ON p.empresaid = e.id
INNER JOIN categoria c ON p.categoriaid = c.id
WHERE c.nombre = 'Calderas'
	AND e.nombre = 'Acme'	
GROUP BY c.id






