set -x
createdb -h localhost -U postgres -T template0 --echo --encoding=UTF8 auth
