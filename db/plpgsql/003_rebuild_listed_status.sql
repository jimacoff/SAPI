CREATE OR REPLACE FUNCTION rebuild_listing_status_for_designation_and_node(
  designation designations, node_id integer
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      deletion_id int;
      addition_id int;
      exception_id int;
      status_flag varchar;
      status_original_flag varchar;
      listing_updated_at_flag varchar;
      flags_to_reset text[];
    BEGIN
    SELECT id INTO deletion_id FROM change_types
      WHERE designation_id = designation.id AND name = 'DELETION';
    SELECT id INTO addition_id FROM change_types
      WHERE designation_id = designation.id AND name = 'ADDITION';
    SELECT id INTO exception_id FROM change_types
      WHERE designation_id = designation.id AND name = 'EXCEPTION';

    status_flag = LOWER(designation.name) || '_status';
    status_original_flag = LOWER(designation.name) || '_status_original';
    listing_updated_at_flag = LOWER(designation.name) || '_updated_at';
    flags_to_reset := ARRAY[status_flag, status_original_flag, listing_updated_at_flag];
    IF designation.name = 'CITES' THEN 
      flags_to_reset := flags_to_reset ||
        ARRAY['cites_listing','cites_I','cites_II','cites_III','cites_NC'];
    ELSIF designation.name = 'EU' THEN
      flags_to_reset := flags_to_reset ||
        ARRAY['eu_listing','eu_A','eu_B','eu_C','eu_D','eu_NEU'];
    END IF;

    -- reset the listing status (so we start clear)
    UPDATE taxon_concepts
    SET listing = (COALESCE(listing, ''::HSTORE) - flags_to_reset) ||
      hstore('listing_updated_at', NULL) -- TODO get rid of this
    WHERE taxonomy_id = designation.taxonomy_id AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    -- set cites_status property to 'LISTED' for all explicitly listed taxa
    -- i.e. ones which have at least one current ADDITION
    -- also set cites_status_original flag to true
    -- also set the listing_updated_at property
    WITH listed_taxa AS (
      SELECT taxon_concepts.id, MAX(effective_at) AS listing_updated_at
      FROM taxon_concepts
      INNER JOIN listing_changes
        ON taxon_concepts.id = listing_changes.taxon_concept_id
        AND is_current = 't'
        AND change_type_id = addition_id
      WHERE taxonomy_id = designation.taxonomy_id
      GROUP BY taxon_concepts.id
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(status_flag, 'LISTED') ||
      hstore(status_original_flag, 't') ||
      hstore(listing_updated_at_flag, listing_updated_at::VARCHAR) ||
      hstore('listing_updated_at', listing_updated_at::VARCHAR) --TODO get rid of this
    FROM listed_taxa
    WHERE taxon_concepts.id = listed_taxa.id AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- set cites_status property to 'DELETED' for all explicitly deleted taxa
    -- omit ones already marked as listed (applies to appendix III deletions)
    -- also set cites_status_original flag to true
    WITH deleted_taxa AS (
      SELECT taxon_concepts.id
      FROM taxon_concepts
      INNER JOIN listing_changes
        ON taxon_concepts.id = listing_changes.taxon_concept_id
        AND is_current = 't' AND change_type_id = deletion_id
      WHERE taxonomy_id = designation.taxonomy_id AND (
        listing -> status_flag <> 'LISTED'
          OR (listing -> status_flag)::VARCHAR IS NULL
      )
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(status_flag, 'DELETED') ||
      hstore(status_original_flag, 't')
    FROM deleted_taxa
    WHERE taxon_concepts.id = deleted_taxa.id AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- set cites_status property to 'EXCLUDED' for all explicitly excluded taxa
    -- omit ones already marked as listed
    -- also set cites_status_original flag to true
    WITH excluded_taxa AS (
      WITH listing_exceptions AS (
        SELECT listing_changes.parent_id, taxon_concept_id
        FROM listing_changes
        INNER JOIN taxon_concepts
          ON listing_changes.taxon_concept_id  = taxon_concepts.id
            AND taxonomy_id = designation.taxonomy_id
            AND (
              listing -> status_flag <> 'LISTED'
              OR (listing -> status_flag)::VARCHAR IS NULL
            )
        WHERE change_type_id = exception_id
      )
      SELECT DISTINCT listing_exceptions.taxon_concept_id AS id
      FROM listing_exceptions
      INNER JOIN listing_changes
        ON listing_changes.id = listing_exceptions.parent_id
          AND listing_changes.taxon_concept_id <> listing_exceptions.taxon_concept_id
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(status_flag, 'EXCLUDED') ||
      hstore(status_original_flag, 't')
    FROM excluded_taxa
    WHERE taxon_concepts.id = excluded_taxa.id AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;


    -- set the cites_status_original flag to false for taxa included in parent listing
    UPDATE taxon_concepts
    SET listing = listing || hstore(status_original_flag, 'f')
    FROM
    listing_changes
    WHERE
      taxon_concepts.id = listing_changes.taxon_concept_id
      AND is_current = 't'
      AND inclusion_taxon_concept_id IS NOT NULL
      AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- propagate cites_status to descendants
    WITH RECURSIVE q AS
    (
      SELECT  h.id, h.parent_id,
      listing->status_flag AS inherited_cites_status,
      listing->listing_updated_at_flag AS inherited_listing_updated_at
      FROM    taxon_concepts h
      WHERE (listing->status_original_flag)::BOOLEAN = 't' AND
        CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END

      UNION

      SELECT  hi.id, hi.parent_id,
      inherited_cites_status,
      inherited_listing_updated_at
      FROM    q
      JOIN    taxon_concepts hi
      ON      hi.parent_id = q.id
      WHERE listing IS NULL OR
        (listing->status_original_flag)::BOOLEAN IS NULL OR
        (listing->status_original_flag)::BOOLEAN = 'f'
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) ||
      hstore(status_flag, inherited_cites_status) ||
      hstore(status_original_flag, 'f') ||
      hstore('cites_NC', NULL) ||
      hstore(listing_updated_at_flag, inherited_listing_updated_at) ||
      hstore('listing_updated_at', inherited_listing_updated_at) --TODO get rid of this
    FROM q
    WHERE taxon_concepts.id = q.id AND (
      listing IS NULL OR
      (listing->status_original_flag)::BOOLEAN IS NULL OR
      (listing->status_original_flag)::BOOLEAN = 'f'
    );

    -- set cites_status property to 'LISTED' for ancestors of listed taxa
    WITH qq AS (
      WITH RECURSIVE q AS
      (
        SELECT  h.id, h.parent_id,
        listing->status_flag AS inherited_cites_status,
        (listing->listing_updated_at_flag)::TIMESTAMP AS inherited_listing_updated_at
        FROM    taxon_concepts h
        WHERE
          listing->status_flag = 'LISTED'
          AND (listing->status_original_flag)::BOOLEAN = 't'
          AND
          CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END

        UNION

        SELECT  hi.id, hi.parent_id,
        CASE
          WHEN (listing->status_original_flag)::BOOLEAN = 't'
          THEN listing->status_flag
          ELSE inherited_cites_status
        END,
        CASE
          WHEN (listing->listing_updated_at_flag)::TIMESTAMP IS NOT NULL
          THEN (listing->listing_updated_at_flag)::TIMESTAMP
          ELSE inherited_listing_updated_at
        END
        FROM    q
        JOIN    taxon_concepts hi
        ON      hi.id = q.parent_id
        WHERE (listing->status_original_flag)::BOOLEAN IS NULL
      )
      SELECT DISTINCT id, inherited_cites_status, 
        inherited_listing_updated_at
      FROM q
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) ||
      hstore(status_flag, inherited_cites_status) ||
      hstore(status_original_flag, 'f') ||
      hstore(listing_updated_at_flag, inherited_listing_updated_at::VARCHAR) ||
      hstore('listing_updated_at', inherited_listing_updated_at::VARCHAR) --TODO get rid of this
    FROM qq
    WHERE taxon_concepts.id = qq.id
     AND (
       listing IS NULL 
       OR (listing->status_original_flag)::BOOLEAN IS NULL
       OR (listing->status_original_flag)::BOOLEAN = 'f'
     );

    END;
  $$;
