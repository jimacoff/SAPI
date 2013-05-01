CREATE OR REPLACE FUNCTION rebuild_descendant_cites_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CITES';
    PERFORM rebuild_descendant_listing_for_designation_and_node(designation, node_id);
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_descendant_cites_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      PERFORM rebuild_descendant_cites_listing_for_node(NULL);
    END;
  $$;


COMMENT ON FUNCTION rebuild_descendant_cites_listing() IS 'Procedure to rebuild CITES descendant listings in taxon_concepts.';