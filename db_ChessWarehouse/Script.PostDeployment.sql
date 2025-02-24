/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

/*
	ChessWarehouse - Seed Data Script
	Ethan Hunt
	11/26/2023
*/

USE ChessWarehouse
GO

--set the owner
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'database_owner' AND type_desc = 'SQL_LOGIN')
BEGIN
	RAISERROR('The user "database_owner" does not exist', 16, 1)
	RETURN
END

EXEC sp_changedbowner 'database_owner'

--set permissions for other logins
----automation_user
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'automation_user' AND type_desc = 'SQL_LOGIN')
BEGIN
	RAISERROR('The user "automation_user" does not exist', 16, 1)
	RETURN
END

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'automation_user')
BEGIN
	CREATE USER [automation_user] FOR LOGIN [automation_user] WITH DEFAULT_SCHEMA = [dbo]
END

ALTER ROLE [db_datareader] ADD MEMBER [automation_user]
ALTER ROLE [db_datawriter] ADD MEMBER [automation_user]
ALTER ROLE [db_executor] ADD MEMBER [automation_user]
ALTER ROLE [db_ddladmin] ADD MEMBER [automation_user]

----job_owner
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'job_owner' AND type_desc = 'SQL_LOGIN')
BEGIN
	RAISERROR('The user "job_owner" does not exist', 16, 1)
	RETURN
END

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'job_owner')
BEGIN
	CREATE USER [job_owner] FOR LOGIN [job_owner] WITH DEFAULT_SCHEMA = [dbo]
END

ALTER ROLE [db_datareader] ADD MEMBER [job_owner]
ALTER ROLE [db_datawriter] ADD MEMBER [job_owner]
ALTER ROLE [db_executor] ADD MEMBER [job_owner]
ALTER ROLE [db_ddladmin] ADD MEMBER [job_owner]
ALTER ROLE [db_backupoperator] ADD MEMBER [job_owner]

/* Insert seed data */
--Schema: dbo
----Table: FileTypes
SET IDENTITY_INSERT dbo.FileTypes ON

INSERT INTO dbo.FileTypes (FileTypeID, FileType, FileExtension)
SELECT '1', 'Chess Game Analysis', 'game'
WHERE NOT EXISTS (SELECT FileTypeID FROM dbo.FileTypes WHERE FileTypeID = '1')

INSERT INTO dbo.FileTypes (FileTypeID, FileType, FileExtension)
SELECT '2', 'Lichess Evaluations', 'lieval'
WHERE NOT EXISTS (SELECT FileTypeID FROM dbo.FileTypes WHERE FileTypeID = '2')

SET IDENTITY_INSERT dbo.FileTypes OFF


----Table: Settings
SET IDENTITY_INSERT dbo.Settings ON

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 1, 'Forced Move Threshold', '2', 'Difference between T1 and T2 evaluations for move to be considered forced'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 1)

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 2, 'CP Loss Window', '1', 'The maximum CP Loss for a move to be considered a candidate move'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 2)

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 3, 'Max Eval', '3', 'The maximum T1 and move evaluation included in calculations'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 3)

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 4, 'Import Directory', 'C:\FileProcessing\Import', 'General import file location'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 4)

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 5, 'Export Directory', 'C:\FileProcessing\Export', 'General export file location'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 5)

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 6, 'Import File', NULL, 'Name of file to import'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 6)

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 7, 'WinProbabilityLostEqual Source', '3', 'Source used for the WinProbabilityLostEqual calculations'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 7)

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 8, 'WinProbabilityLostEqual Time Control', '5', 'Time Control used for the WinProbabilityLostEqual calculations'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 8)

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 9, 'Default Score', '1', 'The default ScoreID value for fact tables'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 9)

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 10, 'FileProcessing Directory', 'C:\FileProcessing', 'File processing root directory'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 10)

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT 11, 'Z-Score Weights', '0.2|0.35|0.45', 'Weights for T1, ScACPL, and Score (respectively) for composite Z-Scores'
WHERE NOT EXISTS (SELECT ID FROM dbo.Settings WHERE ID = 11)

SET IDENTITY_INSERT dbo.Settings OFF


--Schema: dim
----Table: Aggregations
SET IDENTITY_INSERT dim.Aggregations ON

INSERT INTO dim.Aggregations (AggregationID, AggregationName)
SELECT '1', 'Game'
WHERE NOT EXISTS (SELECT AggregationID FROM dim.Aggregations WHERE AggregationID = '1')

INSERT INTO dim.Aggregations (AggregationID, AggregationName)
SELECT '2', 'Event'
WHERE NOT EXISTS (SELECT AggregationID FROM dim.Aggregations WHERE AggregationID = '2')

INSERT INTO dim.Aggregations (AggregationID, AggregationName)
SELECT '3', 'Evaluation'
WHERE NOT EXISTS (SELECT AggregationID FROM dim.Aggregations WHERE AggregationID = '3')

SET IDENTITY_INSERT dim.Aggregations OFF


----Table: Colors
INSERT INTO dim.Colors (ColorID, Color)
SELECT '0', 'N/A'
WHERE NOT EXISTS (SELECT ColorID FROM dim.Colors WHERE ColorID = '0')

INSERT INTO dim.Colors (ColorID, Color)
SELECT '1', 'White'
WHERE NOT EXISTS (SELECT ColorID FROM dim.Colors WHERE ColorID = '1')

INSERT INTO dim.Colors (ColorID, Color)
SELECT '2', 'Black'
WHERE NOT EXISTS (SELECT ColorID FROM dim.Colors WHERE ColorID = '2')


----Table: CPLossGroups
SET IDENTITY_INSERT dim.CPLossGroups ON

INSERT INTO dim.CPLossGroups (CPLossGroupID, LBound, UBound, CPLoss_Range)
SELECT '1', '0.0', '0.0', '0.00_0.00'
WHERE NOT EXISTS (SELECT CPLossGroupID FROM dim.CPLossGroups WHERE CPLossGroupID = '1')

