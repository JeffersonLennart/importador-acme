-- ==================
-- CREACIÓN DE TABLAS
-- ==================

-- Tabla: Empresa
CREATE TABLE Empresa (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL,
    escompetidor BOOLEAN NOT NULL
);

-- Tabla: Categoria
CREATE TABLE Categoria (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL
);

-- Tabla: Marca
CREATE TABLE Marca (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

-- Tabla: Producto
CREATE TABLE Producto (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL,
    categoriaid INT NOT NULL,
    marcaid INT NOT NULL,
    empresaid INT NOT NULL,    
    FOREIGN KEY (categoriaid) REFERENCES Categoria(id),
    FOREIGN KEY (marcaid) REFERENCES Marca(id),
    FOREIGN KEY (empresaid) REFERENCES Empresa(id)
);

-- Tabla intermedia: empresa_categoria
CREATE TABLE empresa_categoria (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    categoriaid INT NOT NULL,
    empresaid INT NOT NULL,
    FOREIGN KEY (categoriaid) REFERENCES Categoria(id),
    FOREIGN KEY (empresaid) REFERENCES Empresa(id)
);

-- Tabla: Industria
CREATE TABLE Industria (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL
);

-- Tabla: Cliente
CREATE TABLE Cliente (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL,
    industriaid INT NOT NULL,
	FOREIGN KEY (industriaid) REFERENCES Industria(id)
);

-- Tabla: Territorio
CREATE TABLE Territorio (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL
);

-- Tabla: Local
CREATE TABLE Local (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL,
    clienteid INT NOT NULL,
    territorioid INT NOT NULL,    
    FOREIGN KEY (clienteid) REFERENCES Cliente(id) ON DELETE CASCADE,
    FOREIGN KEY (territorioid) REFERENCES Territorio(id)
);

-- Tabla: Vendedor
CREATE TABLE Vendedor (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL
);

-- Tabla intermedia: vendedor_territorio
CREATE TABLE vendedor_territorio (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vendedorid INT NOT NULL,
    territorioid INT NOT NULL,
    fecha DATE NOT NULL,
	estado BOOLEAN NOT NULL,
    FOREIGN KEY (vendedorid) REFERENCES Vendedor(id),
    FOREIGN KEY (territorioid) REFERENCES Territorio(id)
);

-- Tabla: Venta
CREATE TABLE Venta (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha DATE NOT NULL,
    productoid INT NOT NULL,
    marcaid INT NOT NULL,
    clienteid INT NOT NULL,
    localid INT NOT NULL,
    preciousd DECIMAL(18,2) NOT NULL,
    cantidad INT NOT NULL,
    montousd DECIMAL(18,2) NOT NULL,    
    FOREIGN KEY (productoid) REFERENCES Producto(id) ON DELETE CASCADE,
    FOREIGN KEY (marcaid) REFERENCES Marca(id),
    FOREIGN KEY (clienteid) REFERENCES Cliente(id) ON DELETE CASCADE,
    FOREIGN KEY (localid) REFERENCES Local(id) ON DELETE CASCADE
);