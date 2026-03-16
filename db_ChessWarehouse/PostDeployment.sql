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
SELECT v.FileTypeID, v.FileType, v.FileExtension
FROM 
(
    VALUES
        (1, 'Chess Game Analysis', 'game'),
        (2, 'Lichess Evaluations', 'lieval'),
        (3, 'Unanalyzed Chess Games', 'game2')
) AS v (FileTypeID, FileType, FileExtension)
WHERE NOT EXISTS (SELECT 1 FROM dbo.FileTypes AS a WHERE a.FileTypeID = v.FileTypeID)

SET IDENTITY_INSERT dbo.FileTypes OFF


----Table: Settings
SET IDENTITY_INSERT dbo.Settings ON

INSERT INTO dbo.Settings (ID, Name, Value, Description)
SELECT v.ID, v.Name, v.Value, v.Description
FROM 
(
    VALUES
        (1, 'Forced Move Threshold', '2', 'Difference between T1 and T2 evaluations for move to be considered forced'),
        (2, 'CP Loss Window', '1', 'The maximum CP Loss for a move to be considered a candidate move'),
        (3, 'Max Eval', '3', 'The maximum T1 and move evaluation included in calculations'),
        (4, 'Import Directory', 'C:\FileProcessing\Import', 'General import file location'),
        (5, 'Export Directory', 'C:\FileProcessing\Export', 'General export file location'),
        (6, 'Import File', NULL, 'Name of file to import'),
        (7, 'WinProbabilityLostEqual Source', '3', 'Source used for the WinProbabilityLostEqual calculations'),
        (8, 'WinProbabilityLostEqual Time Control', '5', 'Time Control used for the WinProbabilityLostEqual calculations'),
        (9, 'Default Score', '1', 'The default ScoreID value for fact tables'),
        (10, 'FileProcessing Directory', 'C:\FileProcessing', 'File processing root directory'),
        (11, 'Z-Score Weights', '0.2|0.35|0.45', 'Weights for T1, ScACPL, and Score (respectively) for composite Z-Scores')
) AS v (ID, Name, Value, Description)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Settings AS a WHERE a.ID = v.ID)

SET IDENTITY_INSERT dbo.Settings OFF


--Schema: dim
----Table: Aggregations
SET IDENTITY_INSERT dim.Aggregations ON

INSERT INTO dim.Aggregations (AggregationID, AggregationName)
SELECT v.AggregationID, v.AggregationName
FROM 
(
    VALUES
        (1, 'Game'),
        (2, 'Event'),
        (3, 'Evaluation')
) AS v (AggregationID, AggregationName)
WHERE NOT EXISTS (SELECT 1 FROM dim.Aggregations AS a WHERE a.AggregationID = v.AggregationID)

SET IDENTITY_INSERT dim.Aggregations OFF


----Table: AnalysisStatus
SET IDENTITY_INSERT dim.AnalysisStatus ON

INSERT INTO dim.AnalysisStatus (AnalysisStatusID, AnalysisStatusName)
SELECT v.AnalysisStatusID, v.AnalysisStatusName
FROM 
(
    VALUES
        (0, 'Error'),
        (1, 'Pending'),
        (2, 'In Progress'),
        (3, 'Complete')
) AS v (AnalysisStatusID, AnalysisStatusName)
WHERE NOT EXISTS (SELECT 1 FROM dim.AnalysisStatus AS a WHERE a.AnalysisStatusID = v.AnalysisStatusID)

SET IDENTITY_INSERT dim.AnalysisStatus OFF


----Table: Colors
INSERT INTO dim.Colors (ColorID, Color)
SELECT v.ColorID, v.Color
FROM 
(
    VALUES
        (0, 'N/A'),
        (1, 'White'),
        (2, 'Black')
) AS v (ColorID, Color)
WHERE NOT EXISTS (SELECT 1 FROM dim.Colors AS a WHERE a.ColorID = v.ColorID)


----Table: CPLossGroups
SET IDENTITY_INSERT dim.CPLossGroups ON

INSERT INTO dim.CPLossGroups (CPLossGroupID, LBound, UBound, CPLoss_Range)
SELECT v.CPLossGroupID, v.LBound, v.UBound, v.CPLoss_Range
FROM 
(
    VALUES
        (1, 0.0, 0.0, '0.00_0.00'),
        (2, 0.01, 0.09, '0.01_0.09'),
        (3, 0.1, 0.24, '0.10_0.24'),
        (4, 0.25, 0.49, '0.25_0.49'),
        (5, 0.5, 0.99, '0.50_0.99'),
        (6, 1.0, 1.99, '1.00_1.99'),
        (7, 2.0, 4.99, '2.00_4.99'),
        (8, 5.0, 500.0, '5.00_500.00')
) AS v (CPLossGroupID, LBound, UBound, CPLoss_Range)
WHERE NOT EXISTS (SELECT 1 FROM dim.CPLossGroups AS a WHERE a.CPLossGroupID = v.CPLossGroupID)

SET IDENTITY_INSERT dim.CPLossGroups OFF


----Table: ECO
SET IDENTITY_INSERT dim.ECO ON

