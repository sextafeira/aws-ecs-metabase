-- Execute como dbadmin, conectado ao banco metabase, antes de iniciar a aplicação.
-- Se alterar db_name ou db_username no terraform.tfvars, ajuste os identificadores.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'metabase') THEN
    CREATE ROLE metabase LOGIN;
  END IF;
END
$$;

GRANT rds_iam TO metabase;
GRANT CONNECT, CREATE, TEMPORARY ON DATABASE metabase TO metabase;
GRANT USAGE, CREATE ON SCHEMA public TO metabase;

-- Verificação do usuário e da associação ao papel IAM.
SELECT rolname, rolcanlogin,
       pg_has_role(rolname, 'rds_iam', 'member') AS iam_enabled
FROM pg_roles
WHERE rolname = 'metabase';

-- Verificação das permissões no banco e schema atuais.
SELECT current_database(),
       has_database_privilege('metabase', current_database(), 'CONNECT') AS can_connect,
       has_database_privilege('metabase', current_database(), 'CREATE') AS can_create_schema,
       has_schema_privilege('metabase', 'public', 'USAGE') AS can_use_schema,
       has_schema_privilege('metabase', 'public', 'CREATE') AS can_create_objects;
