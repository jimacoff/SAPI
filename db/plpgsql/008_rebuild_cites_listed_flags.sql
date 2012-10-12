--
-- Name: rebuild_cites_listed_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_cites_listed_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

        -- set the cites_listed flag to NULL for all taxa (so we start clear)
        UPDATE taxon_concepts SET listing =
          CASE
            WHEN listing IS NULL THEN ''::HSTORE
            ELSE listing - ARRAY['cites_listing','cites_I','cites_II','cites_III','not_in_cites']
          END || hstore('cites_listed', NULL) || hstore('listing_updated_at', NULL);

        -- set the cited_listed flag to true for all explicitly listed taxa
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_listed', 't') ||
          hstore('listing_updated_at', listing_updated_at::VARCHAR)
        FROM (
          SELECT taxon_concept_id, MAX(effective_at) AS listing_updated_at
          FROM listing_changes
          GROUP BY taxon_concept_id
        ) AS q
        WHERE taxon_concepts.id = q.taxon_concept_id;

        -- set the cites_listed flag to false for all implicitly listed taxa (children)
        WITH RECURSIVE q AS
        (
          SELECT  h,
          (listing->'cites_listed')::BOOLEAN AS inherited_cites_listing,
          listing->'listing_updated_at' AS inherited_listing_updated_at
          FROM    taxon_concepts h
          WHERE   parent_id IS NULL

          UNION ALL

          SELECT  hi,
          CASE
            WHEN (listing->'cites_listed')::BOOLEAN = 't' THEN 't'
            ELSE inherited_cites_listing
          END,
          CASE
            WHEN (listing->'listing_updated_at')::TIMESTAMP IS NOT NULL
            THEN listing->'listing_updated_at'
            ELSE inherited_listing_updated_at
          END
          FROM    q
          JOIN    taxon_concepts hi
          ON      hi.parent_id = (q.h).id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_listed', 'f') || hstore('listing_updated_at', inherited_listing_updated_at)
        FROM q
        WHERE taxon_concepts.id = (q.h).id AND
          ((q.h).listing->'cites_listed')::BOOLEAN IS NULL AND
          q.inherited_cites_listing = 't';

        -- set the cites_listed flag to false for all implicitly listed taxa (parents)
        WITH qq AS (
          WITH RECURSIVE q AS
          (
            SELECT  h,
            (listing->'cites_listed')::BOOLEAN AS inherited_cites_listing,
            (listing->'listing_updated_at')::TIMESTAMP AS inherited_listing_updated_at,
            id AS listed_child_id,
            id AS listed_parent_id
            FROM    taxon_concepts h
            WHERE   (listing->'cites_listed')::BOOLEAN = 't'

            UNION ALL

            SELECT  hi,
            CASE
              WHEN (listing->'cites_listed')::BOOLEAN IS NULL THEN 'f'
              ELSE (listing->'cites_listed')::BOOLEAN
            END,
            CASE
              WHEN (listing->'listing_updated_at')::TIMESTAMP IS NOT NULL
              THEN (listing->'listing_updated_at')::TIMESTAMP
              ELSE inherited_listing_updated_at
            END,
            listed_child_id,
            id
            FROM    q
            JOIN    taxon_concepts hi
            ON      hi.id = (q.h).parent_id
          )
          SELECT DISTINCT listed_parent_id, inherited_cites_listing,
            inherited_listing_updated_at
          FROM q
          WHERE inherited_cites_listing = 'f'
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_listed', 'f') ||
          hstore('listing_updated_at', inherited_listing_updated_at::VARCHAR)
        FROM qq
        WHERE taxon_concepts.id = qq.listed_parent_id;

        -- set cites_show to true for all explicitly or implicitly listed taxa
        -- unless they're implicitly listed subspecies
        -- or species of the family Orchidaceae
        UPDATE taxon_concepts SET listing = listing || 
        CASE
          WHEN (data->'rank_name' = 'SUBSPECIES'
          OR data->'rank_name' = 'CLASS'
          OR data->'rank_name' = 'PHYLUM'
          OR data->'rank_name' = 'KINGDOM')
          AND (listing->'cites_listed')::BOOLEAN = 'f'
          THEN hstore('cites_show', 'f')
          WHEN data->'rank_name' <> 'FAMILY'
          AND data->'family_name' = 'Orchidaceae'
          THEN hstore('cites_show', 'f')
          ELSE hstore('cites_show', 't')
        END
        WHERE (listing->'cites_listed')::BOOLEAN IS NOT NULL;

        -- propagate the usr_cites_exclusion flag to all subtaxa
        -- unless they have cites_listed = 't'
        WITH RECURSIVE q AS (
          SELECT h
          FROM taxon_concepts h
          WHERE listing->'usr_cites_exclusion' = 't'

          UNION ALL

          SELECT hi
          FROM q
          JOIN taxon_concepts hi ON hi.parent_id = (q.h).id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_exclusion', 't')
        FROM q
        WHERE taxon_concepts.id = (q.h).id;

        -- set flags for exceptions
        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC') || hstore('cites_listing_original', 'NC') || hstore('cites_show', 't')
        WHERE listing->'usr_cites_exclusion' = 't';

        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC') || hstore('cites_listing_original', 'NC')
        WHERE listing->'cites_exclusion' = 't';

        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC')
        WHERE fully_covered <> 't' OR (listing->'cites_listed')::BOOLEAN IS NULL;

        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_listed_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_listed_flags() IS 'Procedure to rebuild the cites_listed flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - explicit cites listing, "f" - implicit cites listing, "" - N/A';