-- =================================================================================
-- Autor: Micael Tonini
-- Data: 01/26
--
-- Descrição:
-- Script para auditar as permissões de um usuário (principal) específico
-- em um banco de dados.
--
-- Ele lista:
-- 1. As roles (funções) das quais o usuário é membro (ex: db_owner, db_datareader).
-- 2. As permissões explícitas (GRANT/DENY) concedidas ao usuário em objetos
--    como tabelas, views e procedures.
--
-- DMVs e Tabelas Utilizadas:
-- - sys.database_principals: Lista todos os principais de segurança no banco.
-- - sys.database_role_members: Mapeia usuários para roles.
-- - sys.database_permissions: Lista permissões concedidas/negadas.
-- - sys.objects: Metadados dos objetos do banco.
-- =================================================================================

-- Parâmetro: Altere para o nome do usuário que deseja auditar
DECLARE @UserName NVARCHAR(128) = 'NomeDoUsuario';

-- =================================================================================
-- PARTE 1: Listar as Roles (Funções) do Usuário
-- =================================================================================
PRINT '================================================';
PRINT 'Roles para o usuário: ' + @UserName;
PRINT '================================================';

SELECT
    roles.name AS RoleName,
    users.name AS MemberName
FROM
    sys.database_role_members AS members
JOIN
    sys.database_principals AS roles ON members.role_principal_id = roles.principal_id
JOIN
    sys.database_principals AS users ON members.member_principal_id = users.principal_id
WHERE
    users.name = @UserName;
GO

-- =================================================================================
-- PARTE 2: Listar Permissões Explícitas em Objetos
-- =================================================================================
PRINT '';
PRINT '================================================';
PRINT 'Permissões explícitas para o usuário: ' + @UserName;
PRINT '================================================';

SELECT
    perm.state_desc AS TipoPermissao, -- ex: GRANT, DENY
    perm.permission_name AS Permissao, -- ex: SELECT, INSERT, EXECUTE
    obj.name AS NomeObjeto,
    obj.type_desc AS TipoObjeto -- ex: USER_TABLE, VIEW
FROM
    sys.database_permissions AS perm
JOIN
    sys.database_principals AS users ON perm.grantee_principal_id = users.principal_id
LEFT JOIN
    sys.objects AS obj ON perm.major_id = obj.object_id
WHERE
    users.name = @UserName
    AND perm.major_id > 0 -- Filtra permissões a nível de banco, focando em objetos
ORDER BY
    TipoObjeto, NomeObjeto;
GO