INSERT INTO dim.ECO (ECOID, ECO_Code, Opening_Name, Variation_Name)
SELECT v.ECOID, v.ECO_Code, v.Opening_Name, v.Variation_Name
FROM 
(
    VALUES
        (1, 'A00', 'Misc', NULL),
        (2, 'A01', '1. b3', NULL),
        (3, 'A02', 'Bird', NULL),
        (4, 'A03', NULL, NULL),
        (5, 'A04', 'Reti', NULL),
        (6, 'A05', NULL, NULL),
        (7, 'A06', NULL, NULL),
        (8, 'A07', NULL, NULL),
        (9, 'A08', NULL, NULL),
        (10, 'A09', NULL, NULL),
        (11, 'A10', 'Misc English', NULL),
        (12, 'A11', NULL, NULL),
        (13, 'A12', NULL, NULL),
        (14, 'A13', NULL, NULL),
        (15, 'A14', NULL, NULL),
        (16, 'A15', '1...Nf6 English', NULL),
        (17, 'A16', NULL, NULL),
        (18, 'A17', NULL, NULL),
        (19, 'A18', 'Mikenas', NULL),
        (20, 'A19', NULL, NULL),
        (21, 'A20', '1...e5 English', NULL),
        (22, 'A21', NULL, NULL),
        (23, 'A22', NULL, NULL),
        (24, 'A23', NULL, NULL),
        (25, 'A24', NULL, NULL),
        (26, 'A25', NULL, NULL),
        (27, 'A26', NULL, NULL),
        (28, 'A27', NULL, NULL),
        (29, 'A28', 'Reversed Sicilian', NULL),
        (30, 'A29', NULL, NULL),
        (31, 'A30', 'Symmetrical', NULL),
        (32, 'A31', NULL, NULL),
        (33, 'A32', NULL, NULL),
        (34, 'A33', NULL, NULL),
        (35, 'A34', NULL, NULL),
        (36, 'A35', NULL, NULL),
        (37, 'A36', NULL, NULL),
        (38, 'A37', NULL, NULL),
        (39, 'A38', NULL, NULL),
        (40, 'A39', 'Pure Symmetrical', NULL),
        (41, 'A40', 'Misc 1. d4', NULL),
        (42, 'A41', NULL, NULL),
        (43, 'A42', 'Modern, Aver', NULL),
        (44, 'A43', 'Old Benoni', NULL),
        (45, 'A44', NULL, NULL),
        (46, 'A45', 'Misc 1...Nf6', NULL),
        (47, 'A46', NULL, NULL),
        (48, 'A47', 'Misc QID', NULL),
        (49, 'A48', 'Misc KID', NULL),
        (50, 'A49', NULL, NULL),
        (51, 'A50', 'Misc 2. c4', NULL),
        (52, 'A51', 'Budapest', NULL),
        (53, 'A52', NULL, NULL),
        (54, 'A53', 'Old Indian', NULL),
        (55, 'A54', NULL, NULL),
        (56, 'A55', NULL, NULL),
        (57, 'A56', 'Misc Benoni', NULL),
        (58, 'A57', 'Benko', NULL),
        (59, 'A58', NULL, NULL),
        (60, 'A59', NULL, NULL),
        (61, 'A60', 'Misc Benoni', NULL),
        (62, 'A61', NULL, NULL),
        (63, 'A62', 'Fianchetto', NULL),
        (64, 'A63', NULL, NULL),
        (65, 'A64', NULL, NULL),
        (66, 'A65', NULL, NULL),
        (67, 'A66', 'Taimanov', NULL),
        (68, 'A67', NULL, NULL),
        (69, 'A68', NULL, NULL),
        (70, 'A69', NULL, NULL),
        (71, 'A70', 'Classical', NULL),
        (72, 'A71', NULL, NULL),
        (73, 'A72', NULL, NULL),
        (74, 'A73', NULL, NULL),
        (75, 'A74', NULL, NULL),
        (76, 'A75', NULL, NULL),
        (77, 'A76', NULL, NULL),
        (78, 'A77', NULL, NULL),
        (79, 'A78', NULL, NULL),
        (80, 'A79', NULL, NULL),
        (81, 'A80', 'Misc Dutch', NULL),
        (82, 'A81', NULL, NULL),
        (83, 'A82', NULL, NULL),
        (84, 'A83', NULL, NULL),
        (85, 'A84', NULL, NULL),
        (86, 'A85', NULL, NULL),
        (87, 'A86', NULL, NULL),
        (88, 'A87', 'Leningrad', NULL),
        (89, 'A88', NULL, NULL),
        (90, 'A89', NULL, NULL),
        (91, 'A90', 'Classical', NULL),
        (92, 'A91', NULL, NULL),
        (93, 'A92', NULL, NULL),
        (94, 'A93', 'Stonewall', NULL),
        (95, 'A94', NULL, NULL),
        (96, 'A95', NULL, NULL),
        (97, 'A96', NULL, NULL),
        (98, 'A97', 'Ilyin-Genevsky', NULL),
        (99, 'A98', NULL, NULL),
        (100, 'A99', NULL, NULL),
        (101, 'B00', 'Misc 1. e4', NULL),
        (102, 'B01', 'Scandi', NULL),
        (103, 'B02', 'Alekhine', NULL),
        (104, 'B03', NULL, NULL),
        (105, 'B04', NULL, NULL),
        (106, 'B05', NULL, NULL),
        (107, 'B06', 'Modern', NULL),
        (108, 'B07', 'Pirc', NULL),
        (109, 'B08', NULL, NULL),
        (110, 'B09', NULL, NULL),
        (111, 'B10', 'Caro-Kann', NULL),
        (112, 'B11', NULL, NULL),
        (113, 'B12', NULL, NULL),
        (114, 'B13', NULL, NULL),
        (115, 'B14', 'Panov', NULL),
        (116, 'B15', '3. Nc3', NULL),
        (117, 'B16', NULL, NULL),
        (118, 'B17', NULL, NULL),
        (119, 'B18', NULL, NULL),
        (120, 'B19', NULL, NULL),
        (121, 'B20', 'Misc Sicilian', NULL),
        (122, 'B21', NULL, NULL),
        (123, 'B22', 'Alapin', NULL),
        (124, 'B23', 'Closed', NULL),
        (125, 'B24', NULL, NULL),
        (126, 'B25', NULL, NULL),
        (127, 'B26', NULL, NULL),
        (128, 'B27', 'Misc. 2. Nf3', NULL),
        (129, 'B28', NULL, NULL),
        (130, 'B29', NULL, NULL),
        (131, 'B30', 'Misc 2...Nc6', NULL),
        (132, 'B31', 'Rossolimo', NULL),
        (133, 'B32', 'Misc. 3. d4', NULL),
        (134, 'B33', NULL, NULL),
        (135, 'B34', 'Accel. Dragon', NULL),
        (136, 'B35', NULL, NULL),
        (137, 'B36', 'Maroczy Bind', NULL),
        (138, 'B37', NULL, NULL),
        (139, 'B38', NULL, NULL),
        (140, 'B39', NULL, NULL),
        (141, 'B40', 'Misc. 2...e6', NULL),
        (142, 'B41', 'Kan', NULL),
        (143, 'B42', NULL, NULL),
        (144, 'B43', NULL, NULL),
        (145, 'B44', 'Taimanov', NULL),
        (146, 'B45', NULL, NULL),
        (147, 'B46', NULL, NULL),
        (148, 'B47', NULL, NULL),
        (149, 'B48', NULL, NULL),
        (150, 'B49', NULL, NULL),
        (151, 'B50', 'Misc 2...d6', NULL),
        (152, 'B51', 'Moscow', NULL),
        (153, 'B52', NULL, NULL),
        (154, 'B53', '4. Qxd4', NULL),
        (155, 'B54', 'Misc. 4. Nxd4', NULL),
        (156, 'B55', NULL, NULL),
        (157, 'B56', NULL, NULL),
        (158, 'B57', 'Sozin', NULL),
        (159, 'B58', 'Classical', NULL),
        (160, 'B59', NULL, NULL),
        (161, 'B60', 'Richter-Rauzer', NULL),
        (162, 'B61', NULL, NULL),
        (163, 'B62', NULL, NULL),
        (164, 'B63', NULL, NULL),
        (165, 'B64', NULL, NULL),
        (166, 'B65', NULL, NULL),
        (167, 'B66', NULL, NULL),
        (168, 'B67', NULL, NULL),
        (169, 'B68', NULL, NULL),
        (170, 'B69', NULL, NULL),
        (171, 'B70', 'Dragon', NULL),
        (172, 'B71', NULL, NULL),
        (173, 'B72', NULL, NULL),
        (174, 'B73', 'Classical', NULL),
        (175, 'B74', NULL, NULL),
        (176, 'B75', 'Yugoslav', NULL),
        (177, 'B76', NULL, NULL),
        (178, 'B77', NULL, NULL),
        (179, 'B78', NULL, NULL),
        (180, 'B79', NULL, NULL),
        (181, 'B80', 'Scheveningan', NULL),
        (182, 'B81', NULL, NULL),
        (183, 'B82', NULL, NULL),
        (184, 'B83', NULL, NULL),
        (185, 'B84', NULL, NULL),
        (186, 'B85', NULL, NULL),
        (187, 'B86', 'Sozin Attack', NULL),
        (188, 'B87', NULL, NULL),
        (189, 'B88', NULL, NULL),
        (190, 'B89', NULL, NULL),
        (191, 'B90', 'Najdorf', NULL),
        (192, 'B91', NULL, NULL),
        (193, 'B92', NULL, NULL),
        (194, 'B93', NULL, NULL),
        (195, 'B94', '6. Bg5', NULL),
        (196, 'B95', NULL, NULL),
        (197, 'B96', NULL, NULL),
        (198, 'B97', NULL, NULL),
        (199, 'B98', NULL, NULL),
        (200, 'B99', NULL, NULL),
        (201, 'C00', 'Misc French', NULL),
        (202, 'C01', 'Exchange', NULL),
        (203, 'C02', 'Advance', NULL),
        (204, 'C03', 'Tarrasch', NULL),
        (205, 'C04', NULL, NULL),
        (206, 'C05', NULL, NULL),
        (207, 'C06', NULL, NULL),
        (208, 'C07', NULL, NULL),
        (209, 'C08', NULL, NULL),
        (210, 'C09', NULL, NULL),
        (211, 'C10', 'Misc. 3. Nc3', NULL),
        (212, 'C11', NULL, NULL),
        (213, 'C12', 'MacCutcheon', NULL),
        (214, 'C13', 'Classical', NULL),
        (215, 'C14', NULL, NULL),
        (216, 'C15', 'Winawer', NULL),
        (217, 'C16', NULL, NULL),
        (218, 'C17', NULL, NULL),
        (219, 'C18', NULL, NULL),
        (220, 'C19', NULL, NULL),
        (221, 'C20', 'Misc 1...e5', NULL),
        (222, 'C21', 'Centre Game', NULL),
        (223, 'C22', NULL, NULL),
        (224, 'C23', 'Bishop\x84s', NULL),
        (225, 'C24', NULL, NULL),
        (226, 'C25', 'Vienna', NULL),
        (227, 'C26', NULL, NULL),
        (228, 'C27', NULL, NULL),
        (229, 'C28', NULL, NULL),
        (230, 'C29', NULL, NULL),
        (231, 'C30', 'King\x84s Gambit', NULL),
        (232, 'C31', NULL, NULL),
        (233, 'C32', NULL, NULL),
        (234, 'C33', NULL, NULL),
        (235, 'C34', NULL, NULL),
        (236, 'C35', NULL, NULL),
        (237, 'C36', NULL, NULL),
        (238, 'C37', NULL, NULL),
        (239, 'C38', NULL, NULL),
        (240, 'C39', NULL, NULL),
        (241, 'C40', 'Misc 2. Nf3', NULL),
        (242, 'C41', 'Philidor', NULL),
        (243, 'C42', 'Petrov', NULL),
        (244, 'C43', NULL, NULL),
        (245, 'C44', 'Misc 2..Nc6', NULL),
        (246, 'C45', 'Scotch', NULL),
        (247, 'C46', 'Three Knights', NULL),
        (248, 'C47', 'Scotch Four knights', NULL),
        (249, 'C48', NULL, NULL),
        (250, 'C49', NULL, NULL),
        (251, 'C50', 'Misc 3. Bc4', NULL),
        (252, 'C51', 'Evan\x84s Gambit', NULL),
        (253, 'C52', NULL, NULL),
        (254, 'C53', 'Giuoco Piano', NULL),
        (255, 'C54', NULL, NULL),
        (256, 'C55', 'Two knights', NULL),
        (257, 'C56', NULL, NULL),
        (258, 'C57', NULL, NULL),
        (259, 'C58', NULL, NULL),
        (260, 'C59', NULL, NULL),
        (261, 'C60', 'Misc Ruy Lopez', NULL),
        (262, 'C61', NULL, NULL),
        (263, 'C62', NULL, NULL),
        (264, 'C63', NULL, NULL),
        (265, 'C64', NULL, NULL),
        (266, 'C65', 'Berlin', NULL),
        (267, 'C66', NULL, NULL),
        (268, 'C67', NULL, NULL),
        (269, 'C68', 'Exchange', NULL),
        (270, 'C69', NULL, NULL),
        (271, 'C70', '4. Ba4', NULL),
        (272, 'C71', NULL, NULL),
        (273, 'C72', NULL, NULL),
        (274, 'C73', NULL, NULL),
        (275, 'C74', NULL, NULL),
        (276, 'C75', NULL, NULL),
        (277, 'C76', NULL, NULL),
        (278, 'C77', NULL, NULL),
        (279, 'C78', '5. 0-0', NULL),
        (280, 'C79', NULL, NULL),
        (281, 'C80', 'Open', NULL),
        (282, 'C81', NULL, NULL),
        (283, 'C82', NULL, NULL),
        (284, 'C83', NULL, NULL),
        (285, 'C84', 'Misc. Closed', NULL),
        (286, 'C85', NULL, NULL),
        (287, 'C86', 'Worrall', NULL),
        (288, 'C87', NULL, NULL),
        (289, 'C88', 'Anti-Marshall', NULL),
        (290, 'C89', 'Marshall', NULL),
        (291, 'C90', 'Misc. 8...d6', NULL),
        (292, 'C91', '9. d4', NULL),
        (293, 'C92', 'Zaitsev', NULL),
        (294, 'C93', NULL, NULL),
        (295, 'C94', 'Breyer', NULL),
        (296, 'C95', NULL, NULL),
        (297, 'C96', 'Chigorin', NULL),
        (298, 'C97', NULL, NULL),
        (299, 'C98', NULL, NULL),
        (300, 'C99', NULL, NULL),
        (301, 'D00', 'Misc. 1...d5', NULL),
        (302, 'D01', 'Veresov', NULL),
        (303, 'D02', 'Misc. 2. Nf3', NULL),
        (304, 'D03', 'Torre', NULL),
        (305, 'D04', 'Colle', NULL),
        (306, 'D05', NULL, NULL),
        (307, 'D06', 'Misc 2. c4', NULL),
        (308, 'D07', 'Chigorin', NULL),
        (309, 'D08', NULL, NULL),
        (310, 'D09', NULL, NULL),
        (311, 'D10', 'Slav', NULL),
        (312, 'D11', NULL, NULL),
        (313, 'D12', NULL, NULL),
        (314, 'D13', 'Exchange', NULL),
        (315, 'D14', NULL, NULL),
        (316, 'D15', NULL, NULL),
        (317, 'D16', 'Misc 4...dxc4', NULL),
        (318, 'D17', '4...dxc4', NULL),
        (319, 'D18', NULL, NULL),
        (320, 'D19', NULL, NULL),
        (321, 'D20', 'QGA', NULL),
        (322, 'D21', 'Misc 3. Nf3', NULL),
        (323, 'D22', NULL, NULL),
        (324, 'D23', NULL, NULL),
        (325, 'D24', '4. Nc3', NULL),
        (326, 'D25', 'Main line', NULL),
        (327, 'D26', NULL, NULL),
        (328, 'D27', NULL, NULL),
        (329, 'D28', NULL, NULL),
        (330, 'D29', NULL, NULL),
        (331, 'D30', 'Misc QGD', NULL),
        (332, 'D31', NULL, NULL),
        (333, 'D32', 'Tarrasch', NULL),
        (334, 'D33', NULL, NULL),
        (335, 'D34', NULL, NULL),
        (336, 'D35', 'Misc 3...Nf6', NULL),
        (337, 'D36', 'Exchange', NULL),
        (338, 'D37', '4. Nf3', NULL),
        (339, 'D38', 'Ragozin', NULL),
        (340, 'D39', NULL, NULL),
        (341, 'D40', 'Semi-Tarrasch', NULL),
        (342, 'D41', NULL, NULL),
        (343, 'D42', NULL, NULL),
        (344, 'D43', 'Semi-Slav', NULL),
        (345, 'D44', 'Botvinnik', NULL),
        (346, 'D45', 'Anti-Meran', NULL),
        (347, 'D46', 'Meran', NULL),
        (348, 'D47', NULL, NULL),
        (349, 'D48', '8...a6', NULL),
        (350, 'D49', NULL, NULL),
        (351, 'D50', 'QGD', NULL),
        (352, 'D51', NULL, NULL),
        (353, 'D52', 'Cambridge-Springs', NULL),
        (354, 'D53', '4...Be7', NULL),
        (355, 'D54', NULL, NULL),
        (356, 'D55', '6. Nf3', NULL),
        (357, 'D56', 'Lasker', NULL),
        (358, 'D57', NULL, NULL),
        (359, 'D58', 'Tartakower', NULL),
        (360, 'D59', NULL, NULL),
        (361, 'D60', 'Orthodox', NULL),
        (362, 'D61', NULL, NULL),
        (363, 'D62', NULL, NULL),
        (364, 'D63', NULL, NULL),
        (365, 'D64', NULL, NULL),
        (366, 'D65', NULL, NULL),
        (367, 'D66', NULL, NULL),
        (368, 'D67', NULL, NULL),
        (369, 'D68', NULL, NULL),
        (370, 'D69', NULL, NULL),
        (371, 'D70', 'Anti Grunfeld', NULL),
        (372, 'D71', NULL, NULL),
        (373, 'D72', NULL, NULL),
        (374, 'D73', NULL, NULL),
        (375, 'D74', NULL, NULL),
        (376, 'D75', NULL, NULL),
        (377, 'D76', NULL, NULL),
        (378, 'D77', NULL, NULL),
        (379, 'D78', NULL, NULL),
        (380, 'D79', NULL, NULL),
        (381, 'D80', 'Grunfeld', NULL),
        (382, 'D81', NULL, NULL),
        (383, 'D82', NULL, NULL),
        (384, 'D83', NULL, NULL),
        (385, 'D84', NULL, NULL),
        (386, 'D85', 'Exchange', NULL),
        (387, 'D86', NULL, NULL),
        (388, 'D87', NULL, NULL),
        (389, 'D88', '7. Bc4', NULL),
        (390, 'D89', NULL, NULL),
        (391, 'D90', '4. Nf3', NULL),
        (392, 'D91', NULL, NULL),
        (393, 'D92', NULL, NULL),
        (394, 'D93', NULL, NULL),
        (395, 'D94', NULL, NULL),
        (396, 'D95', NULL, NULL),
        (397, 'D96', 'Russian', NULL),
        (398, 'D97', NULL, NULL),
        (399, 'D98', NULL, NULL),
        (400, 'D99', NULL, NULL),
        (401, 'E00', 'Misc. 2...e6', NULL),
        (402, 'E01', 'Catalan', NULL),
        (403, 'E02', NULL, NULL),
        (404, 'E03', NULL, NULL),
        (405, 'E04', 'Open', NULL),
        (406, 'E05', NULL, NULL),
        (407, 'E06', 'Closed', NULL),
        (408, 'E07', NULL, NULL),
        (409, 'E08', NULL, NULL),
        (410, 'E09', NULL, NULL),
        (411, 'E10', 'Misc. 3. Nf3', NULL),
        (412, 'E11', 'Bogo-Indian', NULL),
        (413, 'E12', 'QID', NULL),
        (414, 'E13', NULL, NULL),
        (415, 'E14', NULL, NULL),
        (416, 'E15', '4. g3', NULL),
        (417, 'E16', '5...Bb4+', NULL),
        (418, 'E17', '5...Be7', NULL),
        (419, 'E18', NULL, NULL),
        (420, 'E19', NULL, NULL),
        (421, 'E20', 'Nimzo-Indian', NULL),
        (422, 'E21', NULL, NULL),
        (423, 'E22', NULL, NULL),
        (424, 'E23', NULL, NULL),
        (425, 'E24', 'Saemisch', NULL),
        (426, 'E25', NULL, NULL),
        (427, 'E26', NULL, NULL),
        (428, 'E27', NULL, NULL),
        (429, 'E28', NULL, NULL),
        (430, 'E29', NULL, NULL),
        (431, 'E30', '4. Bg5', NULL),
        (432, 'E31', NULL, NULL),
        (433, 'E32', 'Classical', NULL),
        (434, 'E33', NULL, NULL),
        (435, 'E34', '4...d5', NULL),
        (436, 'E35', NULL, NULL),
        (437, 'E36', NULL, NULL),
        (438, 'E37', NULL, NULL),
        (439, 'E38', '4...c5', NULL),
        (440, 'E39', NULL, NULL),
        (441, 'E40', 'Rubinstein', NULL),
        (442, 'E41', NULL, NULL),
        (443, 'E42', NULL, NULL),
        (444, 'E43', NULL, NULL),
        (445, 'E44', NULL, NULL),
        (446, 'E45', NULL, NULL),
        (447, 'E46', '4...0-0', NULL),
        (448, 'E47', NULL, NULL),
        (449, 'E48', NULL, NULL),
        (450, 'E49', NULL, NULL),
        (451, 'E50', NULL, NULL),
        (452, 'E51', NULL, NULL),
        (453, 'E52', 'Main line', NULL),
        (454, 'E53', NULL, NULL),
        (455, 'E54', NULL, NULL),
        (456, 'E55', NULL, NULL),
        (457, 'E56', NULL, NULL),
        (458, 'E57', NULL, NULL),
        (459, 'E58', NULL, NULL),
        (460, 'E59', NULL, NULL),
        (461, 'E60', 'KID', NULL),
        (462, 'E61', NULL, NULL),
        (463, 'E62', 'Fianchetto', NULL),
        (464, 'E63', NULL, NULL),
        (465, 'E64', NULL, NULL),
        (466, 'E65', NULL, NULL),
        (467, 'E66', NULL, NULL),
        (468, 'E67', NULL, NULL),
        (469, 'E68', NULL, NULL),
        (470, 'E69', NULL, NULL),
        (471, 'E70', '4. e4', NULL),
        (472, 'E71', NULL, NULL),
        (473, 'E72', NULL, NULL),
        (474, 'E73', '5. Be2', NULL),
        (475, 'E74', NULL, NULL),
        (476, 'E75', NULL, NULL),
        (477, 'E76', 'Four Pawns', NULL),
        (478, 'E77', NULL, NULL),
        (479, 'E78', NULL, NULL),
        (480, 'E79', NULL, NULL),
        (481, 'E80', 'Saemisch', NULL),
        (482, 'E81', NULL, NULL),
        (483, 'E82', NULL, NULL),
        (484, 'E83', NULL, NULL),
        (485, 'E84', NULL, NULL),
        (486, 'E85', NULL, NULL),
        (487, 'E86', NULL, NULL),
        (488, 'E87', NULL, NULL),
        (489, 'E88', NULL, NULL),
        (490, 'E89', NULL, NULL),
        (491, 'E90', '5. Nf3', NULL),
        (492, 'E91', '6. Be2', NULL),
        (493, 'E92', '6...e5', NULL),
        (494, 'E93', 'Petrosian', NULL),
        (495, 'E94', '7. 0-0', NULL),
        (496, 'E95', '7...Nbd7', NULL),
        (497, 'E96', NULL, NULL),
        (498, 'E97', 'Mar del Plata', NULL),
        (499, 'E98', '9. Ne1', NULL),
        (500, 'E99', NULL, NULL)
) AS v (ECOID, ECO_Code, Opening_Name, Variation_Name)
WHERE NOT EXISTS (SELECT 1 FROM dim.ECO AS a WHERE a.ECOID = v.ECOID)