INSERT INTO dim.CPLossGroups (CPLossGroupID, LBound, UBound, CPLoss_Range)
SELECT '2', '0.01', '0.09', '0.01_0.09'
WHERE NOT EXISTS (SELECT CPLossGroupID FROM dim.CPLossGroups WHERE CPLossGroupID = '2')

INSERT INTO dim.CPLossGroups (CPLossGroupID, LBound, UBound, CPLoss_Range)
SELECT '3', '0.1', '0.24', '0.10_0.24'
WHERE NOT EXISTS (SELECT CPLossGroupID FROM dim.CPLossGroups WHERE CPLossGroupID = '3')

INSERT INTO dim.CPLossGroups (CPLossGroupID, LBound, UBound, CPLoss_Range)
SELECT '4', '0.25', '0.49', '0.25_0.49'
WHERE NOT EXISTS (SELECT CPLossGroupID FROM dim.CPLossGroups WHERE CPLossGroupID = '4')

INSERT INTO dim.CPLossGroups (CPLossGroupID, LBound, UBound, CPLoss_Range)
SELECT '5', '0.5', '0.99', '0.50_0.99'
WHERE NOT EXISTS (SELECT CPLossGroupID FROM dim.CPLossGroups WHERE CPLossGroupID = '5')

INSERT INTO dim.CPLossGroups (CPLossGroupID, LBound, UBound, CPLoss_Range)
SELECT '6', '1.0', '1.99', '1.00_1.99'
WHERE NOT EXISTS (SELECT CPLossGroupID FROM dim.CPLossGroups WHERE CPLossGroupID = '6')

INSERT INTO dim.CPLossGroups (CPLossGroupID, LBound, UBound, CPLoss_Range)
SELECT '7', '2.0', '4.99', '2.00_4.99'
WHERE NOT EXISTS (SELECT CPLossGroupID FROM dim.CPLossGroups WHERE CPLossGroupID = '7')

INSERT INTO dim.CPLossGroups (CPLossGroupID, LBound, UBound, CPLoss_Range)
SELECT '8', '5.0', '500.0', '5.00_500.00'
WHERE NOT EXISTS (SELECT CPLossGroupID FROM dim.CPLossGroups WHERE CPLossGroupID = '8')

SET IDENTITY_INSERT dim.CPLossGroups OFF


