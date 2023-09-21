
---------------------------------------------------------------------------------------
--CREACION DE BASE DE DATOS Y TABLAS
----------------------------------------------------------------------------------------

CREATE DATABASE DB_Origen 
/*
ON PRIMARY
( NAME = 'DB_Origen',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\DB_Origen.mdf' ,
SIZE = 10000KB ,
MAXSIZE = 20480KB ,
FILEGROWTH = 1024KB
)
 LOG ON
( NAME = 'DB_Origen_log',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\DB_Origen_log.ldf' ,
SIZE = 6000KB ,
MAXSIZE = 10240KB ,
FILEGROWTH = 10%
)
*/
GO

CREATE DATABASE DB_Destino
/*
ON PRIMARY
( NAME = 'DB_Destino',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\DB_Destino.mdf' ,
SIZE = 10000KB ,
MAXSIZE = 20480KB ,
FILEGROWTH = 1024KB
)
 LOG ON
( NAME = 'DB_Destino_log',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\DB_Destino_log.ldf' ,
SIZE = 6000KB ,
MAXSIZE = 10240KB ,
FILEGROWTH = 10%
)
*/
GO

USE DB_Origen
GO

CREATE TABLE Persona (
	PersonaId INT IDENTITY(1,1) NOT NULL,
	Nombre NVARCHAR(50),
	Apellido NVARCHAR(50),
	CONSTRAINT PK_PersonaId PRIMARY KEY (PersonaId)
)
GO

CREATE TABLE Ciudad (
	CiudadId INT IDENTITY(1,1) NOT NULL,
	Nombre NVARCHAR(99),
	CONSTRAINT PK_CiudadId PRIMARY KEY (CiudadId)
)
GO

USE DB_Destino
GO

CREATE TABLE Persona (
	PersonaId INT IDENTITY(1,1) NOT NULL,
	Nombre NVARCHAR(22),
	CONSTRAINT PK_PersonaId PRIMARY KEY (PersonaId)
)
GO

CREATE TABLE Ciudad (
	CiudadId INT IDENTITY(1,1) NOT NULL,
	Nombre VARCHAR(100),
	CodigoPostal INT,
	CONSTRAINT PK_CiudadId PRIMARY KEY (CiudadId)
)
GO



