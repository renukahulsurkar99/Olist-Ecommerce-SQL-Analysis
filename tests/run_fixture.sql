\set ON_ERROR_STOP on
BEGIN;
\ir ../sql/00_schema.sql
\ir fixture.sql
\ir ../sql/02_views.sql
\ir integrity.sql
\ir behavior.sql
COMMIT;
