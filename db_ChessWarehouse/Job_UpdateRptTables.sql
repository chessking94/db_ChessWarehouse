USE [msdb]
GO

DECLARE @jobName NVARCHAR(128) = N'ChessWarehouse - Update [rpt] Schema Tables'

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysjobs WHERE name = @jobName)
BEGIN
	BEGIN TRANSACTION
		DECLARE @ReturnCode INT
		SELECT @ReturnCode = 0

		IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]' AND category_class = 1)
		BEGIN
			EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'[Uncategorized (Local)]'
			IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		END

		DECLARE @jobId BINARY(16)
		EXEC @ReturnCode = msdb.dbo.sp_add_job
			@job_name = @jobName,
			@enabled = 1,
			@notify_level_eventlog = 0,
			@notify_level_email = 0,
			@notify_level_netsend = 0,
			@notify_level_page = 0,
			@delete_level = 0,
			@description = N'No description available.',
			@category_name = N'[Uncategorized (Local)]',
			@owner_login_name = N'job_owner',
			@job_id = @jobId OUTPUT
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'ECOSummary',
			@step_id = 1,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateECOSummary',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'EventSummary',
			@step_id = 2,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateEventSummary',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'GameStatistics',
			@step_id = 2,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateGameStatistics',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'OpponentSummary',
			@step_id = 2,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateOpponentSummary',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'RatingSummary',
			@step_id = 2,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateRatingSummary',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'RoundSummary',
			@step_id = 2,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateRoundSummary',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'TimeControlSummary',
			@step_id = 2,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateTimeControlSummary',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'YearlyRoundStatistics',
			@step_id = 2,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateYearlyRoundStatistics',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'YearlySummary',
			@step_id = 2,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateYearlySummary',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'YearlyTimeControlStatistics',
			@step_id = 2,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateYearlyTimeControlStatistics',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
			@job_id = @jobId,
			@step_name = N'YearlyTStatistics',
			@step_id = 3,
			@cmdexec_success_code = 0,
			@on_success_action = 1,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'EXEC rpt.UpdateYearlyTStatistics',
			@database_name = N'ChessWarehouse',
			@flags = 0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	COMMIT TRANSACTION
END

GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION

EndSave:

GO
