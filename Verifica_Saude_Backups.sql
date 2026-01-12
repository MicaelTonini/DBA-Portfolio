-- =================================================================================
-- Autor: Micael Tonini
-- Data: 01/26
--
-- Descrição:
-- Audita o histórico de backups na base de dados 'msdb' para verificar a saúde
-- da política de backups.
--
-- O script lista:
-- 1. O último backup de cada tipo (FULL, DIFFERENTIAL, LOG) para cada banco.
-- 2. Alerta sobre bancos de dados que NUNCA tiveram um backup FULL.
-- 3. Alerta sobre bancos em modo de recuperação FULL que não tiveram backup de LOG recente.
--
-- DMVs e Tabelas Utilizadas:
-- - msdb.dbo.backupset: Contém uma linha para cada conjunto de backup.
-- - sys.databases: Metadados sobre todos os bancos de dados na instância.
-- =================================================================================

WITH UltimoBackup AS (
    SELECT
        database_name,
        backup_type =
            CASE type
                WHEN 'D' THEN 'FULL'
                WHEN 'I' THEN 'DIFFERENTIAL'
                WHEN 'L' THEN 'LOG'
            END,
        MAX(backup_finish_date) AS ultimo_backup_data
    FROM
        msdb.dbo.backupset
    GROUP BY
        database_name, type
)
SELECT
    d.name AS NomeBanco,
    d.recovery_model_desc AS RecoveryModel,
    ISNULL(CONVERT(VARCHAR(20), full_bkp.ultimo_backup_data, 120), 'NUNCA REALIZADO') AS UltimoBackupFull,
    ISNULL(CONVERT(VARCHAR(20), diff_bkp.ultimo_backup_data, 120), 'N/A') AS UltimoBackupDifferential,
    ISNULL(CONVERT(VARCHAR(20), log_bkp.ultimo_backup_data, 120), 'N/A') AS UltimoBackupLog,
    CASE
        WHEN d.recovery_model_desc = 'FULL' AND log_bkp.ultimo_backup_data IS NULL THEN 'ALERTA: Banco em modo FULL sem backup de LOG!'
        WHEN d.recovery_model_desc = 'FULL' AND DATEDIFF(HOUR, log_bkp.ultimo_backup_data, GETDATE()) > 24 THEN 'ALERTA: Último backup de LOG há mais de 24 horas!'
        WHEN full_bkp.ultimo_backup_data IS NULL AND d.database_id <> 2 THEN 'CRÍTICO: NENHUM backup FULL encontrado para este banco!' -- Ignora tempdb
        ELSE 'OK'
    END AS Status
FROM
    sys.databases d
LEFT JOIN
    UltimoBackup full_bkp ON d.name = full_bkp.database_name AND full_bkp.backup_type = 'FULL'
LEFT JOIN
    UltimoBackup diff_bkp ON d.name = diff_bkp.database_name AND diff_bkp.backup_type = 'DIFFERENTIAL'
LEFT JOIN
    UltimoBackup log_bkp ON d.name = log_bkp.database_name AND log_bkp.backup_type = 'LOG'
WHERE
    d.source_database_id IS NULL -- Filtra snapshots de banco de dados
ORDER BY
    d.name;

