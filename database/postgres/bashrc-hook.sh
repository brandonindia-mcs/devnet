

function pgget {
  echo -e "
  \t PGPASSWORD: $(if [ -n "$PGPASSWORD" ];then echo -n '<pswd_is_set>';else echo -n '<NOT_SET>';fi)
  \t PGHOST: $PGHOST
  \t PGPORT: $PGPORT
  \t PGUSER: $PGUSER
  \t PGDATABASE: $PGDATABASE
  \t PGSSLMODE: $PGSSLMODE"
}
function pgprint {
  pgget
}

function pghelp {
find ~/appdev -name '.pghelp' -type f -exec cat {} \;
}

export PGHOST=$PGCONTAINER
export PGDATABASE=
export PGUSER=
export PGPASSWORD=
export PGPORT=
export PGSSLMODE=
pgprint

if ! $(envsubst --version >/dev/null 2>&1);then
sudo apt update
sudo apt install gettext
fi
if ! tree >/dev/null 2>&1;then sudo apt update && sudo apt install tree -y;fi

function pgclear {
  unset  PGUSER  PGDATABASE PGHOST PGPASSWORD PGPORT PGSSLMODE
}

function pgconnect {
  host=$PGHOST
  port=$PGPORT
  db=$PGDATABASE
  user=$PGUSER
  echo docker run -it --rm --network appdev postgres psql -h $host -p $port -U $user -d $db
  docker run -it --rm --network appdev postgres psql -h $host -U $user -d $db
}
function pgusers {
  psql -c "SELECT
r.rolsuper AS is_superuser,
r.rolname AS role_name,
d.datname AS database_name,
r.rolcreaterole AS can_create_roles,
r.rolcreatedb AS can_create_db,
r.rolreplication AS can_replication,
r.rolbypassrls AS bypass_rls,
has_database_privilege(r.rolname, d.datname, 'CONNECT') AS can_connect,
has_database_privilege(r.rolname, d.datname, 'CREATE') AS can_create,
has_database_privilege(r.rolname, d.datname, 'TEMPORARY') AS can_temp
FROM pg_roles r
CROSS JOIN pg_database d
WHERE r.rolname IN ('appowner','appuser')
ORDER BY r.rolsuper DESC, r.rolname, d.datname;"
}

function pguserpermissions {
  psql -c "SELECT grantee, table_schema, table_name, privilege_type
FROM information_schema.role_table_grants
ORDER BY grantee, table_schema, table_name;"
}

function pgdatabase {
  schema=$1
  database=$2
  owner=${database}owner
  user=${database}user
  pswd=$3
  psql -c "
CREATE ROLE $owner WITH LOGIN PASSWORD '$pswd';"
  psql -c "
CREATE DATABASE $database OWNER $owner;"
  psql -c "
CREATE ROLE $user WITH LOGIN PASSWORD '$pswd';
"
  psql -d $database -c "
GRANT USAGE ON SCHEMA $schema TO $user;
GRANT CREATE ON SCHEMA $schema TO $user;"
  psql -c "
-- Existing tables
GRANT SELECT, INSERT, UPDATE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA $schema TO $user;

-- Future tables
ALTER DEFAULT PRIVILEGES FOR ROLE $owner IN SCHEMA $schema
GRANT SELECT, INSERT, UPDATE, TRUNCATE, REFERENCES, TRIGGER ON TABLES TO $user;

-- Existing sequences
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA $schema TO $user;

-- Future sequences
ALTER DEFAULT PRIVILEGES FOR ROLE $owner IN SCHEMA $schema
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO $user;

GRANT CONNECT ON DATABASE $database TO $user;
GRANT TEMPORARY ON DATABASE $database TO $user;"

}

