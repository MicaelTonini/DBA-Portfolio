-- =================================================================================
-- Autor: Micael Tonini
-- Data: 01/26
--
-- Descrição:
-- Captura as estatísticas de espera (Wait Stats) do servidor desde a última
-- reinicialização ou limpeza manual. Ajuda a diagnosticar gargalos de recursos
-- como I/O (disco), rede, CPU ou bloqueios (locking/blocking).
--
-- O script filtra "waits benignos" que são comuns e geralmente não indicam
-- um problema, permitindo focar no que realmente importa.
--
-- DMVs Utilizadas:
-- - sys.dm_os_wait_stats: Retorna informações sobre todas as esperas encontradas
--   pelos threads que foram executados.
-- =================================================================================

WITH Waits AS
(
    SELECT
        wait_type,
        wait_time_ms / 1000.0 AS WaitS,
        (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
        signal_wait_time_ms / 1000.0 AS SignalS,
        waiting_tasks_count,
        100.0 * wait_time_ms / SUM(wait_time_ms) OVER() AS Pct
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN (
        -- Filtro para remover "waits benignos" que podem poluir a análise
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
        N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
        N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT',
        N'HADR_NOTIFY_SYNC', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE',
        N'ONDEMAND_TASK_QUEUE', N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK',
        N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY', N'SLEEP_MASTERUPGRADED',
        N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
        N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES', N'WAIT_FOR_RESULTS', N'WAITFOR',
        N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT','WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_WAIT', 'XE_TIMER_EVENT'
    )
)
SELECT
    W.wait_type,
    CAST(W.WaitS AS DECIMAL(14, 2)) AS Wait_S,
    CAST(W.ResourceS AS DECIMAL(14, 2)) AS Resource_S,
    CAST(W.SignalS AS DECIMAL(14, 2)) AS Signal_S,
    W.waiting_tasks_count,
    CAST(W.Pct AS DECIMAL(5, 2)) AS Pct_Total_Waits
FROM Waits AS W
ORDER BY
    Wait_S DESC;

-- Para limpar as estatísticas e começar uma nova análise:
-- DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);