----Table: ECO
SET IDENTITY_INSERT dim.ECO ON

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '1', 'A00', 'Misc', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '1')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '2', 'A01', '1. b3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '2')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '3', 'A02', 'Bird', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '3')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '4', 'A03', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '4')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '5', 'A04', 'Reti', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '5')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '6', 'A05', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '6')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '7', 'A06', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '7')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '8', 'A07', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '8')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '9', 'A08', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '9')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '10', 'A09', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '10')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '11', 'A10', 'Misc English', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '11')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '12', 'A11', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '12')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '13', 'A12', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '13')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '14', 'A13', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '14')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '15', 'A14', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '15')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '16', 'A15', '1...Nf6 English', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '16')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '17', 'A16', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '17')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '18', 'A17', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '18')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '19', 'A18', 'Mikenas', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '19')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '20', 'A19', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '20')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '21', 'A20', '1...e5 English', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '21')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '22', 'A21', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '22')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '23', 'A22', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '23')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '24', 'A23', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '24')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '25', 'A24', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '25')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '26', 'A25', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '26')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '27', 'A26', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '27')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '28', 'A27', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '28')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '29', 'A28', 'Reversed Sicilian', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '29')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '30', 'A29', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '30')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '31', 'A30', 'Symmetrical', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '31')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '32', 'A31', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '32')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '33', 'A32', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '33')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '34', 'A33', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '34')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '35', 'A34', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '35')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '36', 'A35', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '36')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '37', 'A36', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '37')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '38', 'A37', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '38')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '39', 'A38', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '39')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '40', 'A39', 'Pure Symmetrical', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '40')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '41', 'A40', 'Misc 1. d4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '41')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '42', 'A41', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '42')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '43', 'A42', 'Modern, Aver', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '43')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '44', 'A43', 'Old Benoni', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '44')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '45', 'A44', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '45')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '46', 'A45', 'Misc 1...Nf6', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '46')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '47', 'A46', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '47')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '48', 'A47', 'Misc QID', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '48')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '49', 'A48', 'Misc KID', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '49')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '50', 'A49', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '50')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '51', 'A50', 'Misc 2. c4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '51')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '52', 'A51', 'Budapest', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '52')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '53', 'A52', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '53')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '54', 'A53', 'Old Indian', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '54')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '55', 'A54', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '55')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '56', 'A55', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '56')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '57', 'A56', 'Misc Benoni', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '57')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '58', 'A57', 'Benko', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '58')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '59', 'A58', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '59')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '60', 'A59', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '60')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '61', 'A60', 'Misc Benoni', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '61')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '62', 'A61', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '62')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '63', 'A62', 'Fianchetto', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '63')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '64', 'A63', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '64')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '65', 'A64', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '65')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '66', 'A65', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '66')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '67', 'A66', 'Taimanov', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '67')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '68', 'A67', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '68')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '69', 'A68', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '69')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '70', 'A69', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '70')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '71', 'A70', 'Classical', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '71')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '72', 'A71', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '72')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '73', 'A72', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '73')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '74', 'A73', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '74')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '75', 'A74', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '75')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '76', 'A75', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '76')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '77', 'A76', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '77')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '78', 'A77', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '78')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '79', 'A78', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '79')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '80', 'A79', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '80')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '81', 'A80', 'Misc Dutch', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '81')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '82', 'A81', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '82')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '83', 'A82', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '83')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '84', 'A83', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '84')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '85', 'A84', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '85')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '86', 'A85', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '86')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '87', 'A86', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '87')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '88', 'A87', 'Leningrad', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '88')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '89', 'A88', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '89')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '90', 'A89', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '90')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '91', 'A90', 'Classical', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '91')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '92', 'A91', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '92')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '93', 'A92', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '93')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '94', 'A93', 'Stonewall', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '94')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '95', 'A94', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '95')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '96', 'A95', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '96')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '97', 'A96', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '97')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '98', 'A97', 'Ilyin-Genevsky', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '98')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '99', 'A98', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '99')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '100', 'A99', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '100')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '101', 'B00', 'Misc 1. e4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '101')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '102', 'B01', 'Scandi', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '102')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '103', 'B02', 'Alekhine', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '103')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '104', 'B03', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '104')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '105', 'B04', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '105')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '106', 'B05', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '106')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '107', 'B06', 'Modern', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '107')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '108', 'B07', 'Pirc', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '108')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '109', 'B08', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '109')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '110', 'B09', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '110')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '111', 'B10', 'Caro-Kann', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '111')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '112', 'B11', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '112')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '113', 'B12', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '113')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '114', 'B13', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '114')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '115', 'B14', 'Panov', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '115')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '116', 'B15', '3. Nc3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '116')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '117', 'B16', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '117')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '118', 'B17', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '118')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '119', 'B18', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '119')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '120', 'B19', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '120')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '121', 'B20', 'Misc Sicilian', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '121')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '122', 'B21', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '122')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '123', 'B22', 'Alapin', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '123')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '124', 'B23', 'Closed', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '124')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '125', 'B24', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '125')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '126', 'B25', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '126')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '127', 'B26', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '127')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '128', 'B27', 'Misc. 2. Nf3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '128')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '129', 'B28', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '129')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '130', 'B29', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '130')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '131', 'B30', 'Misc 2...Nc6', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '131')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '132', 'B31', 'Rossolimo', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '132')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '133', 'B32', 'Misc. 3. d4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '133')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '134', 'B33', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '134')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '135', 'B34', 'Accel. Dragon', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '135')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '136', 'B35', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '136')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '137', 'B36', 'Maroczy Bind', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '137')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '138', 'B37', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '138')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '139', 'B38', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '139')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '140', 'B39', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '140')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '141', 'B40', 'Misc. 2...e6', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '141')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '142', 'B41', 'Kan', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '142')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '143', 'B42', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '143')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '144', 'B43', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '144')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '145', 'B44', 'Taimanov', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '145')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '146', 'B45', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '146')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '147', 'B46', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '147')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '148', 'B47', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '148')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '149', 'B48', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '149')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '150', 'B49', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '150')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '151', 'B50', 'Misc 2...d6', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '151')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '152', 'B51', 'Moscow', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '152')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '153', 'B52', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '153')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '154', 'B53', '4. Qxd4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '154')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '155', 'B54', 'Misc. 4. Nxd4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '155')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '156', 'B55', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '156')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '157', 'B56', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '157')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '158', 'B57', 'Sozin', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '158')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '159', 'B58', 'Classical', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '159')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '160', 'B59', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '160')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '161', 'B60', 'Richter-Rauzer', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '161')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '162', 'B61', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '162')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '163', 'B62', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '163')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '164', 'B63', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '164')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '165', 'B64', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '165')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '166', 'B65', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '166')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '167', 'B66', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '167')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '168', 'B67', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '168')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '169', 'B68', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '169')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '170', 'B69', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '170')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '171', 'B70', 'Dragon', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '171')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '172', 'B71', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '172')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '173', 'B72', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '173')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '174', 'B73', 'Classical', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '174')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '175', 'B74', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '175')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '176', 'B75', 'Yugoslav', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '176')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '177', 'B76', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '177')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '178', 'B77', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '178')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '179', 'B78', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '179')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '180', 'B79', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '180')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '181', 'B80', 'Scheveningan', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '181')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '182', 'B81', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '182')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '183', 'B82', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '183')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '184', 'B83', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '184')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '185', 'B84', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '185')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '186', 'B85', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '186')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '187', 'B86', 'Sozin Attack', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '187')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '188', 'B87', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '188')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '189', 'B88', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '189')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '190', 'B89', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '190')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '191', 'B90', 'Najdorf', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '191')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '192', 'B91', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '192')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '193', 'B92', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '193')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '194', 'B93', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '194')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '195', 'B94', '6. Bg5', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '195')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '196', 'B95', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '196')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '197', 'B96', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '197')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '198', 'B97', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '198')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '199', 'B98', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '199')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '200', 'B99', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '200')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '201', 'C00', 'Misc French', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '201')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '202', 'C01', 'Exchange', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '202')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '203', 'C02', 'Advance', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '203')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '204', 'C03', 'Tarrasch', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '204')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '205', 'C04', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '205')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '206', 'C05', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '206')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '207', 'C06', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '207')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '208', 'C07', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '208')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '209', 'C08', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '209')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '210', 'C09', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '210')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '211', 'C10', 'Misc. 3. Nc3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '211')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '212', 'C11', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '212')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '213', 'C12', 'MacCutcheon', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '213')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '214', 'C13', 'Classical', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '214')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '215', 'C14', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '215')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '216', 'C15', 'Winawer', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '216')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '217', 'C16', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '217')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '218', 'C17', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '218')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '219', 'C18', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '219')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '220', 'C19', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '220')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '221', 'C20', 'Misc 1...e5', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '221')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '222', 'C21', 'Centre Game', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '222')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '223', 'C22', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '223')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '224', 'C23', 'Bishop�s', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '224')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '225', 'C24', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '225')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '226', 'C25', 'Vienna', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '226')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '227', 'C26', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '227')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '228', 'C27', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '228')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '229', 'C28', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '229')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '230', 'C29', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '230')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '231', 'C30', 'King�s Gambit', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '231')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '232', 'C31', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '232')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '233', 'C32', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '233')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '234', 'C33', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '234')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '235', 'C34', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '235')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '236', 'C35', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '236')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '237', 'C36', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '237')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '238', 'C37', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '238')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '239', 'C38', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '239')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '240', 'C39', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '240')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '241', 'C40', 'Misc 2. Nf3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '241')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '242', 'C41', 'Philidor', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '242')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '243', 'C42', 'Petrov', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '243')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '244', 'C43', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '244')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '245', 'C44', 'Misc 2..Nc6', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '245')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '246', 'C45', 'Scotch', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '246')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '247', 'C46', 'Three Knights', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '247')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '248', 'C47', 'Scotch Four knights', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '248')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '249', 'C48', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '249')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '250', 'C49', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '250')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '251', 'C50', 'Misc 3. Bc4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '251')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '252', 'C51', 'Evan�s Gambit', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '252')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '253', 'C52', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '253')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '254', 'C53', 'Giuoco Piano', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '254')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '255', 'C54', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '255')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '256', 'C55', 'Two knights', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '256')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '257', 'C56', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '257')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '258', 'C57', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '258')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '259', 'C58', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '259')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '260', 'C59', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '260')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '261', 'C60', 'Misc Ruy Lopez', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '261')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '262', 'C61', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '262')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '263', 'C62', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '263')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '264', 'C63', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '264')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '265', 'C64', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '265')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '266', 'C65', 'Berlin', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '266')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '267', 'C66', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '267')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '268', 'C67', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '268')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '269', 'C68', 'Exchange', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '269')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '270', 'C69', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '270')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '271', 'C70', '4. Ba4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '271')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '272', 'C71', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '272')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '273', 'C72', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '273')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '274', 'C73', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '274')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '275', 'C74', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '275')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '276', 'C75', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '276')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '277', 'C76', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '277')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '278', 'C77', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '278')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '279', 'C78', '5. 0-0', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '279')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '280', 'C79', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '280')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '281', 'C80', 'Open', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '281')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '282', 'C81', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '282')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '283', 'C82', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '283')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '284', 'C83', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '284')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '285', 'C84', 'Misc. Closed', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '285')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '286', 'C85', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '286')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '287', 'C86', 'Worrall', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '287')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '288', 'C87', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '288')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '289', 'C88', 'Anti-Marshall', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '289')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '290', 'C89', 'Marshall', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '290')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '291', 'C90', 'Misc. 8...d6', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '291')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '292', 'C91', '9. d4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '292')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '293', 'C92', 'Zaitsev', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '293')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '294', 'C93', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '294')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '295', 'C94', 'Breyer', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '295')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '296', 'C95', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '296')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '297', 'C96', 'Chigorin', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '297')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '298', 'C97', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '298')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '299', 'C98', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '299')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '300', 'C99', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '300')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '301', 'D00', 'Misc. 1...d5', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '301')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '302', 'D01', 'Veresov', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '302')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '303', 'D02', 'Misc. 2. Nf3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '303')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '304', 'D03', 'Torre', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '304')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '305', 'D04', 'Colle', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '305')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '306', 'D05', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '306')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '307', 'D06', 'Misc 2. c4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '307')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '308', 'D07', 'Chigorin', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '308')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '309', 'D08', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '309')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '310', 'D09', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '310')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '311', 'D10', 'Slav', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '311')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '312', 'D11', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '312')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '313', 'D12', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '313')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '314', 'D13', 'Exchange', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '314')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '315', 'D14', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '315')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '316', 'D15', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '316')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '317', 'D16', 'Misc 4...dxc4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '317')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '318', 'D17', '4...dxc4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '318')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '319', 'D18', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '319')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '320', 'D19', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '320')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '321', 'D20', 'QGA', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '321')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '322', 'D21', 'Misc 3. Nf3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '322')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '323', 'D22', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '323')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '324', 'D23', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '324')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '325', 'D24', '4. Nc3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '325')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '326', 'D25', 'Main line', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '326')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '327', 'D26', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '327')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '328', 'D27', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '328')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '329', 'D28', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '329')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '330', 'D29', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '330')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '331', 'D30', 'Misc QGD', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '331')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '332', 'D31', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '332')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '333', 'D32', 'Tarrasch', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '333')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '334', 'D33', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '334')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '335', 'D34', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '335')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '336', 'D35', 'Misc 3...Nf6', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '336')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '337', 'D36', 'Exchange', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '337')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '338', 'D37', '4. Nf3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '338')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '339', 'D38', 'Ragozin', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '339')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '340', 'D39', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '340')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '341', 'D40', 'Semi-Tarrasch', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '341')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '342', 'D41', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '342')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '343', 'D42', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '343')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '344', 'D43', 'Semi-Slav', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '344')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '345', 'D44', 'Botvinnik', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '345')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '346', 'D45', 'Anti-Meran', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '346')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '347', 'D46', 'Meran', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '347')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '348', 'D47', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '348')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '349', 'D48', '8...a6', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '349')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '350', 'D49', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '350')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '351', 'D50', 'QGD', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '351')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '352', 'D51', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '352')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '353', 'D52', 'Cambridge-Springs', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '353')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '354', 'D53', '4...Be7', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '354')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '355', 'D54', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '355')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '356', 'D55', '6. Nf3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '356')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '357', 'D56', 'Lasker', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '357')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '358', 'D57', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '358')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '359', 'D58', 'Tartakower', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '359')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '360', 'D59', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '360')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '361', 'D60', 'Orthodox', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '361')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '362', 'D61', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '362')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '363', 'D62', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '363')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '364', 'D63', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '364')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '365', 'D64', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '365')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '366', 'D65', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '366')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '367', 'D66', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '367')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '368', 'D67', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '368')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '369', 'D68', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '369')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '370', 'D69', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '370')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '371', 'D70', 'Anti Grunfeld', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '371')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '372', 'D71', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '372')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '373', 'D72', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '373')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '374', 'D73', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '374')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '375', 'D74', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '375')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '376', 'D75', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '376')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '377', 'D76', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '377')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '378', 'D77', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '378')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '379', 'D78', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '379')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '380', 'D79', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '380')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '381', 'D80', 'Grunfeld', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '381')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '382', 'D81', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '382')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '383', 'D82', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '383')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '384', 'D83', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '384')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '385', 'D84', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '385')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '386', 'D85', 'Exchange', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '386')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '387', 'D86', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '387')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '388', 'D87', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '388')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '389', 'D88', '7. Bc4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '389')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '390', 'D89', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '390')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '391', 'D90', '4. Nf3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '391')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '392', 'D91', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '392')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '393', 'D92', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '393')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '394', 'D93', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '394')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '395', 'D94', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '395')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '396', 'D95', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '396')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '397', 'D96', 'Russian', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '397')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '398', 'D97', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '398')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '399', 'D98', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '399')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '400', 'D99', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '400')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '401', 'E00', 'Misc. 2...e6', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '401')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '402', 'E01', 'Catalan', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '402')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '403', 'E02', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '403')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '404', 'E03', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '404')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '405', 'E04', 'Open', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '405')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '406', 'E05', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '406')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '407', 'E06', 'Closed', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '407')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '408', 'E07', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '408')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '409', 'E08', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '409')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '410', 'E09', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '410')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '411', 'E10', 'Misc. 3. Nf3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '411')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '412', 'E11', 'Bogo-Indian', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '412')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '413', 'E12', 'QID', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '413')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '414', 'E13', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '414')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '415', 'E14', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '415')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '416', 'E15', '4. g3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '416')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '417', 'E16', '5...Bb4+', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '417')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '418', 'E17', '5...Be7', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '418')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '419', 'E18', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '419')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '420', 'E19', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '420')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '421', 'E20', 'Nimzo-Indian', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '421')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '422', 'E21', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '422')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '423', 'E22', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '423')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '424', 'E23', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '424')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '425', 'E24', 'Saemisch', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '425')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '426', 'E25', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '426')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '427', 'E26', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '427')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '428', 'E27', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '428')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '429', 'E28', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '429')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '430', 'E29', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '430')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '431', 'E30', '4. Bg5', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '431')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '432', 'E31', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '432')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '433', 'E32', 'Classical', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '433')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '434', 'E33', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '434')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '435', 'E34', '4...d5', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '435')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '436', 'E35', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '436')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '437', 'E36', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '437')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '438', 'E37', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '438')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '439', 'E38', '4...c5', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '439')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '440', 'E39', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '440')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '441', 'E40', 'Rubinstein', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '441')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '442', 'E41', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '442')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '443', 'E42', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '443')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '444', 'E43', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '444')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '445', 'E44', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '445')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '446', 'E45', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '446')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '447', 'E46', '4...0-0', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '447')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '448', 'E47', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '448')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '449', 'E48', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '449')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '450', 'E49', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '450')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '451', 'E50', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '451')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '452', 'E51', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '452')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '453', 'E52', 'Main line', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '453')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '454', 'E53', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '454')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '455', 'E54', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '455')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '456', 'E55', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '456')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '457', 'E56', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '457')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '458', 'E57', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '458')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '459', 'E58', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '459')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '460', 'E59', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '460')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '461', 'E60', 'KID', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '461')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '462', 'E61', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '462')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '463', 'E62', 'Fianchetto', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '463')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '464', 'E63', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '464')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '465', 'E64', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '465')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '466', 'E65', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '466')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '467', 'E66', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '467')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '468', 'E67', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '468')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '469', 'E68', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '469')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '470', 'E69', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '470')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '471', 'E70', '4. e4', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '471')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '472', 'E71', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '472')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '473', 'E72', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '473')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '474', 'E73', '5. Be2', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '474')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '475', 'E74', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '475')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '476', 'E75', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '476')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '477', 'E76', 'Four Pawns', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '477')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '478', 'E77', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '478')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '479', 'E78', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '479')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '480', 'E79', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '480')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '481', 'E80', 'Saemisch', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '481')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '482', 'E81', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '482')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '483', 'E82', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '483')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '484', 'E83', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '484')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '485', 'E84', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '485')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '486', 'E85', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '486')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '487', 'E86', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '487')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '488', 'E87', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '488')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '489', 'E88', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '489')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '490', 'E89', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '490')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '491', 'E90', '5. Nf3', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '491')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '492', 'E91', '6. Be2', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '492')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '493', 'E92', '6...e5', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '493')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '494', 'E93', 'Petrosian', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '494')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '495', 'E94', '7. 0-0', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '495')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '496', 'E95', '7...Nbd7', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '496')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '497', 'E96', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '497')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '498', 'E97', 'Mar del Plata', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '498')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '499', 'E98', '9. Ne1', NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '499')

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT '500', 'E99', NULL, NULL
WHERE NOT EXISTS (SELECT ECOID FROM dim.ECO WHERE ECOID = '500')

