CREATE EXTENSION IF NOT POSTGIS;
ALTER VIEW geometry_columns OWNER TO ckan;
ALTER TABLE spatial_ref_sys OWNER TO ckan;