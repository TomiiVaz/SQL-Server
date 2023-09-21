USE DB_Origen
GO
---------------------------------------------------------------------------------------
--FUNCIONES
----------------------------------------------------------------------------------------


-- funcion que devuelve columnas y tipos de datos segun la tabla recibida
CREATE FUNCTION f_ColumnaTipo(@Tabla NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
SELECT COLUMN_NAME AS Columna, DATA_TYPE AS TipoDato , CHARACTER_MAXIMUM_LENGTH AS Longitud
FROM information_schema.columns
WHERE TABLE_NAME like @Tabla
)
GO

-- funcion que devuelce las columnas de una tabla

CREATE FUNCTION f_Columna(@Tabla NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
SELECT COLUMN_NAME AS Columna
FROM information_schema.columns
WHERE TABLE_NAME like @Tabla
)
GO



-- funcion de devuelve los tipos de dato de las columnas de una tabla

CREATE FUNCTION f_Tipo(@Tabla NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
SELECT DATA_TYPE AS TipoDato 
FROM information_schema.columns
WHERE TABLE_NAME like @Tabla
)
GO


-- funcion de devuelve los tipos de dato de las columnas de una tabla

CREATE FUNCTION f_Longitud(@Tabla NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
SELECT CHARACTER_MAXIMUM_LENGTH AS Longitud
FROM information_schema.columns
WHERE TABLE_NAME like @Tabla
)
GO

--funcion que devuelve si un campo tiene un Primary KEY
CREATE FUNCTION f_ChequeaPK(@Tabla NVARCHAR(50), @Columna NVARCHAR(50))
RETURNS int
AS
BEGIN 
	DECLARE @Respuesta int
	DECLARE @dato1 NVARCHAR(200)
	DECLARE @dato2 NVARCHAR(200)
	SELECT @dato1 = COLUMN_NAME FROM information_schema.columns WHERE COLUMN_NAME LIKE @Columna AND TABLE_NAME LIKE @Tabla
	

	SELECT @dato2 = name FROM sys.key_constraints WHERE name LIKE 'PK_' + @dato1

	IF (('PK_' + @dato1) LIKE @dato2)
		BEGIN
			SET @Respuesta = 1
		END
	ELSE
		BEGIN
			SET @Respuesta = 0
		END

	RETURN @Respuesta
END
GO




---------------------------------------------------------------------------------------
--1
----------------------------------------------------------------------------------------


--1 SP_ANALIZATABLAS que chequea que la tabla de la base origen existe en la base destino

CREATE PROC sp_AnalizaTablas
	(
	@Tabla NVARCHAR(100),
	@Coincidencia SMALLINT OUTPUT
	)
AS
	IF EXISTS (SELECT 1 FROM DB_Destino.sys.tables WHERE name LIKE @Tabla)
		BEGIN
			SET @Coincidencia = 1
		END
	ELSE 
		BEGIN
			SET @Coincidencia = 0
		END
GO


--1 SP_CREARTABLAS que crea tabla despues de comparacion de tablas
CREATE PROC sp_CrearTabla
	(
	@Tabla NVARCHAR(100)
	)
AS
		DECLARE @query NVARCHAR(100)
		SET @query = N'USE DB_Destino CREATE TABLE ' + @Tabla + '(FechaChreacion datetime DEFAULT GETDATE())'
		EXEC (@query)
		 
GO


---------------------------------------------------------------------------------------
--2
----------------------------------------------------------------------------------------
--2 sp_AnalizaColumnas chequea las columnas de la DB_ORIGEN con la DB_DESTINO
CREATE PROC sp_AnalizaColumnas
	(
	@Columna NVARCHAR(100),
	@Tabla NVARCHAR(100),
	@Coincidencia SMALLINT OUTPUT
	)
AS
	IF EXISTS (SELECT 1 FROM DB_Destino.information_schema.columns WHERE TABLE_NAME LIKE @Tabla AND COLUMN_NAME LIKE @Columna)
		BEGIN
			SET @Coincidencia = 1
		END
	ELSE 
		BEGIN
			SET @Coincidencia = 0
		END
GO

--2 sp_CrearColumna crea columnas con tipos de datos en la DB_DESTINO
CREATE PROC sp_CrearColumna
	(
	@Columna NVARCHAR(100),
	@Tabla NVARCHAR(100)
	)
AS
	DECLARE @Dato NVARCHAR(max)
	SELECT @Dato = TipoDato FROM f_ColumnaTipo(@Tabla) 

	DECLARE @query NVARCHAR(100)
		SET @query = N'USE DB_Destino ALTER TABLE ' + @Tabla + ' ADD ' + @Columna + SPACE(1) + @Dato
		EXEC (@query)

GO



---------------------------------------------------------------------------------------
--3
----------------------------------------------------------------------------------------

--3 sp que cheque las columnas de las tablas
CREATE PROC sp_ChequearTipoDeDatoDeCadaColumna
	(
	@Tabla NVARCHAR(100),
	@Columna NVARCHAR(100)
	)
AS
	DECLARE @TipoDeDatoOrigen NVARCHAR(max)
	DECLARE @TipoDeDatoDestino NVARCHAR(max)
	SELECT @TipoDeDatoOrigen =  TipoDato FROM f_ColumnaTipo(@Tabla) AS C WHERE  C.Columna = @Columna

	DECLARE @query NVARCHAR(100)
	SET @query = N'USE DB_Destino SELECT '+ @TipoDeDatoDestino + ' = TipoDato FROM f_ColumnaTipo(' + @Tabla + ') WHERE Columna = ' + @Columna 
	EXEC (@query)

	IF(@TipoDeDatoOrigen = @TipoDeDatoDestino)
		BEGIN
			SELECT ''
		END
	ELSE
		BEGIN
			DECLARE @queryModificacion NVARCHAR(max)
			SET @queryModificacion = N'USE DB_Destino ALTER TABLE '+ @Tabla + ' ALTER COLUMN ' + @Columna + SPACE(1) + @TipoDeDatoOrigen + ' NOT NULL'
			EXEC (@queryModificacion)
		END
