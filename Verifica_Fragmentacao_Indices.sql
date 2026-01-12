-- =================================================================================
-- Autor: Micael Tonini
-- Data: 03/25
--
-- Descrição:
-- Analisa a fragmentação de todos os índices em um banco de dados específico.
-- Fornece uma recomendação de ação (REORGANIZE ou REBUILD) com base nas
-- boas práticas da Microsoft:
-- - > 5% e < 30%: REORGANIZE
-- - > 30%: REBUILD
--
-- DMVs Utilizadas:
-- - sys.dm_db_index_physical_stats: Retorna informações de tamanho e fragmentação.
-- - sys.indexes: Metadados sobre os índices.
-- - sys.objects: Metadados sobre os objetos (tabelas).
-- =================================================================================

-- Parâmetros
DECLARE @db_id INT = DB_ID(); -- ID do banco de dados atual. Mude se necessário.
DECLARE @object_id INT = NULL; -- NULL para todas as tabelas do banco.

SELECT
    dbs.name AS DatabaseName,
    obj.name AS TableName,
    idx.name AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    CASE
        WHEN ips.avg_fragmentation_in_percent > 30 THEN 'REBUILD'
        WHEN ips.avg_fragmentation_in_percent > 5 AND ips.avg_fragmentation_in_percent <= 30 THEN 'REORGANIZE'
        ELSE 'Nenhuma Ação Necessária'
    END AS AcaoRecomendada,
    'ALTER INDEX [' + idx.name + '] ON [' + sch.name + '].[' + obj.name + '] ' +
    CASE
        WHEN ips.avg_fragmentation_in_percent > 30 THEN 'REBUILD'
        WHEN ips.avg_fragmentation_in_percent > 5 AND ips.avg_fragmentation_in_percent <= 30 THEN 'REORGANIZE'
        ELSE ''
    END + ';' AS ComandoSQL
FROM
    sys.dm_db_index_physical_stats(@db_id, @object_id, NULL, NULL, 'SAMPLED') AS ips
INNER JOIN
    sys.indexes AS idx ON ips.object_id = idx.object_id AND ips.index_id = idx.index_id
INNER JOIN
    sys.objects AS obj ON ips.object_id = obj.object_id
INNER JOIN
    sys.schemas AS sch ON obj.schema_id = sch.schema_id
INNER JOIN
    sys.databases dbs ON ips.database_id = dbs.database_id
WHERE
    ips.page_count > 1000 -- Ignora índices pequenos, onde a fragmentação tem pouco impacto
    AND ips.index_id > 0 -- Ignora heaps (tabelas sem índice clustered)
    AND ips.avg_fragmentation_in_percent > 5
ORDER BY
    avg_fragmentation_in_percent DESC;

