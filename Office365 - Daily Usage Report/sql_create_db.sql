USE [master]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [netrptinput]    Script Date: 10/6/2015 7:20:17 AM ******/
CREATE LOGIN [netrptinput] WITH PASSWORD='*YOUR_PASSWORD*', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO

ALTER LOGIN [netrptinput] DISABLE
GO



USE [master]
GO

/****** Object:  Database [NetworkReporting]    Script Date: 10/6/2015 7:17:17 AM ******/
CREATE DATABASE [NetworkReporting] ON  PRIMARY 
( NAME = N'NetworkReporting', FILENAME = N'Y:\MSSQL\Data\NetworkReporting.mdf' , SIZE = 402432KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10240KB )
 LOG ON 
( NAME = N'NetworkReporting_log', FILENAME = N'Z:\MSSQL\Logs\NetworkReporting_log.ldf' , SIZE = 50176KB , MAXSIZE = 2048GB , FILEGROWTH = 10240KB )
GO

ALTER DATABASE [NetworkReporting] SET COMPATIBILITY_LEVEL = 100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [NetworkReporting].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [NetworkReporting] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [NetworkReporting] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [NetworkReporting] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [NetworkReporting] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [NetworkReporting] SET ARITHABORT OFF 
GO

ALTER DATABASE [NetworkReporting] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [NetworkReporting] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [NetworkReporting] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [NetworkReporting] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [NetworkReporting] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [NetworkReporting] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [NetworkReporting] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [NetworkReporting] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [NetworkReporting] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [NetworkReporting] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [NetworkReporting] SET  DISABLE_BROKER 
GO

ALTER DATABASE [NetworkReporting] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [NetworkReporting] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [NetworkReporting] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [NetworkReporting] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [NetworkReporting] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [NetworkReporting] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [NetworkReporting] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [NetworkReporting] SET RECOVERY FULL 
GO

ALTER DATABASE [NetworkReporting] SET  MULTI_USER 
GO

ALTER DATABASE [NetworkReporting] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [NetworkReporting] SET DB_CHAINING OFF 
GO

ALTER DATABASE [NetworkReporting] SET  READ_WRITE 
GO


USE [NetworkReporting]
GO

/****** Object:  User [netrptinput]    Script Date: 10/6/2015 7:18:43 AM ******/
CREATE USER [netrptinput] FOR LOGIN [netrptinput] WITH DEFAULT_SCHEMA=[dbo]
GO




USE [NetworkReporting]
GO

/****** Object:  Table [dbo].[EmailStats]    Script Date: 10/6/2015 7:17:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[EmailStats](
	[Date] [datetime] NOT NULL,
	[Recipient] [varchar](130) NOT NULL,
	[Inbound] [numeric](18, 0) NULL,
	[Outbound] [numeric](18, 0) NULL,
	[InboundSize] [numeric](18, 0) NULL,
	[OutboundSize] [numeric](18, 0) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO




USE [NetworkReporting]
GO

/****** Object:  Table [dbo].[ImportEmailStats]    Script Date: 10/6/2015 7:17:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ImportEmailStats](
	[Date] [datetime] NOT NULL,
	[Recipient] [varchar](130) NOT NULL,
	[Inbound] [numeric](18, 0) NULL,
	[Outbound] [numeric](18, 0) NULL,
	[InboundSize] [numeric](18, 0) NULL,
	[OutboundSize] [numeric](18, 0) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


