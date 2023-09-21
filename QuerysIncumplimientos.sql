-- Base de datos para registrar

CREATE DATABASE RegistroBase
GO 

USE RegistroBase

-- tabla para registrar incumplimientos de las normas de codificacion
CREATE TABLE Incumplimiento(
	Id INT IDENTITY(1,1),
	Dato NVARCHAR(50),
	tipo NVARCHAR(50),
	descripcion NVARCHAR(50),
	CONSTRAINT PK_Id PRIMARY KEY (Id)
)
GO


USE DB_Origen
GO

CREATE TABLE Supermercados (id INT)
GO

-- sp que chequea que la tabla empieza con una letra
CREATE PROC sp_VerificaLetraTabla (@NombreTabla NVARCHAR(50))
AS
BEGIN TRANSACTION
IF NOT @NombreTabla LIKE '[A-Z]%'
	BEGIN
		INSERT INTO RegistroBase.dbo.Incumplimiento VALUES(@NombreTabla, 'tabla', 'Debe comenzar con una letra');
		COMMIT TRANSACTION
		
	END
ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END
GO

-- sp que chequea que la tabla no sea plural
CREATE PROC sp_VerificaPluralTabla (@NombreTabla NVARCHAR(50))
AS
BEGIN TRANSACTION
IF @NombreTabla like '%s'
	BEGIN
		INSERT INTO RegistroBase.dbo.Incumplimiento VALUES(@NombreTabla, 'tabla', 'No debe ser plural');
		COMMIT TRANSACTION
	END
ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END
GO

-- pasar una base de datos, recorrer sus tablas para pasar de a una a un sp/funcion
CREATE PROC sp_ChequearBase
AS
DECLARE @Tabla NVARCHAR(100)
DECLARE cur_Base CURSOR FOR SELECT name FROM sys.tables
		OPEN cur_Base
		FETCH NEXT FROM cur_Base INTO @Tabla
		WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC sp_VerificaLetraTabla @Tabla
				EXEC sp_VerificaPluralTabla @Tabla

				FETCH NEXT FROM cur_Base INTO @Tabla
			END

		CLOSE cur_Base
		DEALLOCATE cur_Base
GO

USE RegistroBase
EXEC sp_ChequearBase
GO


-- USE RegistroBase
-- SELECT * FROM Incumplimiento

-- DROP TABLE Incumplimiento

-- DROP DATABASE RegistroBase