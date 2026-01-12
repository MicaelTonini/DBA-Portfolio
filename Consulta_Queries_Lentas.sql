-- =================================================================================
-- Autor: Micael Tonini
-- Data: 11/25
--
-- Descrição:
-- Este script identifica as 50 consultas mais "pesadas" executadas no servidor,
-- com base no tempo total de CPU, leituras lógicas e tempo decorrido.
-- É uma ferramenta essencial para iniciar investigações de performance (tuning).
--
-- DMVs Utilizadas:
-- - sys.dm_exec_query_stats: Agrega estatísticas de performance para planos de consulta em cache.
-- - sys.dm_exec_sql_text: Retorna o texto do lote SQL que corresponde a um sql_handle.
-- - sys.dm_exec_query_plan: Retorna o plano de execução (Showplan) em formato XML.
-- =================================================================================

SELECT TOP 50
    -- Informações de Custo e Duração
    total_worker_time / 1000 AS TotalCpuTime_ms,      -- Tempo total de CPU em milissegundos
    total_elapsed_time / 1000 AS TotalElapsedTime_ms, -- Tempo total decorrido em milissegundos
    total_logical_reads,                              -- Total de leituras lógicas (memória)
    total_logical_writes,                             -- Total de escritas lógicas (memória)
    total_physical_reads,                             -- Total de leituras físicas (disco)

    -- Informações de Execução
    execution_count,                                  -- Quantas vezes a query foi executada
    (total_worker_time / 1000) / execution_count AS AvgCpuTime_ms, -- Média de CPU por execução

    -- Texto e Plano da Query
    SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
          ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2) + 1) AS QueryText,
    DB_NAME(st.dbid) AS DatabaseName,
    qp.query_plan AS QueryPlan -- Plano de execução em XML (clicável no SSMS)

FROM
    sys.dm_exec_query_stats AS qs
CROSS APPLY
    sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY
    sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
    st.dbid IS NOT NULL -- Filtra queries que não estão associadas a um banco de dados específico
ORDER BY
    TotalCpuTime_ms DESC; -- Ordena pelas queries que mais consumiram CPU
    -- Outras opções de ordenação: TotalElapsedTime_ms DESC, total_logical_reads DESC

