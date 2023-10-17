CREATE DATABASE Clinica
GO

USE Clinica;
GO


CREATE TABLE TipoEmpleado (
    IdTipoEmpleado INT PRIMARY KEY NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Empleado (
    IdEmpleado INT PRIMARY KEY NOT NULL,
    Documento NVARCHAR(50) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    Direccion NVARCHAR(50),
    Telefono NVARCHAR(50),
    Clave Char(20) NOT NULL,
    IdTipoEmpleado INT FOREIGN KEY REFERENCES TipoEmpleado(IdTipoEmpleado),
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Proveedor (
    IdProveedor INT PRIMARY KEY NOT NULL,
    Documento NVARCHAR(50) NOT NULL,
    RazonSocial NVARCHAR(50) NOT NULL,
    Correo NVARCHAR(50),
    Telefono NVARCHAR(50),
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Categoria (
    IdCategoria INT PRIMARY KEY NOT NULL,
    Descripcion NVARCHAR(50) NOT NULL,
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Cliente (
    IdCliente INT PRIMARY KEY NOT NULL,
    Documento NVARCHAR(50) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    Direccion NVARCHAR(50),
    Telefono NVARCHAR(50),
    FechaRegistro DATETIME DEFAULT GETDATE()
);

CREATE TABLE Producto (
    IdProducto INT PRIMARY KEY NOT NULL,
    Codigo char(20) NOT NULL,
    Nombre NVARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(50),
    IdCategoria INT FOREIGN KEY REFERENCES Categoria(IdCategoria),
    Laboratorio NVARCHAR(50),
    Presentacion NVARCHAR(50),
    Stock INT DEFAULT 0,
    PrecioCompra DECIMAL(10,2) DEFAULT 0,
    FechaCaducidad DATE,
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Tienda (
    IdTienda INT PRIMARY KEY NOT NULL,
    Documento NVARCHAR(50) NOT NULL,
    Correo NVARCHAR(50),
    Telefono NVARCHAR(50),
    Direccion NVARCHAR(50),
    Ciudad NVARCHAR(50),
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Compra (
    IdCompra INT PRIMARY KEY NOT NULL,
    IdEmpleado INT FOREIGN KEY REFERENCES Empleado(IdEmpleado),
    IdProveedor INT FOREIGN KEY REFERENCES Proveedor(IdProveedor),
    IdTienda INT FOREIGN KEY REFERENCES Tienda(IdTienda),
    MontoTotal DECIMAL(10,2) DEFAULT 0,
    TipoDocumento NVARCHAR(50) DEFAULT 'Boleta',
    NumeroDocumento NVARCHAR(50),
    FechaRegistro DATETIME DEFAULT GETDATE(),
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Detalle_Compra (
    IdDetalleCompra INT PRIMARY KEY NOT NULL,
    IdCompra INT FOREIGN KEY REFERENCES Compra(IdCompra),
    IdProducto INT FOREIGN KEY REFERENCES Producto(IdProducto),
    Cantidad INT,
    PrecioCompra DECIMAL(10,2),
    Total DECIMAL(10,2),
    FechaRegistro DATETIME DEFAULT GETDATE(),
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Venta (
    IdVenta INT PRIMARY KEY NOT NULL,
    IdEmpleado INT FOREIGN KEY REFERENCES Empleado(IdEmpleado),
    IdTienda INT FOREIGN KEY REFERENCES Tienda(IdTienda),
    IdCliente INT FOREIGN KEY REFERENCES Cliente(IdCliente),
    FechaVenta DATE,
    Descuento decimal(10,2),
    TotalVenta DECIMAL(10,2)
);

CREATE TABLE Detalle_Venta (
    IdDetalleVenta INT PRIMARY KEY NOT NULL,
    IdVenta INT FOREIGN KEY REFERENCES Venta(IdVenta),
    IdProducto INT FOREIGN KEY REFERENCES Producto(IdProducto),
    Cantidad INT,
    PrecioVenta DECIMAL(10,2)
);

CREATE TABLE Receta (
    IdReceta INT PRIMARY KEY NOT NULL,
    IdCliente INT FOREIGN KEY REFERENCES Cliente(IdCliente),
    IdVenta INT FOREIGN KEY REFERENCES Venta(IdVenta),
    FechaReceta DATE,
    IdProducto INT FOREIGN KEY REFERENCES Producto(IdProducto),
    Cantidad INT
);



-- Inventario

CREATE TABLE Inventario (
    IdInventario INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    IdCategoria INT FOREIGN KEY REFERENCES Categoria(IdCategoria),
    IdProducto INT FOREIGN KEY REFERENCES Producto(IdProducto),
    Cantidad INT DEFAULT 0,
    LimiteAlmacenamiento INT,
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE(),
);

-- Agregar una restricción para asegurar que la cantidad no supere el límite de almacenamiento
ALTER TABLE Inventario
ADD CONSTRAINT CK_CantidadLimite CHECK (Cantidad >= 0 AND Cantidad <= LimiteAlmacenamiento);




----------------------------Views-------------------------------------
-------------Receta-----------

create View DReceta
as
Select 
R.IdReceta,
R.IdCliente,
R.IdVenta,
R.FechaReceta,
P.Nombre as Producto,
R.Cantidad

from Receta R
inner join Cliente C On C.IdCliente = R.IdCliente
inner join Producto P on P.IdProducto = R.IdProducto
inner join Venta V on V.IdVenta = R.IdVenta


-------------Producto-----------


create View DProducto
as 
select 
P.IdProducto,P.Codigo,P.Nombre,P.Descripcion,
C.Descripcion as Categoria,
P.Laboratorio,
P.Presentacion,P.Stock,P.PrecioCompra,
P.FechaCaducidad,P.Estado,P.FechaCreacion

from Producto P
inner join Categoria C On C.IdCategoria = P.IdCategoria


-------------Empleado-----------


Create View DEmpleado
as
Select 
E.IdEmpleado,E.Documento,E.Nombre,E.Direccion,E.Telefono,
E.Clave,TE.Descripcion as TipoEmpleado,
E.Estado,E.FechaCreacion
from Empleado E
inner join TipoEmpleado TE on  TE.IdTipoEmpleado = E.IdTipoEmpleado


-- Cosas
select * from Producto
select * from Venta
Select * from Detalle_Venta

update Venta set Descuento = 0.15
where IdVenta = 1

