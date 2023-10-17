Use Clinica

--///////////////////////////////////////////////////--
-----------------INSERTAR DATOS-----------------------
--//////////////////////////////////////////////////--


CREATE PROCEDURE sp_InsertarTipoEmpleado
	@IdTipoEmpleado int,
	@Descripcion nvarchar(50)
as
begin
	set nocount on;

	insert into TipoEmpleado(IdTipoEmpleado,Descripcion) values (@IdTipoEmpleado,@Descripcion)
end




------------------Empleado---------------------

CREATE PROCEDURE InsertarEmpleado
	@IdEmpleado int,
    @Documento NVARCHAR(50),
    @Nombre NVARCHAR(50),
    @Direccion NVARCHAR(50),
    @Telefono NVARCHAR(50),
    @Clave CHAR(20),
    @IdTipoEmpleado INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Empleado (IdEmpleado,Documento, Nombre, Direccion, Telefono, Clave, IdTipoEmpleado)
    VALUES (@IdEmpleado,@Documento, @Nombre, @Direccion, @Telefono, @Clave, @IdTipoEmpleado);
END;



Select * from Empleado
Select * from TipoEmpleado
Exec InsertarEmpleado '1005E','Gerente','DouglasReyes','Monumento Rafaela Herrera','80809090','Mondongo123',1

-----------------------------------------------
-----------------Proveedor---------------------


CREATE PROCEDURE InsertarProveedor
	@IdProveedor int,
    @Documento NVARCHAR(50),
    @RazonSocial NVARCHAR(50),
    @Correo NVARCHAR(50),
    @Telefono NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Proveedor (IdProveedor,Documento, RazonSocial, Correo, Telefono)
    VALUES (@IdProveedor,@Documento, @RazonSocial, @Correo, @Telefono);
END;

Select * from Proveedor

Exec InsertarProveedor 'P102653','Proveedorn´t','Proveedorn´t Sueros','Proveedorn´t@gmail.com','9338399'

-----------------------------------------------
------------------Cliente----------------------


CREATE PROCEDURE sp_InsetarCliente
	@IdCliente int,
    @Documento NVARCHAR(50),
    @Nombre NVARCHAR(50),
    @Direccion NVARCHAR(50),
    @Telefono NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Cliente(IdCliente,Documento, Direccion, Telefono)
    VALUES (@IdCliente, @Documento, @Nombre, @Direccion, @Telefono);
END;

Select * from Cliente

-------------------------------------------
---------------Categoria-------------------

CREATE PROCEDURE sp_InsertarCategoria
	@IdCategoria int,
	@Descrìpcion nvarchar(50)
as
begin
	SET NOCOUNT ON;

	insert into Categoria (IdCategoria, Descripcion)
	values (@IdCategoria, @Descrìpcion)

end



-----------------------------------------------
-------------------Receta----------------------

Create procedure sp_InsertarReceta
	@IdReceta int,
	@IdCliente int,
	@IdVenta int,
	@FechaReceta date,
	@IdProducto int,
	@Cantidad int
as 
begin
	SET NOCOUNT ON;

	insert into Receta (IdReceta, IdCliente,IdVenta, FechaReceta, IdProducto, Cantidad)
	values (@IdReceta, @IdCliente, @IdVenta, @FechaReceta, @IdProducto, @Cantidad)


-----------------------------------------------
-------------------Compra----------------------


--Nota: Antes de Ejecutar los Procedure Crear esta tabla temporal
CREATE TABLE ##Productos (
    IdProducto INT,
    Cantidad INT,
    PrecioCompra DECIMAL(10, 2)
);


CREATE PROCEDURE RealizarVenta
    @IdEmpleado INT,
    @IdProveedor INT,
    @TipoDocumento NVARCHAR(50),
    @NumeroDocumento NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdCompra INT;
    DECLARE @MontoTotal DECIMAL(10, 2);

    -- Insertar la compra sin incluir el monto total
    INSERT INTO Compra (IdEmpleado, IdProveedor, TipoDocumento, NumeroDocumento)
    VALUES (@IdEmpleado, @IdProveedor, @TipoDocumento, @NumeroDocumento);

    -- Obtener el ID de la compra recién insertada
    SET @IdCompra = SCOPE_IDENTITY();

    -- Insertar el detalle de la compra desde la tabla global temporal de productos
    INSERT INTO Detalle_Compra (IdCompra, IdProducto, Cantidad, PrecioCompra, Total)
    SELECT @IdCompra, IdProducto, Cantidad, PrecioCompra, Cantidad * PrecioCompra
    FROM ##Productos;

    -- Calcular el monto total de la compra
    SELECT @MontoTotal = SUM(Total)
    FROM Detalle_Compra
    WHERE IdCompra = @IdCompra;

    -- Actualizar el monto total de la compra en la tabla Compra
    UPDATE Compra
    SET MontoTotal = @MontoTotal
    WHERE IdCompra = @IdCompra;

	Delete from ##Productos