SET IDENTITY_INSERT dim.ECO OFF


----Table: EvaluationGroups
INSERT INTO dim.EvaluationGroups (EvaluationGroupID, LBound, UBound, Meaning)
SELECT v.EvaluationGroupID, v.LBound, v.UBound, v.Meaning
FROM 
(
    VALUES
        (0, NULL, NULL, 'N/A'),
        (1, -500.0, -3.0, '-+'),
        (2, -2.99, -1.5, '-/+ / -+'),
        (3, -1.49, -0.75, '=+ / -/+'),
        (4, -0.74, -0.25, '= / =+'),
        (5, -0.24, -0.01, '='),
        (6, 0.0, 0.0, '='),
        (7, 0.01, 0.24, '='),
        (8, 0.25, 0.74, '= / +='),
        (9, 0.75, 1.49, '+= / +/-'),
        (10, 1.5, 2.99, '+/- / +-'),
        (11, 3.0, 500.0, '+-')
) AS v (EvaluationGroupID, LBound, UBound, Meaning)
WHERE NOT EXISTS (SELECT 1 FROM dim.EvaluationGroups AS a WHERE a.EvaluationGroupID = v.EvaluationGroupID)


----Table: Measurements
SET IDENTITY_INSERT dim.Measurements ON

INSERT INTO dim.Measurements (MeasurementID, MeasurementName, ZScore_Multiplier)
SELECT v.MeasurementID, v.MeasurementName, v.ZScore_Multiplier
FROM 
(
    VALUES
        (1, 'T1', 1),
        (2, 'T2', 1),
        (3, 'T3', 1),
        (4, 'T4', 1),
        (5, 'T5', 1),
        (6, 'ACPL', -1),
        (7, 'SDCPL', -1),
        (8, 'WinProbabilityLost', 1),
        (9, 'ScACPL', -1),
        (10, 'ScSDCPL', -1),
        (11, 'EvaluationGroupComparison', 1)
) AS v (MeasurementID, MeasurementName, ZScore_Multiplier)
WHERE NOT EXISTS (SELECT 1 FROM dim.Measurements AS a WHERE a.MeasurementID = v.MeasurementID)

