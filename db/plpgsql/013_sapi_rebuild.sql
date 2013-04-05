--
-- Name: sapi_rebuild(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION sapi_rebuild() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
          RAISE NOTICE 'Rebuilding SAPI database';
          --RAISE NOTICE 'names and ranks';
          PERFORM rebuild_names_and_ranks();
          --RAISE NOTICE 'taxonomic positions';
          PERFORM rebuild_taxonomic_positions();
          PERFORM rebuild_cites_listed_status();
          PERFORM rebuild_fully_covered_flags();
          PERFORM rebuild_cites_nc_flags();
          --RAISE NOTICE 'listings';
          PERFORM rebuild_listings();
          --RAISE NOTICE 'descendant listings';
          PERFORM rebuild_descendant_listings();
          --RAISE NOTICE 'ancestor listings';
          PERFORM rebuild_ancestor_listings();
          PERFORM rebuild_cites_accepted_flags();
          PERFORM rebuild_cites_show_flags();
        END;
      $$;


--
-- Name: FUNCTION sapi_rebuild(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION sapi_rebuild() IS 'Procedure to rebuild computed fields in the database.';
