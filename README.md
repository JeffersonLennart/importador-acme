## Project Overview
ACME is a Peruvian industrial equipment supplier serving clients across different industries. The company sells both its own manufactured products and imported equipment for which it has exclusive distribution rights.

Products are grouped into several categories—such as pumps, valves, generators, and boilers—and ACME competes with other vendors within each segment.

Each client has one or more physical locations (up to five nationwide). These locations are organized into predefined sales territories: North, Central, South, Jungle, Central Highlands, Lima Provinces, and Metropolitan Lima. Every territory is assigned to a salesperson responsible for achieving the annual sales targets.

Because territories may be reassigned at different times of the year, the company needs traceability to determine which salesperson was accountable for sales in each territory at any given month.

ACME has commissioned the creation of a PostgreSQL database to store and manage all related business information and enable data queries for decision-making. The company has provided:

- The list of current sales representatives and their assigned territories

- The list of clients and their locations, including associated territories

- The product catalog and main competitors by category

- Historical product sales for 2022

This database will centralize all operational information and support analytical reporting for strategic sales management.

## System Description
This is an ETL process project developed in Python that allows importing data from Excel files, transforming them according to business rules, and loading them into a PostgreSQL database.  
The ETL process is fault-tolerant, meaning it captures internal errors and generates an Excel file containing the problematic records inside the `error` folder for later review.  
It also validates that no required columns in the Excel files contain `NULL` values.

## ETL Process

### 1. Extract
- Reads Excel files using `pandas` from the `data` folder.  
  It supports multiple files and sheets, as long as they follow the defined base format.

### 2. Transform
- Removes duplicate records.
- Normalizes and formats the data.

### 3. Load
- Inserts the cleaned and validated data into the PostgreSQL database.

## Database Configuration
The SQL scripts are located in the `sql` folder.  
First, create the `ACME` database, and then run the scripts `creacion_tablas.sql` and `procedimientos_almacenados.sql`.  
The connection configuration is defined in the `.env` file, which is explained below.

## Local Installation and Configuration

### 1. Clone Repository

```
git https://github.com/JeffersonLennart/importador-acme.git
cd importador-acme
```

### 2. Create Virtual Environment and Install Dependencies

```
python -m venv env
source env/bin/activate  # Linux/macOS
# env\Scripts\activate # Windows

pip install -r requirements.txt
```

### 3. Environment Configuration
Create a `.env` file in the project root and set the environment variables  
(you can use `.env.example` as a template; only change `DB_PASSWORD`):

```
DB_HOST=localhost
DB_PORT=5433
DB_NAME=ACME 
DB_USER=postgres
DB_PASSWORD=**YOUR PASSWORD**
```

### 4. Run the Process
Move the Excel file(s) into the `data` folder.  
Then, in the project root, run:

```
python main.py
```

If any errors occur during execution, an `error` folder will be created containing an Excel file with the problematic rows.


## Database Design
![Diseño de la base de datos](/imgs/diseño_bd.png)

---

## Sample Queries

1. Who is the best client based on purchases in 2022?

```sql
SELECT c.nombre AS cliente,
	SUM(v.montousd) AS total_compra
FROM cliente c
INNER JOIN venta v ON c.id = v.clienteid
WHERE EXTRACT(YEAR FROM v.fecha) = 2022
GROUP BY c.id
ORDER BY total_compra DESC
LIMIT 1;
```

![query_1](/imgs/query_1.png)

2. Which are the top 3 sellers based on sales in 2022, and what total sales did each achieve?

```sql
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
```
![query_2](/imgs/query_2.png)

3. What are the company’s monthly sales in the lowest-performing territory of 2022?

```sql
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
```

![query_3](/imgs/query_3.png)

4. What was the best-selling product of 2022?

```sql
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
```

![query_4](/imgs/query_4.png)

5. Which client locations made no purchases in 2022?

```sql
SELECT l.nombre AS local,
	c.nombre AS Cliente,
	t.nombre AS territorio
FROM local l
INNER JOIN cliente c ON l.clienteid = c.id
LEFT JOIN venta v ON c.id = v.clienteid
	AND EXTRACT(YEAR FROM v.fecha) = 2022
INNER JOIN territorio t ON l.territorioid = t.id
WHERE v.id IS NULL
```

![query_5](/imgs/query_5.png)

6. If RESASA sold 15% more than ACME in the Boilers category in 2022, and each of its products participated equally (50%) in those sales, how much did each product sell in 2022?    

    ```sql
    SELECT c.id, c.nombre, COUNT(p.id), SUM(v.montousd)
    FROM venta v
    INNER JOIN producto p ON v.productoid = p.id
    INNER JOIN empresa e ON p.empresaid = e.id
    INNER JOIN categoria c ON p.categoriaid = c.id
    WHERE c.nombre = 'Calderas'
        AND e.nombre = 'Acme'
        AND EXTRACT(YEAR FROM v.fecha) = 2022
    GROUP BY c.id
    ```

    **RESASA sold $482,372.68 per product in 2022**

7. If RESASA had sold 20% more than ACME in the Boilers category, what would the average selling price of its products have been?  

    ```sql
    SELECT c.id, c.nombre, COUNT(p.id), SUM(v.montousd), AVG(v.montousd)
    FROM venta v
    INNER JOIN producto p ON v.productoid = p.id
    INNER JOIN empresa e ON p.empresaid = e.id
    INNER JOIN categoria c ON p.categoriaid = c.id
    WHERE c.nombre = 'Calderas'
        AND e.nombre = 'Acme'	
    GROUP BY c.id
    ```
    **The average selling price per RESASA product would be $43,769.16**