SET IDENTITY_INSERT dim.Measurements OFF


----Table: Phases
SET IDENTITY_INSERT dim.Phases ON

INSERT INTO dim.Phases (PhaseID, Phase)
SELECT v.PhaseID, v.Phase
FROM 
(
    VALUES
        (1, 'Opening'),
        (2, 'Middlegame'),
        (3, 'Endgame')
) AS v (PhaseID, Phase)
WHERE NOT EXISTS (SELECT 1 FROM dim.Phases AS a WHERE a.PhaseID = v.PhaseID)

SET IDENTITY_INSERT dim.Phases OFF


----Table: Ratings
INSERT INTO dim.Ratings (RatingID, RatingUpperBound)
SELECT v.RatingID, v.RatingUpperBound
FROM 
(
    VALUES
        (0, 99),
        (100, 199),
        (200, 299),
        (300, 399),
        (400, 499),
        (500, 599),
        (600, 699),
        (700, 799),
        (800, 899),
        (900, 999),
        (1000, 1099),
        (1100, 1199),
        (1200, 1299),
        (1300, 1399),
        (1400, 1499),
        (1500, 1599),
        (1600, 1699),
        (1700, 1799),
        (1800, 1899),
        (1900, 1999),
        (2000, 2099),
        (2100, 2199),
        (2200, 2299),
        (2300, 2399),
        (2400, 2499),
        (2500, 2599),
        (2600, 2699),
        (2700, 2799),
        (2800, 2899),
        (2900, 2999),
        (3000, 3099),
        (3100, 3199),
        (3200, 3299),
        (3300, 3399),
        (3400, 3499),
        (3500, 3599),
        (3600, 3699),
        (3700, 3799),
        (3800, 3899),
        (3900, 3999)
) AS v (RatingID, RatingUpperBound)
WHERE NOT EXISTS (SELECT 1 FROM dim.Ratings AS a WHERE a.RatingID = v.RatingID)


