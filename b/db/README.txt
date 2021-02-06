scripts/createdb.sh
scripts/createuser.sh
psql -U postgres -h localhost
\c auth
\ir create_schema.sql
\ir grant.sql
\q
psql -U auth -h localhost
\ir create_tables.sql