SET IDENTITY_INSERT dim.ECO OFF


----Table: EvaluationGroups
INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '0', NULL, NULL, 'N/A'
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '0')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '1', '-500.0', '-3.0', '-+'
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '1')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '2', '-2.99', '-1.5', '-/+ / -+'
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '2')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '3', '-1.49', '-0.75', '=+ / -/+'
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '3')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '4', '-0.74', '-0.25', '= / =+'
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '4')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '5', '-0.24', '-0.01', '='
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '5')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '6', '0.0', '0.0', '='
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '6')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '7', '0.01', '0.24', '='
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '7')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '8', '0.25', '0.74', '= / +='
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '8')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '9', '0.75', '1.49', '+= / +/-'
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '9')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '10', '1.5', '2.99', '+/- / +-'
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '10')

INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT '11', '3.0', '500.0', '+-'
WHERE NOT EXISTS (SELECT EvaluationGroupID FROM dim.EvaluationGroups WHERE EvaluationGroupID = '11')


----Table: Measurements
SET IDENTITY_INSERT dim.Measurements ON

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '1', 'T1', '1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '1')

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '2', 'T2', '1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '2')

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '3', 'T3', '1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '3')

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '4', 'T4', '1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '4')

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '5', 'T5', '1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '5')

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '6', 'ACPL', '-1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '6')

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '7', 'SDCPL', '-1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '7')

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '8', 'WinProbabilityLost', '1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '8')

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '9', 'ScACPL', '-1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '9')

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '10', 'ScSDCPL', '-1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '10')

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT '11', 'EvaluationGroupComparison', '1'
WHERE NOT EXISTS (SELECT MeasurementID FROM dim.Measurements WHERE MeasurementID = '11')