----Table: Scores
SET IDENTITY_INSERT dim.Scores ON

INSERT INTO dim.Scores (ScoreID, ScoreName, ScoreDesc, ScoreActive)
SELECT v.ScoreID, v.ScoreName, v.ScoreDesc, v.ScoreActive
FROM 
(
    VALUES
        (0, 'TestScore', 'This score is used for testing purposes', 0),
        (1, 'WinProbabilityLost', 'A measurement of the change in win probability based on the evaluation and individual game source/time control', 1),
        (2, 'WinProbabilityLostEqual', 'A measurement of the change in win probability based on the evaluation and a predefined game source/time control', 1),
        (3, 'EvaluationGroupComparison', 'A measurement of the historical difficulty in playing similar positions based on the T5 evaluations and individual game source/time control/ratings', 1)
) AS v (ScoreID, ScoreName, ScoreDesc, ScoreActive)
WHERE NOT EXISTS (SELECT 1 FROM dim.Scores AS a WHERE a.ScoreID = v.ScoreID)

SET IDENTITY_INSERT dim.Scores OFF


----Table: Sites
SET IDENTITY_INSERT dim.Sites ON

INSERT INTO dim.Sites (SiteID, SiteName)
SELECT v.SiteID, v.SiteName
FROM 
(
    VALUES
        (1, 'ChessManiac'),
        (2, 'FICS'),
        (3, 'Chess.com'),
        (4, 'Lichess')
) AS v (SiteID, SiteName)
WHERE NOT EXISTS (SELECT 1 FROM dim.Sites AS a WHERE a.SiteID = v.SiteID)

