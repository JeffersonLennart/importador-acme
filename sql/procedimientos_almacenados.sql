-- ===============================
-- IMPORTA DEL EXCEL DE VENDEDORES
-- ===============================
CREATE OR REPLACE PROCEDURE prc_vendedores_importar(
	p_vendedor TEXT,
	p_territorio TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_vendedorid INT;
	v_territorioid INT;
BEGIN
	
	-- Recuperar id del vendedor
	SELECT id INTO v_vendedorid
	FROM vendedor
	WHERE nombre = p_vendedor;
	
	-- Recuperar id del territorio
	SELECT id INTO v_territorioid
	FROM territorio
	WHERE nombre = p_territorio;

	-- Crear vendedor si no existe
	IF v_vendedorid IS NULL THEN
		INSERT INTO vendedor(nombre) VALUES(p_vendedor)
		RETURNING id INTO v_vendedorid;			
	END IF;

	-- Crear territorio si no existe
	IF v_territorioid IS NULL THEN
		INSERT INTO territorio(nombre) VALUES(p_territorio)
		RETURNING id INTO v_territorioid;
	END IF;

	-- Desactivar otras asignaciones del vendedor o territorio
	UPDATE vendedor_territorio
	SET estado = False
	WHERE vendedorid = v_vendedorid OR territorioid = v_territorioid;

	-- Insertar nuevas asignaciones
	INSERT INTO vendedor_territorio(vendedorid, territorioid, fecha, estado)
	VALUES (v_vendedorid, v_territorioid, CURRENT_DATE, True);
	
END;
$$; 

-- ===============================
-- IMPORTA DEL EXCEL DE CLIENTES
-- ===============================
CREATE OR REPLACE PROCEDURE prc_clientes_importar(
	p_cliente TEXT,
	p_industria TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_clienteid INT;
	v_industriaid INT;
BEGIN
	
	-- Recuperar id de la industria
	SELECT id INTO v_industriaid
	FROM industria
	WHERE nombre = p_industria;
	
	-- Crear industria si no existe
	IF v_industriaid IS NULL THEN
		INSERT INTO industria(nombre) VALUES(p_industria)
		RETURNING id INTO v_industriaid;			
	END IF;

	-- Recuperar id del cliente
	SELECT id INTO v_clienteid
	FROM cliente
	WHERE nombre = p_cliente
		AND industriaid = v_industriaid;	

	-- Crear cliente si no existe 
	IF v_clienteid IS NULL THEN
		INSERT INTO cliente(nombre,industriaid) VALUES(p_cliente,v_industriaid)
		RETURNING id INTO v_clienteid;
	END IF;
	
END;
$$; 

-- ===============================
-- IMPORTA DEL EXCEL DE LOCALES
-- ===============================
CREATE OR REPLACE PROCEDURE prc_locales_importar(
	p_local TEXT,
	p_cliente TEXT,
	p_territorio TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_localid INT;
	v_clienteid INT;
	v_territorioid INT;
BEGIN
	
	-- Recuperar id del cliente
	SELECT id INTO v_clienteid
	FROM cliente
	WHERE nombre = p_cliente;
	
	-- Recuperar id del territorio
	SELECT id INTO v_territorioid
	FROM territorio
	WHERE nombre = p_territorio;

	-- Crear territorio si no existe
	IF v_territorioid IS NULL THEN
		INSERT INTO territorio(nombre) VALUES(p_territorio)
		RETURNING id INTO v_territorioid;
	END IF;

	-- Recuperar id del local
	SELECT id INTO v_localid
	FROM local
	WHERE nombre = p_local 
		AND clienteid = v_clienteid
		AND territorioid = v_territorioid;
		
	-- Crear local si no existe
	IF v_localid IS NULL THEN
		INSERT INTO local(nombre,clienteid,territorioid) 
			VALUES(p_local,v_clienteid,v_territorioid);			
	END IF;
	
END;
$$;

-- ===============================
-- IMPORTA DEL EXCEL DE PRODUCTOS
-- ===============================
CREATE OR REPLACE PROCEDURE prc_productos_importar(
	p_producto TEXT,
	p_categoria TEXT,
	p_marca TEXT,
	p_empresa TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_productoid INT;
	v_categoriaid INT;
	v_marcaid INT;
	v_empresaid INT;
	v_empresa_categoria_id INT;
BEGIN
	
	-- Recuperar id de la categoria
	SELECT id INTO v_categoriaid
	FROM categoria
	WHERE nombre = p_categoria;
	
	-- Crear categoria si no existe
	IF v_categoriaid IS NULL THEN
		INSERT INTO categoria(nombre) VALUES(p_categoria)
		RETURNING id INTO v_categoriaid;
	END IF;

	-- Recuperar id de la marca
	SELECT id INTO v_marcaid
	FROM marca
	WHERE nombre = p_marca;

	-- Crear marca si no existe
	IF v_marcaid IS NULL THEN
		INSERT INTO marca(nombre) VALUES(p_marca)
		RETURNING id INTO v_marcaid;
	END IF;

	-- Recuperar id de la empresa
	SELECT id INTO v_empresaid
	FROM empresa
	WHERE nombre = p_empresa;

	-- Crear empresa si no existe
	IF v_empresaid IS NULL THEN
		INSERT INTO empresa(nombre,escompetidor)
			VALUES(p_empresa,
				CASE 
					WHEN p_empresa = 'Acme' THEN False
					ELSE True
				END)
		RETURNING id INTO v_empresaid;
	END IF;

	-- Recuperar id del producto
	SELECT id INTO v_productoid
	FROM producto
	WHERE nombre = p_producto
		AND categoriaid = v_categoriaid
		AND marcaid = v_marcaid
		AND empresaid = v_empresaid;
	
	-- Recuperar id de la relacion empresa_categoria
	SELECT id INTO v_empresa_categoria_id
	FROM empresa_categoria
	WHERE categoriaid = v_categoriaid AND empresaid = v_empresaid;				

	-- Crear la relacion empresa_categoria si no existe
	IF v_empresa_categoria_id IS NULL THEN
		INSERT INTO empresa_categoria(categoriaid,empresaid) VALUES(v_categoriaid,v_empresaid)
		RETURNING id INTO v_empresa_categoria_id;
	END IF;

	-- Crear Producto si no existe
	IF v_productoid IS NULL THEN
		INSERT INTO producto(nombre,categoriaid,marcaid,empresaid) 
			VALUES(p_producto,v_categoriaid,v_marcaid,v_empresaid);			
	END IF;
	
END;
$$;

-- ===========================
-- IMPORTA DEL EXCEL DE VENTAS
-- ===========================
CREATE OR REPLACE PROCEDURE prc_ventas_importar(
	p_fecha TIMESTAMP WITHOUT TIME ZONE,
	p_producto TEXT,
	p_marca TEXT,
	p_cliente TEXT,
	p_local TEXT,
	p_preciousd DECIMAL(18,2),
	p_cantidad INT,
	p_montousd DECIMAL(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_ventaid INT;
	v_productoid INT;
	v_marcaid INT;
	v_clienteid INT;
	v_localid INT;	
BEGIN

	-- Cambiar la fecha
	p_fecha := CAST(p_fecha AS DATE);
	
	-- Recuperar id de la marca
	SELECT id INTO v_marcaid
	FROM marca
	WHERE nombre = p_marca;
	
	-- Crear marca si no existe
	IF v_marcaid IS NULL THEN
		INSERT INTO marca(nombre) VALUES(p_marca)
		RETURNING id INTO v_marcaid;
	END IF;

	-- Recuperar id del producto
	SELECT id INTO v_productoid
	FROM producto
	WHERE nombre = p_producto AND marcaid = v_marcaid;	

	-- Recuperar id del cliente
	SELECT id INTO v_clienteid
	FROM cliente
	WHERE nombre = p_cliente;

	-- Recuperar id del local
	SELECT id INTO v_localid
	FROM local
	WHERE nombre = p_local AND clienteid = v_clienteid;

	-- Recuperar id de la venta
	SELECT id INTO v_ventaid
	FROM venta
	WHERE fecha = p_fecha
		AND productoid = v_productoid
		AND marcaid = v_marcaid
		AND clienteid = v_clienteid
		AND localid = v_localid
		AND preciousd = p_preciousd
		AND cantidad = p_cantidad
		AND montousd = p_montousd;	

	-- Crear venta si no existe
	IF v_ventaid IS NULL THEN
		INSERT INTO venta(fecha,productoid,marcaid,clienteid,localid,preciousd,cantidad,montousd)
			VALUES(p_fecha,v_productoid,v_marcaid,v_clienteid,v_localid,p_preciousd,p_cantidad,p_montousd)
		RETURNING id INTO v_marcaid;
	END IF;	
	
END;
$$;