SET IDENTITY_INSERT dim.Measurements OFF


----Table: Phases
SET IDENTITY_INSERT dim.Phases ON

INSERT INTO dim.Phases (PhaseID, Phase)
SELECT '1', 'Opening'
WHERE NOT EXISTS (SELECT PhaseID FROM dim.Phases WHERE PhaseID = '1')

INSERT INTO dim.Phases (PhaseID, Phase)
SELECT '2', 'Middlegame'
WHERE NOT EXISTS (SELECT PhaseID FROM dim.Phases WHERE PhaseID = '2')

INSERT INTO dim.Phases (PhaseID, Phase)
SELECT '3', 'Endgame'
WHERE NOT EXISTS (SELECT PhaseID FROM dim.Phases WHERE PhaseID = '3')

SET IDENTITY_INSERT dim.Phases OFF


----Table: Ratings
INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '0', '99'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '0')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '100', '199'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '100')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '200', '299'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '200')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '300', '399'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '300')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '400', '499'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '400')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '500', '599'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '500')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '600', '699'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '600')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '700', '799'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '700')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '800', '899'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '800')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '900', '999'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '900')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '1000', '1099'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '1000')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '1100', '1199'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '1100')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '1200', '1299'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '1200')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '1300', '1399'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '1300')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '1400', '1499'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '1400')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '1500', '1599'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '1500')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '1600', '1699'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '1600')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '1700', '1799'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '1700')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '1800', '1899'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '1800')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '1900', '1999'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '1900')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '2000', '2099'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '2000')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '2100', '2199'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '2100')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '2200', '2299'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '2200')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '2300', '2399'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '2300')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '2400', '2499'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '2400')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '2500', '2599'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '2500')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '2600', '2699'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '2600')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '2700', '2799'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '2700')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '2800', '2899'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '2800')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '2900', '2999'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '2900')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '3000', '3099'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '3000')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '3100', '3199'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '3100')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '3200', '3299'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '3200')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '3300', '3399'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '3300')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '3400', '3499'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '3400')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '3500', '3599'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '3500')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '3600', '3699'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '3600')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '3700', '3799'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '3700')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '3800', '3899'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '3800')

INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT '3900', '3999'
WHERE NOT EXISTS (SELECT RatingID FROM dim.Ratings WHERE RatingID = '3900')


----Table: Scores
SET IDENTITY_INSERT dim.Scores ON

INSERT INTO dim.Scores (ScoreID, ScoreName, ScoreDesc, ScoreActive)
SELECT '0', 'TestScore', 'This score is used for testing purposes', '0'
WHERE NOT EXISTS (SELECT ScoreID FROM dim.Scores WHERE ScoreID = '0')

INSERT INTO dim.Scores (ScoreID, ScoreName, ScoreDesc, ScoreActive)
SELECT '1', 'WinProbabilityLost', 'A measurement of the change in win probability based on the evaluation and individual game source/time control', '1'
WHERE NOT EXISTS (SELECT ScoreID FROM dim.Scores WHERE ScoreID = '1')

INSERT INTO dim.Scores (ScoreID, ScoreName, ScoreDesc, ScoreActive)
SELECT '2', 'WinProbabilityLostEqual', 'A measurement of the change in win probability based on the evaluation and a predefined game source/time control', '1'
WHERE NOT EXISTS (SELECT ScoreID FROM dim.Scores WHERE ScoreID = '2')

INSERT INTO dim.Scores (ScoreID, ScoreName, ScoreDesc, ScoreActive)
SELECT '3', 'EvaluationGroupComparison', 'A measurement of the historical difficulty in playing similar positions based on the T5 evaluations and individual game source/time control/ratings', '1'
WHERE NOT EXISTS (SELECT ScoreID FROM dim.Scores WHERE ScoreID = '3')

SET IDENTITY_INSERT dim.Scores OFF


----Table: Sites
SET IDENTITY_INSERT dim.Sites ON

INSERT INTO dim.Sites (SiteID, SiteName)
SELECT '1', 'ChessManiac'
WHERE NOT EXISTS (SELECT SiteID FROM dim.Sites WHERE SiteID = '1')

INSERT INTO dim.Sites (SiteID, SiteName)
SELECT '2', 'FICS'
WHERE NOT EXISTS (SELECT SiteID FROM dim.Sites WHERE SiteID = '2')

INSERT INTO dim.Sites (SiteID, SiteName)
SELECT '3', 'Chess.com'
WHERE NOT EXISTS (SELECT SiteID FROM dim.Sites WHERE SiteID = '3')

INSERT INTO dim.Sites (SiteID, SiteName)
SELECT '4', 'Lichess'
WHERE NOT EXISTS (SELECT SiteID FROM dim.Sites WHERE SiteID = '4')

SET IDENTITY_INSERT dim.Sites OFF


----Table: Sources
SET IDENTITY_INSERT dim.Sources ON

INSERT INTO dim.Sources (SourceID, SourceName, PersonalFlag)
SELECT '1', 'Personal', 1
WHERE NOT EXISTS (SELECT SourceID FROM dim.Sources WHERE SourceID = '1')

INSERT INTO dim.Sources (SourceID, SourceName, PersonalFlag)
SELECT '2', 'PersonalOnline', 1
WHERE NOT EXISTS (SELECT SourceID FROM dim.Sources WHERE SourceID = '2')

INSERT INTO dim.Sources (SourceID, SourceName, PersonalFlag)
SELECT '3', 'Control', 0
WHERE NOT EXISTS (SELECT SourceID FROM dim.Sources WHERE SourceID = '3')

INSERT INTO dim.Sources (SourceID, SourceName, PersonalFlag)
SELECT '4', 'Lichess', 0
WHERE NOT EXISTS (SELECT SourceID FROM dim.Sources WHERE SourceID = '4')

SET IDENTITY_INSERT dim.Sources OFF


----Table: TimeControls
SET IDENTITY_INSERT dim.TimeControls ON

INSERT INTO dim.TimeControls (TimeControlID, TimeControlName, MinSeconds, MaxSeconds)
SELECT '1', 'UltraBullet', '0', '59'
WHERE NOT EXISTS (SELECT TimeControlID FROM dim.TimeControls WHERE TimeControlID = '1')