SET IDENTITY_INSERT dim.Sites OFF


----Table: Sources
SET IDENTITY_INSERT dim.Sources ON

INSERT INTO dim.Sources (SourceID, SourceName, PersonalFlag, AnalysisDepth, UseOpeningExplorer, UseTablebase, MovesToAnalyze)
SELECT v.SourceID, v.SourceName, v.PersonalFlag, v.AnalysisDepth, v.UseOpeningExplorer, v.UseTablebase, v.MovesToAnalyze
FROM 
(
    VALUES
        (1, 'Personal', 1, 15, 1, 1, 32),
        (2, 'PersonalOnline', 1, 11, 1, 1, 32),
        (3, 'Control', 0, 11, 1, 1, 32),
        (4, 'Lichess', 0, 11, 0, 0, 5)
) AS v (SourceID, SourceName, PersonalFlag, AnalysisDepth, UseOpeningExplorer, UseTablebase, MovesToAnalyze)
WHERE NOT EXISTS (SELECT 1 FROM dim.Sources AS a WHERE a.SourceID = v.SourceID)

SET IDENTITY_INSERT dim.Sources OFF


----Table: TimeControls
SET IDENTITY_INSERT dim.TimeControls ON

INSERT INTO dim.TimeControls (TimeControlID, TimeControlName, MinSeconds, MaxSeconds)
SELECT v.TimeControlID, v.TimeControlName, v.MinSeconds, v.MaxSeconds
FROM 
(
    VALUES
        (1, 'UltraBullet', 0, 59),
        (2, 'Bullet', 60, 179),
        (3, 'Blitz', 180, 600),
        (4, 'Rapid', 601, 2699),
        (5, 'Classical', 2700, 86399),
        (6, 'Correspondence', 86400, 1209600)
) AS v (TimeControlID, TimeControlName, MinSeconds, MaxSeconds)
WHERE NOT EXISTS (SELECT 1 FROM dim.TimeControls AS a WHERE a.TimeControlID = v.TimeControlID)

SET IDENTITY_INSERT dim.TimeControls OFF


