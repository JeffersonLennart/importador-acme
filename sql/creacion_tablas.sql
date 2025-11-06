-- ==================
-- CREACIÓN DE TABLAS
-- ==================

-- Tabla: Empresa
CREATE TABLE Empresa (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT,
    escompetidor BOOLEAN
);

-- Tabla: Categoria
CREATE TABLE Categoria (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT
);

-- Tabla: Marca
CREATE TABLE Marca (
    id SERIAL PRIMARY KEY,
    nombre TEXT
);

-- Tabla: Producto
CREATE TABLE Producto (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT,
    categoriaid INT,
    marcaid INT,
    empresaid INT,    
    FOREIGN KEY (categoriaid) REFERENCES Categoria(id),
    FOREIGN KEY (marcaid) REFERENCES Marca(id),
    FOREIGN KEY (empresaid) REFERENCES Empresa(id)
);

-- Tabla intermedia: empresa_categoria
CREATE TABLE empresa_categoria (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    categoriaid INT,
    empresaid INT,
    FOREIGN KEY (categoriaid) REFERENCES Categoria(id),
    FOREIGN KEY (empresaid) REFERENCES Empresa(id)
);

-- Tabla: Industria
CREATE TABLE Industria (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT
);

-- Tabla: Cliente
CREATE TABLE Cliente (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT,
    industriaid INT,
	FOREIGN KEY (industriaid) REFERENCES Industria(id)
);

-- Tabla: Territorio
CREATE TABLE Territorio (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT
);

-- Tabla: Local
CREATE TABLE Local (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT,
    clienteid INT,
    territorioid INT,    
    FOREIGN KEY (clienteid) REFERENCES Cliente(id),
    FOREIGN KEY (territorioid) REFERENCES Territorio(id)
);

-- Tabla: Vendedor
CREATE TABLE Vendedor (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT
);

-- Tabla intermedia: vendedor_territorio
CREATE TABLE vendedor_territorio (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vendedorid INT,
    territorioid INT,
    fecha DATE,
	estado BOOLEAN,
    FOREIGN KEY (vendedorid) REFERENCES Vendedor(id),
    FOREIGN KEY (territorioid) REFERENCES Territorio(id)
);

-- Tabla: Venta
CREATE TABLE Venta (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha DATE,
    productoid INT,
    marcaid INT,
    clienteid INT,
    localid INT,
    preciousd DECIMAL(18,2),
    cantidad INT,
    montousd DECIMAL(18,2),    
    FOREIGN KEY (productoid) REFERENCES Producto(id) ON DELETE CASCADE,
    FOREIGN KEY (marcaid) REFERENCES Marca(id),
    FOREIGN KEY (clienteid) REFERENCES Cliente(id),
    FOREIGN KEY (localid) REFERENCES Local(id) ON DELETE CASCADE
);