INSERT INTO dim.TimeControls (TimeControlID, TimeControlName, MinSeconds, MaxSeconds)
SELECT '2', 'Bullet', '60', '179'
WHERE NOT EXISTS (SELECT TimeControlID FROM dim.TimeControls WHERE TimeControlID = '2')

INSERT INTO dim.TimeControls (TimeControlID, TimeControlName, MinSeconds, MaxSeconds)
SELECT '3', 'Blitz', '180', '600'
WHERE NOT EXISTS (SELECT TimeControlID FROM dim.TimeControls WHERE TimeControlID = '3')

INSERT INTO dim.TimeControls (TimeControlID, TimeControlName, MinSeconds, MaxSeconds)
SELECT '4', 'Rapid', '601', '2699'
WHERE NOT EXISTS (SELECT TimeControlID FROM dim.TimeControls WHERE TimeControlID = '4')

INSERT INTO dim.TimeControls (TimeControlID, TimeControlName, MinSeconds, MaxSeconds)
SELECT '5', 'Classical', '2700', '86399'
WHERE NOT EXISTS (SELECT TimeControlID FROM dim.TimeControls WHERE TimeControlID = '5')

INSERT INTO dim.TimeControls (TimeControlID, TimeControlName, MinSeconds, MaxSeconds)
SELECT '6', 'Correspondence', '86400', '1209600'
WHERE NOT EXISTS (SELECT TimeControlID FROM dim.TimeControls WHERE TimeControlID = '6')

SET IDENTITY_INSERT dim.TimeControls OFF


----Table: Traces
INSERT INTO dim.Traces (TraceKey, TraceDescription, Scored)
SELECT '0', 'Inferior Move', 'True'
WHERE NOT EXISTS (SELECT TraceKey FROM dim.Traces WHERE TraceKey = '0')

INSERT INTO dim.Traces (TraceKey, TraceDescription, Scored)
SELECT 'b', 'Book Move', 'False'
WHERE NOT EXISTS (SELECT TraceKey FROM dim.Traces WHERE TraceKey = 'b')

INSERT INTO dim.Traces (TraceKey, TraceDescription, Scored)
SELECT 'e', 'Eliminated Move', 'False'
WHERE NOT EXISTS (SELECT TraceKey FROM dim.Traces WHERE TraceKey = 'e')

INSERT INTO dim.Traces (TraceKey, TraceDescription, Scored)
SELECT 'f', 'Forced Move', 'False'
WHERE NOT EXISTS (SELECT TraceKey FROM dim.Traces WHERE TraceKey = 'f')

INSERT INTO dim.Traces (TraceKey, TraceDescription, Scored)
SELECT 'M', 'Equal Value Match Move', 'True'
WHERE NOT EXISTS (SELECT TraceKey FROM dim.Traces WHERE TraceKey = 'M')

INSERT INTO dim.Traces (TraceKey, TraceDescription, Scored)
SELECT 'r', 'Repeated Move', 'False'
WHERE NOT EXISTS (SELECT TraceKey FROM dim.Traces WHERE TraceKey = 'r')

INSERT INTO dim.Traces (TraceKey, TraceDescription, Scored)
SELECT 't', 'Tablebase Move', 'False'
WHERE NOT EXISTS (SELECT TraceKey FROM dim.Traces WHERE TraceKey = 't')


--Schema: doc
----Table: Records
INSERT INTO doc.Records (RecordKey, RecordName)
SELECT 'G', 'Games'
WHERE NOT EXISTS (SELECT RecordKey FROM doc.Records WHERE RecordKey = 'G')

INSERT INTO doc.Records (RecordKey, RecordName)
SELECT 'M', 'Moves'
WHERE NOT EXISTS (SELECT RecordKey FROM doc.Records WHERE RecordKey = 'M')


----Table: RecordLayouts -> dependent on doc.Records
INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '1', 'Record ID'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '1')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '2', 'Source Name'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '2')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '3', 'Site Name'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '3')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '4', 'Game ID'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '4')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '5', 'White Last Name'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '5')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '6', 'White First Name'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '6')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '7', 'Black Last Name'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '7')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '8', 'Black First Name'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '8')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '9', 'White Elo Rating'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '9')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '10', 'Black Elo Rating'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '10')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '11', 'Time Control'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '11')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '12', 'ECO Code'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '12')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '13', 'Game Date'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '13')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '14', 'Game Time'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '14')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '15', 'Event Name'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '15')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '16', 'Round Number'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '16')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '17', 'Result'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '17')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'G', '18', 'Event Rated'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'G' AND FieldPosition = '18')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '1', 'Record Key'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '1')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '2', 'Game ID'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '2')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '3', 'Move Number'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '3')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '4', 'Color'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '4')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '5', 'Is Theory'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '5')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '6', 'Is Tablebase'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '6')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '7', 'Engine'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '7')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '8', 'Depth'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '8')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '9', 'Clock'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '9')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '10', 'Time Spent'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '10')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '11', 'FEN'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '11')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '12', 'Phase ID'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '12')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '13', 'Move Played'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '13')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '14', 'Move Played Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '14')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '15', 'Move Played Rank'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '15')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '16', 'Centipawn Loss'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '16')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '17', 'Engine Move #1'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '17')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '18', 'Engine Move #1 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '18')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '19', 'Engine Move #2'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '19')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '20', 'Engine Move #2 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '20')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '21', 'Engine Move #3'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '21')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '22', 'Engine Move #3 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '22')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '23', 'Engine Move #4'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '23')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '24', 'Engine Move #4 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '24')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '25', 'Engine Move #5'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '25')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '26', 'Engine Move #5 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '26')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '27', 'Engine Move #6'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '27')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '28', 'Engine Move #6 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '28')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '29', 'Engine Move #7'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '29')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '30', 'Engine Move #7 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '30')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '31', 'Engine Move #8'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '31')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '32', 'Engine Move #8 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '32')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '33', 'Engine Move #9'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '33')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '34', 'Engine Move #9 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '34')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '35', 'Engine Move #10'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '35')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '36', 'Engine Move #10 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '36')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '37', 'Engine Move #11'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '37')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '38', 'Engine Move #11 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '38')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '39', 'Engine Move #12'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '39')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '40', 'Engine Move #12 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '40')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '41', 'Engine Move #13'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '41')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '42', 'Engine Move #13 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '42')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '43', 'Engine Move #14'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '43')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '44', 'Engine Move #14 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '44')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '45', 'Engine Move #15'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '45')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '46', 'Engine Move #15 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '46')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '47', 'Engine Move #16'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '47')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '48', 'Engine Move #16 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '48')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '49', 'Engine Move #17'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '49')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '50', 'Engine Move #17 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '50')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '51', 'Engine Move #18'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '51')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '52', 'Engine Move #18 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '52')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '53', 'Engine Move #19'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '53')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '54', 'Engine Move #19 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '54')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '55', 'Engine Move #20'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '55')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '56', 'Engine Move #20 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '56')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '57', 'Engine Move #21'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '57')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '58', 'Engine Move #21 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '58')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '59', 'Engine Move #22'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '59')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '60', 'Engine Move #22 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '60')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '61', 'Engine Move #23'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '61')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '62', 'Engine Move #23 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '62')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '63', 'Engine Move #24'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '63')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '64', 'Engine Move #24 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '64')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '65', 'Engine Move #25'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '65')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '66', 'Engine Move #25 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '66')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '67', 'Engine Move #26'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '67')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '68', 'Engine Move #26 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '68')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '69', 'Engine Move #27'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '69')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '70', 'Engine Move #27 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '70')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '71', 'Engine Move #28'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '71')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '72', 'Engine Move #28 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '72')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '73', 'Engine Move #29'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '73')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '74', 'Engine Move #29 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '74')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '75', 'Engine Move #30'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '75')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '76', 'Engine Move #30 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '76')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '77', 'Engine Move #31'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '77')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '78', 'Engine Move #31 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '78')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '79', 'Engine Move #32'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '79')