----Table: Traces
INSERT INTO dim.Traces (TraceKey, TraceDescription, Scored)
SELECT v.TraceKey, v.TraceDescription, v.Scored
FROM 
(
    VALUES
        ('0', 'Inferior Move', 1),
        ('b', 'Book Move', 0),
        ('e', 'Eliminated Move', 0),
        ('f', 'Forced Move', 0),
        ('M', 'Equal Value Match Move', 1),
        ('r', 'Repeated Move', 0),
        ('t', 'Tablebase Move', 0)
) AS v (TraceKey, TraceDescription, Scored)
WHERE NOT EXISTS (SELECT 1 FROM dim.Traces AS a WHERE a.TraceKey = v.TraceKey)


--Schema: doc
----Table: Records
INSERT INTO doc.Records (FileTypeID, RecordKey, RecordName)
SELECT v.FileTypeID, v.RecordKey, v.RecordName
FROM 
(
    VALUES
        (1, 'G', 'Games'),
        (1, 'M', 'Moves'),
        (3, 'G', 'Games'),
        (3, 'M', 'Moves')
) AS v (FileTypeID, RecordKey, RecordName)
WHERE NOT EXISTS (SELECT 1 FROM doc.Records AS a WHERE a.FileTypeID = v.FileTypeID)


----Table: RecordLayouts -> dependent on doc.Records
INSERT INTO doc.RecordLayouts (FileTypeID, RecordKey, FieldPosition, FieldName)
SELECT v.FileTypeID, v.RecordKey, v.FieldPosition, v.FieldName
FROM 
(
    VALUES
        (1, 'G', 1, 'Record ID'),
        (1, 'G', 2, 'Source Name'),
        (1, 'G', 3, 'Site Name'),
        (1, 'G', 4, 'Game ID'),
        (1, 'G', 5, 'White Last Name'),
        (1, 'G', 6, 'White First Name'),
        (1, 'G', 7, 'Black Last Name'),
        (1, 'G', 8, 'Black First Name'),
        (1, 'G', 9, 'White Elo Rating'),
        (1, 'G', 10, 'Black Elo Rating'),
        (1, 'G', 11, 'Time Control'),
        (1, 'G', 12, 'ECO Code'),
        (1, 'G', 13, 'Game Date'),
        (1, 'G', 14, 'Game Time'),
        (1, 'G', 15, 'Event Name'),
        (1, 'G', 16, 'Round Number'),
        (1, 'G', 17, 'Result'),
        (1, 'G', 18, 'Event Rated'),
        (1, 'M', 1, 'Record Key'),
        (1, 'M', 2, 'Game ID'),
        (1, 'M', 3, 'Move Number'),
        (1, 'M', 4, 'Color'),
        (1, 'M', 5, 'Is Theory'),
        (1, 'M', 6, 'Is Tablebase'),
        (1, 'M', 7, 'Engine'),
        (1, 'M', 8, 'Depth'),
        (1, 'M', 9, 'Clock'),
        (1, 'M', 10, 'Time Spent'),
        (1, 'M', 11, 'FEN'),
        (1, 'M', 12, 'Phase ID'),
        (1, 'M', 13, 'Move Played'),
        (1, 'M', 14, 'Move Played Evaluation'),
        (1, 'M', 15, 'Move Played Rank'),
        (1, 'M', 16, 'Centipawn Loss'),
        (1, 'M', 17, 'Engine Move #1'),
        (1, 'M', 18, 'Engine Move #1 Evaluation'),
        (1, 'M', 19, 'Engine Move #2'),
        (1, 'M', 20, 'Engine Move #2 Evaluation'),
        (1, 'M', 21, 'Engine Move #3'),
        (1, 'M', 22, 'Engine Move #3 Evaluation'),
        (1, 'M', 23, 'Engine Move #4'),
        (1, 'M', 24, 'Engine Move #4 Evaluation'),
        (1, 'M', 25, 'Engine Move #5'),
        (1, 'M', 26, 'Engine Move #5 Evaluation'),
        (1, 'M', 27, 'Engine Move #6'),
        (1, 'M', 28, 'Engine Move #6 Evaluation'),
        (1, 'M', 29, 'Engine Move #7'),
        (1, 'M', 30, 'Engine Move #7 Evaluation'),
        (1, 'M', 31, 'Engine Move #8'),
        (1, 'M', 32, 'Engine Move #8 Evaluation'),
        (1, 'M', 33, 'Engine Move #9'),
        (1, 'M', 34, 'Engine Move #9 Evaluation'),
        (1, 'M', 35, 'Engine Move #10'),
        (1, 'M', 36, 'Engine Move #10 Evaluation'),
        (1, 'M', 37, 'Engine Move #11'),
        (1, 'M', 38, 'Engine Move #11 Evaluation'),
        (1, 'M', 39, 'Engine Move #12'),
        (1, 'M', 40, 'Engine Move #12 Evaluation'),
        (1, 'M', 41, 'Engine Move #13'),
        (1, 'M', 42, 'Engine Move #13 Evaluation'),
        (1, 'M', 43, 'Engine Move #14'),
        (1, 'M', 44, 'Engine Move #14 Evaluation'),
        (1, 'M', 45, 'Engine Move #15'),
        (1, 'M', 46, 'Engine Move #15 Evaluation'),
        (1, 'M', 47, 'Engine Move #16'),
        (1, 'M', 48, 'Engine Move #16 Evaluation'),
        (1, 'M', 49, 'Engine Move #17'),
        (1, 'M', 50, 'Engine Move #17 Evaluation'),
        (1, 'M', 51, 'Engine Move #18'),
        (1, 'M', 52, 'Engine Move #18 Evaluation'),
        (1, 'M', 53, 'Engine Move #19'),
        (1, 'M', 54, 'Engine Move #19 Evaluation'),
        (1, 'M', 55, 'Engine Move #20'),
        (1, 'M', 56, 'Engine Move #20 Evaluation'),
        (1, 'M', 57, 'Engine Move #21'),
        (1, 'M', 58, 'Engine Move #21 Evaluation'),
        (1, 'M', 59, 'Engine Move #22'),
        (1, 'M', 60, 'Engine Move #22 Evaluation'),
        (1, 'M', 61, 'Engine Move #23'),
        (1, 'M', 62, 'Engine Move #23 Evaluation'),
        (1, 'M', 63, 'Engine Move #24'),
        (1, 'M', 64, 'Engine Move #24 Evaluation'),
        (1, 'M', 65, 'Engine Move #25'),
        (1, 'M', 66, 'Engine Move #25 Evaluation'),
        (1, 'M', 67, 'Engine Move #26'),
        (1, 'M', 68, 'Engine Move #26 Evaluation'),
        (1, 'M', 69, 'Engine Move #27'),
        (1, 'M', 70, 'Engine Move #27 Evaluation'),
        (1, 'M', 71, 'Engine Move #28'),
        (1, 'M', 72, 'Engine Move #28 Evaluation'),
        (1, 'M', 73, 'Engine Move #29'),
        (1, 'M', 74, 'Engine Move #29 Evaluation'),
        (1, 'M', 75, 'Engine Move #30'),
        (1, 'M', 76, 'Engine Move #30 Evaluation'),
        (1, 'M', 77, 'Engine Move #31'),
        (1, 'M', 78, 'Engine Move #31 Evaluation'),
        (1, 'M', 79, 'Engine Move #32'),
        (1, 'M', 80, 'Engine Move #32 Evaluation'),
        (3, 'G', 1, 'Record ID'),
        (3, 'G', 2, 'Source Name'),
        (3, 'G', 3, 'Site Name'),
        (3, 'G', 4, 'Game ID'),
        (3, 'G', 5, 'White Last Name'),
        (3, 'G', 6, 'White First Name'),
        (3, 'G', 7, 'Black Last Name'),
        (3, 'G', 8, 'Black First Name'),
        (3, 'G', 9, 'White Elo Rating'),
        (3, 'G', 10, 'Black Elo Rating'),
        (3, 'G', 11, 'Time Control'),
        (3, 'G', 12, 'ECO Code'),
        (3, 'G', 13, 'Game Date'),
        (3, 'G', 14, 'Game Time'),
        (3, 'G', 15, 'Event Name'),
        (3, 'G', 16, 'Round Number'),
        (3, 'G', 17, 'Result'),
        (3, 'G', 18, 'Event Rated'),
        (3, 'M', 1, 'Record Key'),
        (3, 'M', 2, 'Game ID'),
        (3, 'M', 3, 'Move Number'),
        (3, 'M', 4, 'Color'),
        (3, 'M', 5, 'Clock'),
        (3, 'M', 6, 'Time Spent'),
        (3, 'M', 7, 'FEN'),
        (3, 'M', 8, 'Phase ID'),
        (3, 'M', 9, 'Move Played')
) AS v (FileTypeID, RecordKey, FieldPosition, FieldName)
WHERE NOT EXISTS (SELECT 1 FROM doc.RecordLayouts AS a WHERE a.FileTypeID = v.FileTypeID)