GO


--3 sp que chequea la longitud de cada columna de las tablas
CREATE PROC sp_ChequearLongitudCol
	(
	@Tabla NVARCHAR(100),
	@Columna NVARCHAR(100)
	)
AS
	DECLARE @TipoDeDatoOrigen NVARCHAR(max)
	
	SELECT @TipoDeDatoOrigen =  TipoDato FROM f_ColumnaTipo(@Tabla) AS C WHERE  C.Columna = @Columna


	DECLARE @LongitudOrigen NVARCHAR(max)
	DECLARE @LongitudDestino NVARCHAR(max)
	SELECT @LongitudOrigen =  Longitud FROM f_ColumnaTipo(@Tabla) AS C WHERE  C.Columna = @Columna

	DECLARE @query NVARCHAR(100)
	SET @query = N'USE DB_Destino SELECT '+ @LongitudDestino + ' = Longitud FROM f_ColumnaTipo(' + @Tabla + ') WHERE Columna = ' + @Columna 
	EXEC (@query)
	
	IF(@LongitudOrigen IS NOT NULL)
		BEGIN
			IF(@LongitudOrigen = @LongitudDestino)
				BEGIN
					SELECT ''
				END
			ELSE
				BEGIN
					DECLARE @queryModificacion NVARCHAR(max)
					SET @queryModificacion = N'USE DB_Destino ALTER TABLE '+ @Tabla + ' ALTER COLUMN ' + @Columna + SPACE(1) + @TipoDeDatoOrigen + '(' +@LongitudOrigen + ')'
					EXEC (@queryModificacion)
				END
		END
GO

-- 3 Sp que chekea las PK
CREATE PROC sp_ChequearPK
	(
	@Tabla NVARCHAR(100),
	@Columna NVARCHAR(100)
	)
AS
	DECLARE @dato int
	EXEC @dato = f_ChequeaPK @Tabla, @Columna
	IF(@dato = 1)
		BEGIN
			DECLARE @queryAddPK NVARCHAR(max)
			SET @queryAddPK = N'USE DB_Destino ALTER TABLE '+ @Tabla + ' ADD CONSTRAINT PK_' + @Columna + ' PRIMARY KEY ('+ @Columna +')'
			EXEC (@queryAddPK)
		END
GO



--3 sp que cheque las columnas de las tablas
CREATE PROC sp_ChequearColumnas
	(
	@Tabla NVARCHAR(100)
	)
AS
		DECLARE @Columna NVARCHAR(100)
		DECLARE cur_Columnas CURSOR FOR SELECT * FROM f_Columna(@Tabla)
		OPEN cur_Columnas
		FETCH NEXT FROM cur_Columnas INTO @Columna
		WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE @Resultado SMALLINT
				EXEC sp_AnalizaColumnas @Columna, @Tabla , @Resultado OUTPUT
				IF (@Resultado = 0)
					BEGIN
						EXEC sp_CrearColumna @Columna, @Tabla
						EXEC sp_ChequearTipoDeDatoDeCadaColumna @Tabla, @Columna
						EXEC sp_ChequearLongitudCol @Tabla, @Columna
						EXEC sp_ChequearPK @Tabla, @Columna
					END
				ELSE 
					BEGIN
						EXEC sp_ChequearTipoDeDatoDeCadaColumna @Tabla, @Columna
						EXEC sp_ChequearLongitudCol @Tabla, @Columna
					END

		FETCH NEXT FROM cur_Columnas INTO @Columna
		END

		CLOSE cur_Columnas
		DEALLOCATE cur_Columnas
		GO
	 
GO

---------------------------------------------------------------------------------------
--CURSOR PADRE
----------------------------------------------------------------------------------------
-- CURSOR PADRE que ejecuta las funciones de arriba mandandole las tablas de una base de datos
BEGIN TRY
	BEGIN TRANSACTION

		DECLARE @tabla NVARCHAR(100)

		DECLARE cur_Origen CURSOR FOR SELECT name FROM sys.tables
		OPEN cur_Origen
		FETCH NEXT FROM cur_Origen INTO @Tabla
		WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE @Resultado SMALLINT
				EXEC sp_AnalizaTablas @Tabla , @Resultado OUTPUT
				IF (@Resultado = 0)
					BEGIN
						EXEC sp_CrearTabla @Tabla
					END

				EXEC sp_ChequearColumnas @Tabla

				FETCH NEXT FROM cur_Origen INTO @Tabla
			END

		CLOSE cur_Origen
		DEALLOCATE cur_Origen

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION 
	PRINT ERROR_MESSAGE();
	THROW 51000, 'ERROR', 1
END CATCH
GO



/*
Integrantes: 

- Espinoza, María Chiara
- Manchini, Juan Manuel
- Mitria, Damian Nahuel
- Santamaría, Florencia Belén
- Vazquez, Tomas
*/















/*
DECLARE @dato3 int
exec @dato3 = f_ChequeaPK 'Persona', 'Nombre'
SELECT @dato3




	DECLARE @dato int
	exec @dato = f_ChequeaPK @Tabla, @Columna
	IF(@dato = 1)
		BEGIN
			DECLARE @queryModificacion2 NVARCHAR(max)
			SET @queryModificacion2 = N'USE DB_Destino ALTER TABLE '+ @Tabla + ' ADD CONSTRAINT PK_' + @Columna + ' PRIMARY KEY (' + @Columna + ')'
			EXEC (@queryModificacion2)
		END



*/


