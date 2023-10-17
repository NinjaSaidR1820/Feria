Create database DWClinica
go
use DWClinica
go

If OBJECT_ID('dbo.DimEmpleado') Is Not Null
	Begin
		Drop Table dbo.DimEmpleado
	End
go
If OBJECT_ID('dbo.DimCliente') Is Not Null
	Begin
		Drop Table dbo.DimCliente
	End
go
If OBJECT_ID('dbo.DimProducto') Is Not Null
	Begin
		Drop Table dbo.DimProducto
	End
go
If OBJECT_ID('dbo.DimFecha') Is Not Null
	Begin
		Drop Table dbo.DimFecha
	End
go
If OBJECT_ID('dbo.DimTienda') Is Not Null
	Begin
		Drop Table dbo.DimTienda
	End
go
If OBJECT_ID('dbo.FactVenta') Is Not Null
	Begin
		Drop Table dbo.FactVenta
	End
go



CREATE TABLE DimEmpleado (
    IdDimEmpleado int primary key identity(1,1) not null,
    IdEmpleado INT ,
    Documento NVARCHAR(50) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    Direccion NVARCHAR(50),
    Telefono NVARCHAR(50),
    Clave Char(20),
    IdTipoEmpleado Nvarchar(50),
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE(),
	FechaInicio datetime,
	FechaFinal datetime
);

go

CREATE TABLE DimCliente (
    IdDimCliente int primary key identity(1,1) not null,
    IdCliente INT,
    Documento NVARCHAR(50) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    Direccion NVARCHAR(50),
    Telefono NVARCHAR(50),
    FechaRegistro DATETIME DEFAULT GETDATE(),
	FechaInicio datetime,
	FechaFinal datetime
);

go

CREATE TABLE DimProducto (
    IdDimProducto int primary key identity(1,1) not null,
    IdProducto INT,
	Categoria nvarchar(50),
    Codigo char(20) NOT NULL,
    Nombre NVARCHAR(30) NOT NULL,
    Descripcion NVARCHAR(50),
    Laboratorio NVARCHAR(50),
    Presentacion NVARCHAR(50),
    Stock INT DEFAULT 0,
    PrecioCompra DECIMAL(10,2) DEFAULT 0,
    FechaCaducidad DATE,
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaInicio datetime,
	FechaFinal datetime
);

go

-- Dimensión Fecha
create table DimFecha(
IdDimFecha int primary key Identity(1,1),
IdFecha date,
Año int,
NoMes int,
NoDia int,
Trimestre int
);

go

CREATE TABLE DimTienda(
IdDimTienda int identity(1,1) primary key not null,
IdTienda int,
Documento NVARCHAR(50),
Correo NVARCHAR(50),
Telefono NVARCHAR(50),
Direccion NVARCHAR(50),
Ciudad NVARCHAR(50),
Estado bit,
FechaCreacion Datetime,
FechaInicio datetime,
FechaFinal datetime
);
GO


CREATE TABLE DimReceta (
IdDimReceta int identity(1,1) primary key not null,
IdReceta INT,
IdCliente INT,
FechaReceta DATE,
Producto NVARCHAR(50),
Cantidad INT,
FechaInicio datetime,
FechaFinal datetime
);

go