--Schema: stat
----Table: DistributionTypes
SET IDENTITY_INSERT stat.DistributionTypes ON

INSERT INTO stat.DistributionTypes (DistributionID, DistributionType)
SELECT v.DistributionID, v.DistributionType
FROM 
(
    VALUES
        (1, 'Normal'),
        (2, 'Gamma')
) AS v (DistributionID, DistributionType)
WHERE NOT EXISTS (SELECT 1 FROM stat.DistributionTypes AS a WHERE a.DistributionID = v.DistributionID)

SET IDENTITY_INSERT stat.DistributionTypes OFF


----Table: PerfRatingCrossRef
INSERT INTO stat.PerfRatingCrossRef (Score, RatingEffect)
SELECT v.Score, v.RatingEffect
FROM 
(
    VALUES
        (0.0, -800),
        (0.01, -677),
        (0.02, -589),
        (0.03, -538),
        (0.04, -501),
        (0.05, -470),
        (0.06, -444),
        (0.07, -422),
        (0.08, -401),
        (0.09, -383),
        (0.1, -366),
        (0.11, -351),
        (0.12, -336),
        (0.13, -322),
        (0.14, -309),
        (0.15, -296),
        (0.16, -284),
        (0.17, -273),
        (0.18, -262),
        (0.19, -251),
        (0.2, -240),
        (0.21, -230),
        (0.22, -220),
        (0.23, -211),
        (0.24, -202),
        (0.25, -193),
        (0.26, -184),
        (0.27, -175),
        (0.28, -166),
        (0.29, -158),
        (0.3, -149),
        (0.31, -141),
        (0.32, -133),
        (0.33, -125),
        (0.34, -117),
        (0.35, -110),
        (0.36, -102),
        (0.37, -95),
        (0.38, -87),
        (0.39, -80),
        (0.4, -72),
        (0.41, -65),
        (0.42, -57),
        (0.43, -50),
        (0.44, -43),
        (0.45, -36),
        (0.46, -29),
        (0.47, -21),
        (0.48, -14),
        (0.49, -7),
        (0.5, 0),
        (0.51, 7),
        (0.52, 14),
        (0.53, 21),
        (0.54, 29),
        (0.55, 36),
        (0.56, 43),
        (0.57, 50),
        (0.58, 57),
        (0.59, 65),
        (0.6, 72),
        (0.61, 80),
        (0.62, 87),
        (0.63, 95),
        (0.64, 102),
        (0.65, 110),
        (0.66, 117),
        (0.67, 125),
        (0.68, 133),
        (0.69, 141),
        (0.7, 149),
        (0.71, 158),
        (0.72, 166),
        (0.73, 175),
        (0.74, 184),
        (0.75, 193),
        (0.76, 202),
        (0.77, 211),
        (0.78, 220),
        (0.79, 230),
        (0.8, 240),
        (0.81, 251),
        (0.82, 262),
        (0.83, 273),
        (0.84, 284),
        (0.85, 296),
        (0.86, 309),
        (0.87, 322),
        (0.88, 336),
        (0.89, 351),
        (0.9, 366),
        (0.91, 383),
        (0.92, 401),
        (0.93, 422),
        (0.94, 444),
        (0.95, 470),
        (0.96, 501),
        (0.97, 538),
        (0.98, 589),
        (0.99, 677),
        (1.0, 800)
) AS v (Score, RatingEffect)
WHERE NOT EXISTS (SELECT 1 FROM stat.PerfRatingCrossRef AS a WHERE a.Score = v.Score)
