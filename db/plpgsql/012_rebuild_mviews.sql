--
-- Name: rebuild_mviews(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_mviews() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_taxon_concepts_mview();
    PERFORM rebuild_listing_changes_mview();
  END;
  $$;

COMMENT ON FUNCTION rebuild_mviews() IS 'Procedure to rebuild materialized views in the database.';

--
-- Name: rebuild_taxon_concepts_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_taxon_concepts_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    RAISE NOTICE 'Dropping taxon concepts materialized view';
    DROP table taxon_concepts_mview;

    RAISE NOTICE 'Creating taxon concepts materialized view';
    CREATE TABLE taxon_concepts_mview AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM taxon_concepts_view;

    CREATE UNIQUE INDEX taxon_concepts_mview_on_id ON taxon_concepts_mview (id);
  END;
  $$;

COMMENT ON FUNCTION rebuild_taxon_concepts_mview() IS 'Procedure to rebuild taxon concepts materialized view in the database.';

--
-- Name: rebuild_listing_changes_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_listing_changes_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    RAISE NOTICE 'Dropping listing changes materialized view';
    DROP table listing_changes_mview;

    RAISE NOTICE 'Creating listing changes materialized view';
    CREATE TABLE listing_changes_mview AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM listing_changes_view;

    CREATE UNIQUE INDEX listing_changes_mview_on_id ON listing_changes_mview (id);
  END;
  $$;

COMMENT ON FUNCTION rebuild_listing_changes_mview() IS 'Procedure to rebuild listing changes materialized view in the database.';