CREATE TABLE DimInventario (
    IdDimInventario INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	IdInventario INT,
    Categoria NVARCHAR(50),
    Producto NVARCHAR(40),
    Cantidad INT,
    LimiteAlmacenamiento INT,
    Estado BIT DEFAULT 1,
	FechaInicio datetime,
	FechaFinal datetime,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE DimProveedor (
    IdDimProveedor INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	IdProveedor INT,
    Proveedor NVARCHAR(50),
    Documento NVARCHAR(50) NOT NULL,
    RazonSocial NVARCHAR(50) NOT NULL,
    Correo NVARCHAR(50),
    Telefono NVARCHAR(50),
    Estado BIT DEFAULT 1,
	FechaInicio datetime,
	FechaFinal datetime,
    FechaCreacion DATETIME DEFAULT GETDATE()
);


--Tabla de Hechos

CREATE TABLE FactVenta (
--Datos 
    IdFactVenta int identity(1,1) primary key not null,
	IdDimTienda INT,
    IdDimCliente INT,
    IdDimEmpleado INT, 
    IdDimProducto INT,
	IdDimFecha INT,
	IdDimReceta INT,
--Calculos 
	CantidadOrdenes INT,
	Recaudacion decimal,
    TotalVenta DECIMAL(10,2)
);

go

-- Tabla de Hechos 2 --

-- Tabla de Hechos para Compras de Productos
CREATE TABLE FactCompra (
    IdFactCompra INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    IdDimEmpleado INT,
    IdDimProveedor INT,
    IdDimTienda INT,
    IdDimFecha INT,
    MontoTotal DECIMAL(10,2),
    TipoDocumento NVARCHAR(50),
    NumeroDocumento NVARCHAR(50),
    FechaRegistro DATETIME,
    Estado BIT DEFAULT 1
);

-- Agregar claves foráneas a las tablas de dimensiones
ALTER TABLE FactCompra
ADD FOREIGN KEY (IdDimEmpleado) REFERENCES DimEmpleado(IdDimEmpleado);

ALTER TABLE FactCompra
ADD FOREIGN KEY (IdDimProveedor) REFERENCES DimProveedor(IdDimProveedor);

ALTER TABLE FactCompra
ADD FOREIGN KEY (IdDimTienda) REFERENCES DimTienda(IdDimTienda);

ALTER TABLE FactCompra
ADD FOREIGN KEY (IdDimFecha) REFERENCES DimFecha(IdDimFecha);




-- References --

ALTER TABLE FactVenta
ADD FOREIGN KEY (IdDimEmpleado) REFERENCES DimEmpleado(IdDimEmpleado);

ALTER TABLE FactVenta
ADD FOREIGN KEY (IdDimCliente) REFERENCES DimCliente(IdDimCliente);

ALTER TABLE FactVenta
ADD FOREIGN KEY (IdDimProducto) REFERENCES DimProducto(IdDimProducto);

ALTER TABLE FactVenta
ADD FOREIGN KEY (IdDimFecha) REFERENCES DimFecha(IdDimFecha);

ALTER TABLE FactVenta
ADD FOREIGN KEY (IdDimTienda) REFERENCES DimTienda(IdDimTienda);

ALTER TABLE FactVenta
ADD FOREIGN KEY (IdDimReceta) REFERENCES DimReceta(IdDimReceta);


-- Add Inventario y Proveedor 

ALTER TABLE FactVenta
ADD IdDimInventario INT;

ALTER TABLE FactVenta
ADD FOREIGN KEY (IdDimInventario) REFERENCES DimInventario(IdDimInventario);


ALTER TABLE FactCompra
ADD IdDimProveedor INT;

ALTER TABLE FactCompra
ADD FOREIGN KEY (IdDimProveedor) REFERENCES DimProveedor(IdDimProveedor);






Merge dbo.FactVenta Destino
Using
(Select 
DE.IdDimEmpleado,
DP.IdDimProducto,
DF.IdDimFecha,
DT.IdDimTienda,
DC.IdDimCliente,

count(V.IdVenta) as CantidadVentas,
round(sum((Dv.Cantidad * Dv.PrecioVenta) - (Dv.Cantidad * Dv.PrecioVenta * V.Descuento)),2) as Recaudacion,
round(sum(((Dv.Cantidad * Dv.PrecioVenta) - (Dv.Cantidad * Dv.PrecioVenta * V.Descuento)) * 1.15),2) as [TotalVenta (IVA)]


from Clinica.dbo.Venta V
inner join Clinica.dbo.Detalle_Venta DV on DV.IdVenta = V.IdVenta

inner join DimFecha df on df.IdFecha = V.FechaVenta
inner join DimEmpleado de on de.IdEmpleado = V.IdEmpleado
inner join DimProducto DP on DP.IdProducto = DV.IdProducto
inner join DimTienda DT on DT.IdTienda = V.IdTienda
inner join DimCliente DC on DC.IdCliente = V.IdCliente



WHERE DE.FechaFinal ='9999/12/31' AND 
	  DP.FechaFinal ='9999/12/31' AND 
      DT.FechaFinal = '9999/12/31'
	 

Group by
df.IdDimFecha,
de.IdDimEmpleado,
dp.IdDimProducto,
DT.IdDimTienda,
DC.IdDimCliente

) Origen
on
Destino.IdDimProducto = Origen.IdDimProducto and
Destino.IdDimEmpleado = Origen.IdDimEmpleado and
Destino.IdDimTienda = Origen.IdDimTienda and
Destino.IdDimFecha = Origen.IdDimFecha and 
Destino.IdDimCliente = Origen.IdDimCliente


WHEN MATCHED AND (Destino.CantidadOrdenes <> Origen.CantidadVentas or                 
				  Destino.Recaudacion <> Origen.Recaudacion or
				  Destino.TotalVenta <> Origen.[TotalVenta (IVA)])
				  Then
				  Update set
				  Destino.CantidadOrdenes = Origen.CantidadVentas,                 
				  Destino.Recaudacion = Origen.Recaudacion,
				  Destino.TotalVenta = Origen.[TotalVenta (IVA)]

WHEN NOT MATCHED THEN 
            INSERT
			(IdDimTienda, IdDimEmpleado, IdDimProducto,IdDimCliente, CantidadOrdenes,
			 IdDimFecha, Recaudacion ,TotalVenta)
			 Values
			 (Origen.IdDimTienda,Origen.IdDimEmpleado,
			  Origen.IdDimProducto, IdDimCliente, Origen.CantidadVentas,
			  Origen.IdDimFecha,Origen.Recaudacion,Origen.[TotalVenta (IVA)]);


go

			 

Delete from DimCliente
Delete from DimEmpleado
Delete from DimFecha
Delete from DimProducto
Delete from DimReceta
Delete From DimTienda
Delete From FactVenta
---------------------------------------------
DBCC CHECKIDENT (DimFecha, RESEED,0)
DBCC CHECKIDENT (DimCliente, RESEED,0)
DBCC CHECKIDENT (DimEmpleado, RESEED,0)
DBCC CHECKIDENT (DimProducto, RESEED,0)
DBCC CHECKIDENT (DimReceta, RESEED,0)
DBCC CHECKIDENT (DimTienda, RESEED,0)
DBCC CHECKIDENT (FactVenta, RESEED,0)
------------------------------------------------------
Select * from DimCliente
Select * from DimEmpleado
Select * from DimFecha 
Select * from DimProducto 
Select * from DimReceta 
Select * from DimTienda 
select * from FactVenta


Create login AdministraProy with password = 'Proy123'
use DWClinica
exec sp_adduser AdministraProy,AdministraProy
exec sp_addrolemember db_datareader, AdministraProy

grant select on DimCliente to AdministraProy
grant select on DimEmpleado to AdministraProy
grant select on DimFecha to AdministraProy
grant select on DimProducto to AdministraProy
grant select on DimReceta to AdministraProy
grant select on DimTienda to AdministraProy
grant select on FactVenta to AdministraProy



backup database DWClinica to disk = 'C:\RespaldosDB\DWClinica.Bak'
 