INSERT INTO doc.RecordLayouts (RecordKey, FieldPosition, FieldName)
SELECT 'M', '80', 'Engine Move #32 Evaluation'
WHERE NOT EXISTS (SELECT RecordKey, FieldPosition FROM doc.RecordLayouts WHERE RecordKey = 'M' AND FieldPosition = '80')


--Schema: stat
----Table: DistributionTypes
SET IDENTITY_INSERT stat.DistributionTypes ON

INSERT INTO stat.DistributionTypes (DistributionID, DistributionType)
SELECT '1', 'Normal'
WHERE NOT EXISTS (SELECT DistributionID FROM stat.DistributionTypes WHERE DistributionID = '1')

INSERT INTO stat.DistributionTypes (DistributionID, DistributionType)
SELECT '2', 'Gamma'
WHERE NOT EXISTS (SELECT DistributionID FROM stat.DistributionTypes WHERE DistributionID = '2')

SET IDENTITY_INSERT stat.DistributionTypes OFF


----Table: PerfRatingCrossRef
INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.0', '-800'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.0')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.01', '-677'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.01')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.02', '-589'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.02')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.03', '-538'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.03')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.04', '-501'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.04')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.05', '-470'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.05')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.06', '-444'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.06')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.07', '-422'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.07')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.08', '-401'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.08')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.09', '-383'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.09')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.1', '-366'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.1')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.11', '-351'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.11')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.12', '-336'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.12')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.13', '-322'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.13')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.14', '-309'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.14')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.15', '-296'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.15')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.16', '-284'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.16')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.17', '-273'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.17')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.18', '-262'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.18')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.19', '-251'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.19')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.2', '-240'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.2')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.21', '-230'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.21')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.22', '-220'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.22')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.23', '-211'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.23')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.24', '-202'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.24')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.25', '-193'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.25')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.26', '-184'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.26')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.27', '-175'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.27')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.28', '-166'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.28')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.29', '-158'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.29')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.3', '-149'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.3')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.31', '-141'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.31')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.32', '-133'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.32')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.33', '-125'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.33')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.34', '-117'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.34')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.35', '-110'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.35')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.36', '-102'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.36')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.37', '-95'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.37')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.38', '-87'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.38')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.39', '-80'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.39')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.4', '-72'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.4')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.41', '-65'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.41')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.42', '-57'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.42')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.43', '-50'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.43')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.44', '-43'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.44')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.45', '-36'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.45')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.46', '-29'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.46')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.47', '-21'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.47')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.48', '-14'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.48')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.49', '-7'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.49')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.5', '0'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.5')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.51', '7'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.51')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.52', '14'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.52')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.53', '21'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.53')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.54', '29'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.54')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.55', '36'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.55')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.56', '43'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.56')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.57', '50'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.57')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.58', '57'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.58')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.59', '65'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.59')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.6', '72'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.6')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.61', '80'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.61')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.62', '87'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.62')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.63', '95'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.63')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.64', '102'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.64')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.65', '110'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.65')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.66', '117'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.66')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.67', '125'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.67')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.68', '133'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.68')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.69', '141'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.69')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.7', '149'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.7')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.71', '158'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.71')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.72', '166'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.72')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.73', '175'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.73')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.74', '184'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.74')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.75', '193'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.75')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.76', '202'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.76')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.77', '211'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.77')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.78', '220'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.78')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.79', '230'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.79')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.8', '240'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.8')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.81', '251'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.81')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.82', '262'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.82')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.83', '273'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.83')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.84', '284'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.84')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.85', '296'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.85')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.86', '309'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.86')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.87', '322'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.87')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.88', '336'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.88')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.89', '351'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.89')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.9', '366'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.9')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.91', '383'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.91')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.92', '401'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.92')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.93', '422'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.93')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.94', '444'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.94')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.95', '470'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.95')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.96', '501'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.96')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.97', '538'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.97')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.98', '589'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.98')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '0.99', '677'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '0.99')

INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT '1.0', '800'
WHERE NOT EXISTS (SELECT Score FROM stat.PerfRatingCrossRef WHERE Score = '1.0')
