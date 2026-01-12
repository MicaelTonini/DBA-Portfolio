-- =================================================================================
-- Autor: Micael Tonini
-- Data: 01/26
--
-- Descrição:
-- Este script serve como um MODELO para criar uma rotina de backup robusta,
-- combinando backups FULL e de LOG de TRANSAÇÃO.
--
-- ESTRATÉGIA PROPOSTA:
-- 1. Backup FULL: Realizado diariamente (ex: durante a madrugada).
-- 2. Backup de LOG: Realizado a cada 15 minutos durante o horário comercial.
--
-- PRÉ-REQUISITO:
-- O banco de dados DEVE estar no modo de recuperação (Recovery Model) 'FULL'.
-- Para verificar: SELECT name, recovery_model_desc FROM sys.databases;
-- Para alterar: ALTER DATABASE [NomeDoSeuBanco] SET RECOVERY FULL;
--
-- IMPLEMENTAÇÃO:
-- Estes blocos de código devem ser adaptados e configurados como 'Jobs'
-- separados no SQL Server Agent para execução agendada.
-- =================================================================================

-- Variáveis de configuração (adapte conforme o ambiente)
DECLARE @NomeBancoDeDados NVARCHAR(128) = 'SeuBancoDeDados';
DECLARE @CaminhoBackup NVARCHAR(256) = 'C:\Caminho\Para\Backups\'; -- Ex: '\\servidor\backups\'
DECLARE @NomeArquivoBackup NVARCHAR(512);
DECLARE @DataAtual CHAR(8) = CONVERT(CHAR(8), GETDATE(), 112); -- Formato YYYYMMDD

-- =================================================================================
-- BLOCO 1: SCRIPT PARA O JOB DE BACKUP FULL (Agendar 1x por dia)
-- =================================================================================

-- Monta o nome do arquivo com o nome do banco e a data
SET @NomeArquivoBackup = @CaminhoBackup + @NomeBancoDeDados + '_FULL_' + @DataAtual + '.bak';

BACKUP DATABASE @NomeBancoDeDados
TO DISK = @NomeArquivoBackup
WITH
    NOFORMAT,
    INIT,
    NAME = N'Backup Full do Banco de Dados',
    SKIP,
    NOREWIND,
    NOUNLOAD,
    STATS = 10,
    COMPRESSION; -- Use COMPRESSION se sua edição do SQL Server permitir (Standard, Enterprise)
GO

-- =================================================================================
-- BLOCO 2: SCRIPT PARA O JOB DE BACKUP DE LOG (Agendar a cada 15 minutos)
-- =================================================================================

-- Variáveis de configuração
DECLARE @NomeBancoDeDadosLog NVARCHAR(128) = 'SeuBancoDeDados';
DECLARE @CaminhoBackupLog NVARCHAR(256) = 'C:\Caminho\Para\Backups\';
DECLARE @NomeArquivoBackupLog NVARCHAR(512);
DECLARE @DataHoraAtual CHAR(14) = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(19), GETDATE(), 120), '-', ''), ' ', '_'), ':', ''); -- Formato YYYYMMDD_HHMMSS

-- Monta o nome do arquivo com data e hora para não sobrescrever
SET @NomeArquivoBackupLog = @CaminhoBackupLog + @NomeBancoDeDadosLog + '_LOG_' + @DataHoraAtual + '.trn';

BACKUP LOG @NomeBancoDeDadosLog
TO DISK = @NomeArquivoBackupLog
WITH
    NOFORMAT,
    INIT,
    NAME = N'Backup de Log de Transação',
    SKIP,
    NOREWIND,
    NOUNLOAD,
    STATS = 10,
    COMPRESSION;
GO