END;

CREATE PROCEDURE InsertarProductoEnCompra
    @IdProducto INT,
    @Cantidad INT,
    @PrecioCompra DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar el producto en la tabla global temporal de productos
    INSERT INTO ##Productos (IdProducto, Cantidad, PrecioCompra)
    VALUES (@IdProducto, @Cantidad, @PrecioCompra);
END;

-- Insertar productos en la tabla global temporal de productos
EXEC InsertarProductoEnCompra @IdProducto = 5, @Cantidad = 100, @PrecioCompra = 8;
EXEC InsertarProductoEnCompra @IdProducto = 7, @Cantidad = 207, @PrecioCompra = 10;

-- Realizar la venta con los productos
EXEC RealizarVenta @IdEmpleado = 3, @IdProveedor =	1, @TipoDocumento = 'Factura', @NumeroDocumento = 'M0002TW';

select * from Detalle_Compra
Select * from Compra
Select * from ##Productos

Delete from ##Productos

DBCC CHECKIDENT (Compra, RESEED,0)
DBCC CHECKIDENT (Detalle_Compra, RESEED,0)

delete from Detalle_Compra 
delete from Compra
delete from Compra where  IdCompra = 8



select * from Detalle_Compra
Select * from Compra

-----------------------------------------------
-------------------Venta----------------------

--Nota: Antes de Ejecutar los Procedure Crear esta tabla temporal

CREATE TABLE ##ProductosVenta (
    IdProducto INT,
    Cantidad INT,
    PrecioVenta DECIMAL(10, 2)
);

CREATE PROCEDURE RealizarVentaVenta
    @IdEmpleado INT,
    @IdTienda INT,
	@IdCliente INT,
    @FechaVenta DATE,
	@Descuento DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdVenta INT;
    DECLARE @TotalVenta DECIMAL(10, 2);

	

    -- Insertar la venta sin incluir el total de venta
    INSERT INTO Venta (IdEmpleado, IdTienda, IdCliente, FechaVenta, Descuento)
    VALUES (@IdEmpleado, @IdTienda, @IdCliente, @FechaVenta, @Descuento);

    -- Obtener el ID de la venta recién insertada
    SET @IdVenta = SCOPE_IDENTITY();

    -- Insertar el detalle de la venta desde la tabla global temporal de productos de venta
    INSERT INTO Detalle_Venta (IdVenta, IdProducto, Cantidad, PrecioVenta)
    SELECT @IdVenta, IdProducto, Cantidad, PrecioVenta
    FROM ##ProductosVenta;

    -- Calcular el total de venta
    SELECT @TotalVenta = SUM(Cantidad * PrecioVenta)
    FROM Detalle_Venta
    WHERE IdVenta = @IdVenta;

    -- Aplicar el descuento al total de venta
    SET @TotalVenta = @TotalVenta - (@TotalVenta * @Descuento);

    -- Actualizar el total de venta en la tabla Venta
    UPDATE Venta
    SET TotalVenta = @TotalVenta
    WHERE IdVenta = @IdVenta;

	delete from ##ProductosVenta

END;


CREATE PROCEDURE InsertarProductoEnVenta
    @IdProducto INT,
    @Cantidad INT,
    @PrecioVenta DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar el producto en la tabla global temporal de productos de venta
    INSERT INTO ##ProductosVenta (IdProducto, Cantidad, PrecioVenta)
    VALUES (@IdProducto, @Cantidad, @PrecioVenta);
END;




delete from ##ProductosVenta

-- Insertar productos en la tabla global temporal de productos
EXEC InsertarProductoEnVenta @IdProducto = 2, @Cantidad = 30, @PrecioVenta = 12.99;
EXEC InsertarProductoEnVenta @IdProducto = 5, @Cantidad = 40, @PrecioVenta = 100.99;
EXEC InsertarProductoEnVenta @IdProducto = 4, @Cantidad = 14, @PrecioVenta = 15.99;

-- Realizar la venta con los productos
EXEC RealizarVentaVenta @IdEmpleado = 5, @IdTienda = 1, @IdCliente = 5, @FechaVenta = '2021-07-04', @Descuento = 0.15;


select * from Detalle_Venta
Select * from Venta
Select * from ##ProductosVenta


delete from Venta
delete from Detalle_Venta


select * from Detalle_Venta
Select * from Venta
Select * from ##ProductosVenta










select * from Detalle_Venta
select * from Venta

--UwUn't


DBCC CHECKIDENT (Venta, RESEED,0)
DBCC CHECKIDENT (Detalle_Venta, RESEED,0)

delete from Venta where  IdVenta >= 1
delete from Detalle_Venta where  IdDetalleVenta >= 1


Backup database Clinica to disk = 'C:\RespaldosDB\Clinica.bak'

