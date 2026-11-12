\set ON_ERROR_STOP on
\pset pager off
BEGIN;
\ir 00_schema.sql
\ir 01_load.sql
\ir 02_views.sql
\ir ../tests/integrity.sql
\ir ../tests/dataset_controls.sql
COMMIT;
\echo 'Loaded and validated Olist. Run sql/03_analysis.sql next.'
