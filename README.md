# Portfólio de Projetos e Scripts de SQL Server

Olá! Meu nome é **Micael Tonini** e este repositório serve como meu cartão de visitas técnico, demonstrando minhas habilidades práticas em administração, otimização e manutenção de bancos de dados Microsoft SQL Server.

Atualmente, atuo como **Analista de Suporte Pleno**, onde sou a referência técnica para a infraestrutura de banco de dados e ERP da empresa. Estou em fase final de preparação para a certificação **Microsoft Certified: Azure Database Administrator Associate (DP-300)**, consolidando meu conhecimento para migrar oficialmente para uma carreira de DBA.

https://www.linkedin.com/in/micael-tonini-32309417b/

---

## 🎯 Objetivo deste Portfólio

O objetivo deste repositório é apresentar uma coleção de scripts T-SQL que desenvolvi para resolver problemas comuns do dia a dia de um DBA, focando em três pilares principais:

1.  **Diagnóstico e Monitoramento:** Scripts para identificar problemas de performance e saúde do servidor.
2.  **Automação e Manutenção:** Rotinas para automatizar tarefas repetitivas e garantir a integridade dos dados.
3.  **Segurança e Administração:** Ferramentas para gerenciar permissões e configurações de segurança.

## 🧰 Scripts e Ferramentas

Abaixo está a lista de scripts disponíveis neste repositório, com uma breve descrição de sua funcionalidade.

### 1. Diagnóstico de Performance

*   **`Consulta_Queries_Lentas.sql`**
    *   **Descrição:** Utiliza DMVs (Dynamic Management Views) como `sys.dm_exec_query_stats` para identificar as 50 consultas mais "caras" em termos de CPU, leitura de dados e duração. Essencial para iniciar uma análise de performance tuning.
*   **`Verifica_Fragmentacao_Indices.sql`**
    *   **Descrição:** Script que varre os índices de um banco de dados específico para verificar o nível de fragmentação. Com base no resultado, sugere a execução de `REBUILD` ou `REORGANIZE`.
*   **`Analisa_Waits_Servidor.sql`**
    *   **Descrição:** Captura as estatísticas de espera (wait stats) do SQL Server, ajudando a diagnosticar gargalos como problemas de I/O (disco), CPU ou bloqueios na rede.

### 2. Manutenção e Automação

*   **`Rotina_Backup_Full_Log.sql`**
    *   **Descrição:** Modelo de script para criar uma rotina de backup `FULL` diário e de `LOG` a cada 15 minutos para bancos de dados em modo de recuperação "Full". Inclui comentários sobre como adaptar e agendar via SQL Server Agent.
*   **`Verifica_Saude_Backups.sql`**
    *   **Descrição:** Consulta o histórico de backups na base `msdb` para garantir que as políticas de backup estão sendo executadas conforme o esperado e alerta sobre bancos que não tiveram backup recente.

### 3. Administração e Segurança

*   **`Lista_Permissoes_Usuario.sql`**
    *   **Descrição:** Script que recebe o nome de um usuário como parâmetro e lista todas as permissões efetivas que ele possui no servidor e nos bancos de dados, facilitando auditorias de segurança.

---

## 🛠️ Como Utilizar

1.  Clone este repositório ou baixe os scripts individualmente.
2.  Abra os arquivos `.sql` no SQL Server Management Studio (SSMS) ou Azure Data Studio.
3.  Adapte as variáveis (como nome do banco de dados ou do usuário) conforme indicado nos comentários de cada script.
4.  Execute e analise os resultados.

## 💡 Sobre Mim

*   **Certificação:** Microsoft DP-300 (concluída em 01/2025).
*   **Principais Habilidades:** T-SQL, Performance Tuning, Backup & Recovery, Administração de SQL Server, Análise de DMVs, Noções de Infraestrutura e Ambientes ERP.
*   **Objetivo:** Conquistar minha primeira oportunidade como DBA SQL Server, onde eu possa aplicar minha paixão por dados para garantir a estabilidade, segurança e performance de ambientes de missão crítica.

