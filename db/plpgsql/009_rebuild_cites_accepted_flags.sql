--
-- Name: rebuild_cites_accepted_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_cites_accepted_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

        -- set the cites_accepted flag to null for all taxa (so we start clear)
        UPDATE taxon_concepts SET data =
          CASE
            WHEN data IS NULL THEN ''::HSTORE
            ELSE data - ARRAY['cites_accepted']
          END || hstore('cites_accepted', NULL);

        -- set the cites_accepted flag to true for all explicitly referenced taxa
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', 't')
        FROM (
          SELECT taxon_concepts.id
          FROM taxon_concepts
          INNER JOIN taxon_concept_references ON taxon_concept_references.taxon_concept_id = taxon_concepts.id
          INNER JOIN designation_references ON taxon_concept_references.reference_id = designation_references.reference_id
          INNER JOIN designations ON designation_references.designation_id = designations.id
          WHERE designations.name = 'CITES'
        ) AS q
        WHERE taxon_concepts.id = q.id;

        -- set the cites_listed flag to true for all implicitly listed taxa
        WITH RECURSIVE q AS
        (
          SELECT  h,
          (data->'cites_accepted')::BOOLEAN AS inherited_cites_accepted
          FROM    taxon_concepts h
          WHERE   parent_id IS NULL

          UNION ALL

          SELECT  hi,
          CASE
            WHEN (data->'cites_accepted')::BOOLEAN = 't' THEN 't'
            ELSE inherited_cites_accepted
          END
          FROM    q
          JOIN    taxon_concepts hi
          ON      hi.parent_id = (q.h).id
        )
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', 't')
        FROM q
        WHERE taxon_concepts.id = (q.h).id AND
          ((q.h).data->'cites_accepted')::BOOLEAN IS NULL AND
          q.inherited_cites_accepted = 't';

        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_accepted_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_accepted_flags() IS 'Procedure to rebuild the cites_accepted flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - CITES accepted name, "f" - not accepted, but shows in Checklist, null - not accepted, doesn''t show';